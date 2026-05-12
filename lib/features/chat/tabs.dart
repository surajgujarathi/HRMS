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
                color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  tabs[index]["title"],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
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
