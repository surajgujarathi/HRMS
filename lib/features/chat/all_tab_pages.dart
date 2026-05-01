import 'package:flutter/material.dart';

class UnreadPage extends StatelessWidget {
  const UnreadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Unread")),
      body: const Center(
        child: Text("Unread Chats", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: const Center(
        child: Text("Favorite Chats", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Groups")),
      body: const Center(
        child: Text("Group Chats", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class AllPage extends StatelessWidget {
  const AllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All")),
      body: const Center(
        child: Text("All Chats", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
