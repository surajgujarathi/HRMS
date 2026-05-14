import 'package:equatable/equatable.dart';
import '../models/chat_model.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatChannel> channels;
  final List<ChatChannel> directMessages;
  final List<ChatMessage> activeMessages;
  final String? errorMessage;
  final String? currentChatId;

  const ChatState({
    this.status = ChatStatus.initial,
    this.channels = const [],
    this.directMessages = const [],
    this.activeMessages = const [],
    this.errorMessage,
    this.currentChatId,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatChannel>? channels,
    List<ChatChannel>? directMessages,
    List<ChatMessage>? activeMessages,
    String? errorMessage,
    String? currentChatId,
  }) {
    return ChatState(
      status: status ?? this.status,
      channels: channels ?? this.channels,
      directMessages: directMessages ?? this.directMessages,
      activeMessages: activeMessages ?? this.activeMessages,
      errorMessage: errorMessage ?? this.errorMessage,
      currentChatId: currentChatId ?? this.currentChatId,
    );
  }

  @override
  List<Object?> get props => [status, channels, directMessages, activeMessages, errorMessage, currentChatId];
}
