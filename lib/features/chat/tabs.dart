import 'package:flutter/material.dart';
import 'package:flutter_app/features/chat/all_tab_pages.dart';

class FilterTabsPage extends StatelessWidget {
  const FilterTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tabs = [
      {"title": "All", "page": const AllPage()},
      {"title": "Unread", "page": const UnreadPage()},
      {"title": "Teams", "page": const FavoritesPage()},
      {"title": "Managers", "page": const GroupsPage()},
    ];

    return SizedBox(
      height: 35, // smaller overall height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => tabs[index]["page"]),
              );
            },
            child: Container(
              height: 38, // reduced tab height
              width: 80, // reduced tab width
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200, // light grey background
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(2, 2), // shadow direction
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  tabs[index]["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
