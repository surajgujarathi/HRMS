import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFFF5F5F5),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.teamTitle,
              style: const TextStyle(
                color: Colors.black,
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
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.videocam, size: 18, color: Colors.black),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.call, size: 18, color: Colors.black),
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
          // SizedBox(height: 50),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(msg['text']),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
      decoration: const BoxDecoration(
        // color: Colors.white,
        // border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Message",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
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
