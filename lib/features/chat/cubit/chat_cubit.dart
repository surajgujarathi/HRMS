import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/shared_pref.dart';
import '../../../network/odoo_service.dart';
import '../models/chat_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState());

  WebSocketChannel? _channelSocket;
  StreamSubscription? _channelSubscription;
  Timer? _pollingTimer;

  Future<void> initChat() async {
    emit(state.copyWith(status: ChatStatus.loading));
    await fetchChannels();
    _initWebSockets();
  }

  Future<void> _initWebSockets() async {
    try {
      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final sessionJson = await prefs.getObject('session');
      
      if (baseUrl == null || sessionJson == null) return;

      final uri = Uri.parse(baseUrl.trim());
      final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final host = uri.host;
      // Ensure we don't have trailing slashes or fragments
      final wsUrl = '$wsScheme://$host/longpolling';
      final sessionId = sessionJson['session_id'];

      debugPrint('ChatCubit: Attempting WebSocket connection to $wsUrl');

      _channelSocket = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {'Cookie': 'session_id=$sessionId'},
      );

      _channelSubscription = _channelSocket!.stream.listen(
        (message) {
          debugPrint('ChatCubit: WebSocket Message Received: $message');
          final decoded = json.decode(message);
          // Odoo Bus logic
          fetchChannels();
          if (state.currentChatId != null) {
            fetchMessages(int.parse(state.currentChatId!));
          }
        },
        onError: (error) {
          debugPrint('ChatCubit: WebSocket Error: $error');
          _startPolling();
        },
        onDone: () {
          debugPrint('ChatCubit: WebSocket Closed');
          _startPolling();
        },
      );
    } catch (e) {
      debugPrint('ChatCubit: WebSocket Connection Failed: $e');
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchChannels();
      if (state.currentChatId != null) {
        fetchMessages(int.parse(state.currentChatId!));
      }
    });
  }

  Future<void> fetchChannels() async {
    try {
      debugPrint('ChatCubit: Fetching channels from Odoo...');
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) {
        debugPrint('ChatCubit: Error - Session or BaseURL is null');
        return;
      }

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      // 1. Fetch channel members for the current user
      final channelMembers = await client.callKw({
        'model': 'discuss.channel.member',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [['partner_id', '=', session.partnerId]],
          'fields': [
            'channel_id',
            'message_unread_counter',
            'custom_channel_name',
            'is_pinned',
            'seen_message_id',
            'fetched_message_id',
            'mute_until_dt',
            'fold_state',
            'last_interest_dt'
          ],
        },
      });

      final channelIds = channelMembers
          .map((m) => m['channel_id'])
          .where((id) => id != null)
          .map((id) => id is List ? id[0] : id)
          .toList();

      // 2. Fetch channel details
      final channelRecords = await client.callKw({
        'model': 'discuss.channel',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [['id', 'in', channelIds]],
          'fields': [
            'id',
            'name',
            'channel_type',
            'display_name',
            'image_128',
            'channel_member_ids',
            'description',
            'active',
            'parent_channel_id',
            'sub_channel_ids'
          ],
        },
      });

      final List<ChatChannel> channels = [];
      final List<ChatChannel> dms = [];

      // Fetch all member details to find DM partners
      final allMembers = await client.callKw({
        'model': 'discuss.channel.member',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [['channel_id', 'in', channelIds]],
          'fields': ['channel_id', 'partner_id'],
        },
      });

      // Collect partner IDs for status fetching
      final List<int> partnerIdsToFetch = [];
      for (var m in (allMembers as List)) {
        if (m['partner_id'] is List && m['partner_id'][0] != session.partnerId) {
          partnerIdsToFetch.add(m['partner_id'][0]);
        }
      }

      // Fetch im_status and image_128 for these partners
      Map<int, String> partnerStatuses = {};
      Map<int, String?> partnerImages = {};
      if (partnerIdsToFetch.isNotEmpty) {
        final partners = await client.callKw({
          'model': 'res.partner',
          'method': 'read',
          'args': [partnerIdsToFetch, ['im_status', 'image_128']],
          'kwargs': {},
        });
        for (var p in (partners as List)) {
          partnerStatuses[p['id']] = p['im_status'] ?? 'offline';
          partnerImages[p['id']] = p['image_128'] is String ? p['image_128'] : null;
        }
      }

      // Fetch last message bodies and dates directly from mail.message
      Map<int, Map<String, dynamic>> lastMessages = {};
      if (channelIds.isNotEmpty) {
        final messages = await client.callKw({
          'model': 'mail.message',
          'method': 'search_read',
          'args': [
            [
              ['res_id', 'in', channelIds],
              ['model', '=', 'discuss.channel']
            ]
          ],
          'kwargs': {
            'fields': ['res_id', 'body', 'date'],
            'order': 'date desc',
            'limit': 100, // Fetch enough to cover most channels
          },
        });
        for (var m in (messages as List)) {
          final resId = m['res_id'] is List ? m['res_id'][0] : m['res_id'];
          if (!lastMessages.containsKey(resId)) {
            lastMessages[resId] = {
              'body': _stripHtml(m['body'] ?? ''),
              'date': m['date']
            };
          }
        }
      }

      for (var json in (channelRecords as List)) {
        final channel = ChatChannel.fromJson(json, session.userName, session.partnerId);
        
        // Find membership info for unread count and pinning
        final memberInfo = (channelMembers as List).firstWhere(
          (m) => (m['channel_id'] is List ? m['channel_id'][0] : m['channel_id']) == channel.id,
          orElse: () => {},
        );

        // Find DM partner status and image
        String? imStatus;
        String? partnerImage;
        if (channel.type == ChannelType.chat) {
          final otherMember = (allMembers as List).firstWhere(
            (m) => (m['channel_id'] is List ? m['channel_id'][0] : m['channel_id']) == channel.id &&
                   (m['partner_id'] is List ? m['partner_id'][0] : m['partner_id']) != session.partnerId,
            orElse: () => null,
          );
          if (otherMember != null) {
            final pid = otherMember['partner_id'] is List ? otherMember['partner_id'][0] : otherMember['partner_id'];
            imStatus = partnerStatuses[pid];
            partnerImage = partnerImages[pid];
          }
        }

        final lastInterestStr = memberInfo['last_interest_dt'];
        final lastInterestDt = lastInterestStr != null ? DateTime.tryParse(lastInterestStr)?.toLocal() : null;

        // Get last message info
        final lastMsgInfo = lastMessages[channel.id];
        final lastMsgText = lastMsgInfo?['body'] ?? '';
        final lastMsgDateStr = lastMsgInfo?['date'];
        final lastMsgDate = lastMsgDateStr != null ? DateTime.tryParse(lastMsgDateStr)?.toLocal() : null;
        final lastMsgTime = lastMsgDate != null 
            ? (DateTime.now().difference(lastMsgDate).inDays == 0 
                ? DateFormat('h:mm a').format(lastMsgDate)
                : DateFormat('MMM d').format(lastMsgDate))
            : '';

        final rawDisplayName = memberInfo['custom_channel_name'] is String ? memberInfo['custom_channel_name'] : channel.displayName;
        final finalDisplayName = _formatDisplayName(rawDisplayName, session.userName, channel.type);

        final updatedChannel = ChatChannel(
          id: channel.id,
          name: channel.name,
          displayName: finalDisplayName,
          type: channel.type,
          unreadCount: memberInfo['message_unread_counter'] ?? 0,
          isPinned: memberInfo['is_pinned'] ?? false,
          memberCount: channel.memberCount,
          image: (channel.image == null || channel.image == "false") ? partnerImage : channel.image,
          description: channel.description,
          active: channel.active,
          parentChannelId: channel.parentChannelId,
          subChannelIds: channel.subChannelIds,
          sfuChannelUuid: channel.sfuChannelUuid,
          sfuServerUrl: channel.sfuServerUrl,
          imStatus: imStatus,
          lastInterestDt: lastInterestDt,
          lastMessage: lastMsgText,
          lastMessageTime: lastMsgTime,
          lastMessageRaw: lastMsgDate,
        );

        if (updatedChannel.type == ChannelType.chat) {
          dms.add(updatedChannel);
        } else {
          channels.add(updatedChannel);
        }
      }

      // Sort by last message date descending (newest first)
      channels.sort((a, b) {
        if (a.isPinned != b.isPinned) return b.isPinned ? -1 : 1;
        final dateA = a.lastMessageRaw ?? a.lastInterestDt;
        final dateB = b.lastMessageRaw ?? b.lastInterestDt;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      dms.sort((a, b) {
        if (a.isPinned != b.isPinned) return b.isPinned ? -1 : 1;
        final dateA = a.lastMessageRaw ?? a.lastInterestDt;
        final dateB = b.lastMessageRaw ?? b.lastInterestDt;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      emit(state.copyWith(
        status: ChatStatus.loaded,
        channels: channels,
        directMessages: dms,
      ));
    } catch (e) {
      debugPrint('ChatCubit: Fetch Channels Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchContacts() async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return [];

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      // Search partners who have a linked user (employees/users)
      final result = await client.callKw({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['user_ids', '!=', false],
            ['id', '!=', session.partnerId] // Don't show myself
          ],
          'fields': ['id', 'name', 'email', 'image_128', 'function'],
          'limit': 100,
        },
      });

      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Fetch Contacts Error: $e');
      return [];
    }
  }

  Future<ChatChannel?> createDirectMessage(int partnerId) async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return null;

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      // channel_get is the standard Odoo method for starting DMs across versions
      final result = await client.callKw({
        'model': 'discuss.channel',
        'method': 'channel_get',
        'args': [],
        'kwargs': {
          'partners_to': [partnerId],
        },
      });

      if (result != null && result is Map && result['id'] != null) {
        final int channelId = result['id'];
        
        // Fetch the newly created channel details immediately
        final channelRecord = await client.callKw({
          'model': 'discuss.channel',
          'method': 'read',
          'args': [[channelId], ['id', 'name', 'channel_type', 'display_name', 'image_128', 'channel_member_ids', 'description', 'active']],
          'kwargs': {},
        });

        if (channelRecord != null && (channelRecord as List).isNotEmpty) {
          final newChannelJson = channelRecord[0];
          
          // Fetch the partner's image since channel_get doesn't return it
          final partnerData = await client.callKw({
            'model': 'res.partner',
            'method': 'read',
            'args': [[partnerId], ['image_128']],
            'kwargs': {},
          });

          String? partnerImage;
          if (partnerData != null && (partnerData as List).isNotEmpty) {
            partnerImage = partnerData[0]['image_128'] is String ? partnerData[0]['image_128'] : null;
          }

          final baseChannel = ChatChannel.fromJson(newChannelJson, session.userName, session.partnerId);
          final newChannel = baseChannel.copyWith(
            image: (baseChannel.image == null || baseChannel.image == "false") ? partnerImage : baseChannel.image,
          );
          
          // Trigger a full background refresh to update the list
          fetchChannels(); 
          return newChannel;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Create DM Error: $e');
      return null;
    }
  }

  Future<void> fetchMessages(int channelId) async {
    try {
      debugPrint('ChatCubit: Fetching messages for channel $channelId...');
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return;

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      final response = await client.callKw({
        'model': 'mail.message',
        'method': 'search_read',
        'args': [
          [
            ['res_id', '=', channelId],
            ['model', '=', 'discuss.channel']
          ]
        ],
        'kwargs': {
          'fields': [
            'id',
            'date',
            'author_id',
            'body',
            'message_type',
            'attachment_ids',
            'subject',
            'subtype_id',
            'partner_ids',
            'needaction',
            'starred_partner_ids'
          ],
          'limit': 50,
          'order': 'date desc'
        }
      });

      final List<ChatMessage> messages = [];
      
      // 1. Collect all attachment IDs
      final List<int> allAttachmentIds = [];
      for (var msg in (response as List)) {
        if (msg['attachment_ids'] is List) {
          allAttachmentIds.addAll((msg['attachment_ids'] as List).cast<int>());
        }
      }

      // 2. Fetch ir.attachment details (metadata only)
      Map<int, ChatAttachment> attachmentMap = {};
      if (allAttachmentIds.isNotEmpty) {
        final attachmentRecords = await client.callKw({
          'model': 'ir.attachment',
          'method': 'read',
          'args': [allAttachmentIds, ['id', 'name', 'mimetype', 'file_size', 'create_uid']],
          'kwargs': {},
        });
        for (var att in (attachmentRecords as List)) {
          attachmentMap[att['id']] = ChatAttachment.fromJson(att);
        }
      }

      // 3. Process messages and they will be in DESC order (newest first)
      for (var msg in (response as List)) {
        final author = msg['author_id'] is List ? msg['author_id'][1] : 'Unknown';
        final authorId = msg['author_id'] is List ? msg['author_id'][0] : 0;
        final date = DateTime.tryParse(msg['date'])?.toLocal() ?? DateTime.now();

        // Map attachments to this message
        final List<ChatAttachment> msgAttachments = [];
        if (msg['attachment_ids'] is List) {
          for (var id in (msg['attachment_ids'] as List)) {
            if (attachmentMap.containsKey(id)) {
              msgAttachments.add(attachmentMap[id]!);
            }
          }
        }

        messages.add(ChatMessage(
          id: msg['id'],
          sender: author,
          senderId: authorId,
          message: _stripHtml(msg['body'] ?? ''),
          date: date,
          formattedDate: DateFormat('h:mm a').format(date),
          isMe: authorId == session.partnerId,
          messageType: msg['message_type'],
          attachments: msgAttachments,
          subject: msg['subject'] is String ? msg['subject'] : null,
          subtypeId: msg['subtype_id'] is List 
              ? msg['subtype_id'][0] 
              : (msg['subtype_id'] is int ? msg['subtype_id'] : null),
          partnerIds: msg['partner_ids'] is List ? (msg['partner_ids'] as List).cast<int>() : null,
          needAction: msg['needaction'] is bool ? msg['needaction'] : false,
          starredPartnerIds: msg['starred_partner_ids'] is List ? (msg['starred_partner_ids'] as List).cast<int>() : null,
        ));
      }

      // Mark the last message as read
      if (messages.isNotEmpty) {
        markAsRead(channelId, messages.first.id);
      }

      // Reverse to show chronologically (oldest at top, newest at bottom)
      final chronologicalMessages = messages.reversed.toList();
      
      debugPrint('ChatCubit: Emitting ${chronologicalMessages.length} messages for channel $channelId');
      emit(state.copyWith(
        activeMessages: chronologicalMessages,
        currentChatId: channelId.toString(),
      ));
    } catch (e) {
      debugPrint('ChatCubit: Fetch Messages Error: $e');
    }
  }

  Future<void> markAsRead(int channelId, int messageId) async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return;

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      // Find the membership record ID for this channel and partner
      final memberships = await client.callKw({
        'model': 'discuss.channel.member',
        'method': 'search',
        'args': [
          [
            ['channel_id', '=', channelId],
            ['partner_id', '=', session.partnerId]
          ]
        ],
        'kwargs': {},
      });

      if (memberships != null && (memberships as List).isNotEmpty) {
        final memberId = memberships[0];
        await client.callKw({
          'model': 'discuss.channel.member',
          'method': 'write',
          'args': [
            [memberId],
            {'seen_message_id': messageId}
          ],
          'kwargs': {},
        });
        debugPrint('ChatCubit: Updated seen_message_id to $messageId for member $memberId');
      }
    } catch (e) {
      debugPrint('ChatCubit: Mark As Read Error: $e');
    }
  }

  Future<bool> joinChannel(int channelId) async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return false;

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      await client.callKw({
        'model': 'discuss.channel',
        'method': 'action_join',
        'args': [
          [channelId]
        ],
        'kwargs': {},
      });
      await fetchChannels();
      return true;
    } catch (e) {
      debugPrint('ChatCubit: Join Channel Error: $e');
      return false;
    }
  }

  Future<bool> leaveChannel(int channelId) async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return false;

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      await client.callKw({
        'model': 'discuss.channel',
        'method': 'action_leave',
        'args': [
          [channelId]
        ],
        'kwargs': {},
      });
      await fetchChannels();
      return true;
    } catch (e) {
      debugPrint('ChatCubit: Leave Channel Error: $e');
      return false;
    }
  }

  Future<Uint8List?> downloadAttachment(int attachmentId) async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return null;

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      final result = await client.callKw({
        'model': 'ir.attachment',
        'method': 'read',
        'args': [[attachmentId], ['datas']],
        'kwargs': {},
      });

      if (result != null && (result as List).isNotEmpty) {
        var datas = result[0]['datas'];
        if (datas is String && datas != "false") {
          // Clean the base64 string: remove all whitespace and potential data prefixes
          final cleanedDatas = datas.trim().replaceAll(RegExp(r'\s+'), '');
          final actualBase64 = cleanedDatas.contains(',') 
              ? cleanedDatas.split(',').last 
              : cleanedDatas;
          
          try {
            return base64Decode(actualBase64);
          } catch (e) {
            debugPrint('Base64 Decode Error: $e');
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Download Attachment Error: $e');
      return null;
    }
  }

  Future<bool> sendMessage(int channelId, String text, {List<ChatAttachment>? attachments}) async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return false;

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      final List<List<dynamic>> attachmentData = [];
      if (attachments != null) {
        for (var att in attachments) {
          if (att.bytes != null) {
            // Odoo 17/18 expects a list of lists/tuples: [name, datas]
            attachmentData.add([
              att.name,
              base64Encode(att.bytes!),
            ]);
          }
        }
      }

      debugPrint('ChatCubit: Sending message to channel $channelId with ${attachmentData.length} attachments');
      final result = await client.callKw({
        'model': 'discuss.channel',
        'method': 'message_post',
        'args': [channelId],
        'kwargs': {
          'body': text,
          'message_type': 'comment',
          'subtype_xmlid': 'mail.mt_comment',
          if (attachmentData.isNotEmpty) 'attachments': attachmentData,
        },
      });
      
      debugPrint('ChatCubit: Message sent successfully. Result: $result');

      await fetchMessages(channelId);
      return true;
    } catch (e) {
      debugPrint('Send Message Error: $e');
      return false;
    }
  }

  String _formatDisplayName(String name, String currentUserName, ChannelType type) {
    if (type != ChannelType.chat) return name;
    
    // Odoo often uses "Name1, Name2" for DMs
    final parts = name.split(',').map((s) => s.trim()).toList();
    if (parts.length > 1) {
      parts.removeWhere((n) => n.toLowerCase() == currentUserName.toLowerCase());
      if (parts.isNotEmpty) {
        return parts.join(', ');
      }
    }
    return name;
  }

  String _stripHtml(String html) {
    if (html.isEmpty) return "";
    
    String text = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'</p>'), '\n')
        .replaceAll(RegExp(r'</div>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // Remove leading/trailing newlines and multiple spaces
    return text.trim().replaceAll(RegExp(r'\n\s*\n'), '\n');
  }

  @override
  Future<void> close() {
    _channelSubscription?.cancel();
    _channelSocket?.sink.close();
    _pollingTimer?.cancel();
    return super.close();
  }
}
