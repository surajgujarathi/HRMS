import 'package:flutter/material.dart';
import 'package:flutter_app/routes.dart';

class FeatureSearchDelegate extends SearchDelegate<String?> {
  final List<Map<String, dynamic>> features = [
    // {'title': 'Leave', 'route': Routes.leaveList, 'icon': Icons.calendar_today},
    {'title': 'My Pay', 'route': Routes.myPay, 'icon': Icons.payment},
    {'title': 'Profile', 'route': Routes.personalinf, 'icon': Icons.person},
    {'title': 'Attendance Report', 'route': Routes.inOutReport, 'icon': Icons.access_time},
    {'title': 'Company Calendar', 'route': Routes.companyCalendar, 'icon': Icons.event},
    {'title': 'Chat Bot', 'route': Routes.aichatbot, 'icon': Icons.chat},
    {'title': 'Documents', 'route': Routes.docbox, 'icon': Icons.folder},
    {'title': 'Job Details', 'route': Routes.jobdetails, 'icon': Icons.work},
    {'title': 'Notifications', 'route': Routes.notifications, 'icon': Icons.notifications},
    {'title': 'Events', 'route': Routes.events, 'icon': Icons.event_available},
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final suggestions = query.isEmpty
        ? features
        : features.where((feature) {
            return feature['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final feature = suggestions[index];
        return ListTile(
          leading: Icon(feature['icon'] as IconData, color: Theme.of(context).primaryColor),
          title: Text(feature['title'] as String),
          onTap: () {
            close(context, feature['title'] as String);
            Navigator.pushNamed(context, feature['route'] as String);
          },
        );
      },
    );
  }
}
