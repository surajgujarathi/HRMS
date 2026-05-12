import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // outer background
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children:  [
                    Icon(Icons.arrow_back_ios_new, size: 18),
                    SizedBox(width: 90),
                    Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 15),
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 10),
                      Text("Search", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// Filter Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _filterChip(context, "All", "24", true),
                    const SizedBox(width: 10),
                    _filterChip(context, "Unread", "15", false),
                    const Spacer(),
                    const Text(
                      "Mark all as read",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// Notifications List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Text(
                      "Today",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _notificationItem(
                      context: context,
                      icon: Icons.menu_book,
                      color: Colors.blue.shade100,
                      title: "New Course Material Available",
                      subtitle:
                          "Check out the latest lecture slides and resources",
                      time: "2 mins ago",
                    ),

                    _notificationItem(
                      context: context,
                      icon: Icons.assignment,
                      color: Colors.blue.shade100,
                      title: "Upcoming Assignment Deadline",
                      subtitle:
                          "Don't forget to submit your Biology assignment",
                      time: "30 mins ago",
                    ),

                    const SizedBox(height: 15),
                    Text(
                      "Yesterday",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _notificationItem(
                      context: context,
                      icon: Icons.campaign,
                      color: Colors.yellow.shade100,
                      title: "Important Announcement",
                      subtitle:
                          "Learnly is hosting a webinar on The dangers...",
                      time: "1 day ago",
                    ),

                    _notificationItem(
                      context: context,
                      icon: Icons.bookmark,
                      color: Colors.blue.shade50,
                      title: "Recommended Reading Material",
                      subtitle:
                          "Check out the latest lecture slides and resources",
                      time: "1 day ago",
                    ),

                    _notificationItem(
                      context: context,
                      icon: Icons.emoji_events,
                      color: Colors.red.shade100,
                      title: "You've Achieved a Milestone!",
                      subtitle:
                          "You've completed 80% of the Web Development course",
                      time: "1 day ago",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Filter Chip Widget
  Widget _filterChip(BuildContext context, String title, String count, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.blue : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 10,
                color: active ? Colors.blue : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Notification Item Widget
  Widget _notificationItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Column(
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Container(
                height: 6,
                width: 6,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
