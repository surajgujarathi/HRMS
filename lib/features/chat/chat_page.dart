import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';

class TeamChatPage extends StatefulWidget {
  final String teamId;
  final String teamTitle;

  const TeamChatPage({
    super.key,
    required this.teamId,
    required this.teamTitle,
  });

  @override
  State<TeamChatPage> createState() => _TeamChatPageState();
}

class _TeamChatPageState extends State<TeamChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      'text': "Hi! I'm interested in your property. is it still available",
      'isMe': true,
      'time': "12:43 PM",
    },
    {
      'text': "Yes, it's still available! would you like to schedule a viewing",
      'isMe': false,
    },
    {'text': "Can you meeting with tomorrow?", 'isMe': false},
    {
      'text': "Please let me know when you're available.",
      'isMe': false,
      'time': "1:50 AM",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.teamTitle,
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Typing...",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).cardTheme.color?.withOpacity(0.5) ?? Colors.grey.shade200,
            child: Icon(Icons.videocam, size: 18, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).cardTheme.color?.withOpacity(0.5) ?? Colors.grey.shade200,
            child: Icon(Icons.call, size: 18, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(width: 10),
        ],
      ),

      // ---------------- BODY ----------------
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Today, Jun 14",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                ...messages.map((msg) => _chatBubble(msg)).toList(),
              ],
            ),
          ),

          _chatInput(),
        ],
      ),
    );
  }

  // ---------------- CHAT BUBBLE ----------------
  Widget _chatBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isMe 
                  ? AppColors.primaryPurple 
                  : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg['text'],
              style: TextStyle(
                color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (msg['time'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                msg['time'],
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- INPUT FIELD ----------------
  Widget _chatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_emotions_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Message",
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryPurple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                if (_messageController.text.isEmpty) return;

                setState(() {
                  messages.add({'text': _messageController.text, 'isMe': true});
                });

                _messageController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}
