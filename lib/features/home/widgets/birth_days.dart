import 'package:flutter/material.dart';

class BirthdaySection extends StatelessWidget {
  final String title;
  final IconData? trailing;

  const BirthdaySection({
    super.key,
    this.title = 'Upcoming Birthdays',
    this.trailing = Icons.calendar_month,
  });

  /// Built-in birthday data
  List<Map<String, dynamic>> get _birthdays => [
    {
      'name': 'Kristin Watson',
      'date': DateTime.now(),
      'imageUrl': 'https://i.pravatar.cc/150?img=5',
    },

    {
      'name': 'Cameron Williamson',
      'date': DateTime.now().add(const Duration(days: 3)),
      'imageUrl': 'https://i.pravatar.cc/150?img=7',
    },
  ];

  /// Function to get friendly text like "Today", "Tomorrow", or date
  String _getDayText(DateTime date) {
    final now = DateTime.now();
    final birthdayThisYear = DateTime(now.year, date.month, date.day);
    final difference = birthdayThisYear
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    return '${date.day}-${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 5),
              const Text('🎂 ', style: TextStyle(fontSize: 16)),

              const Spacer(),
              if (trailing != null)
                Icon(trailing, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ],
          ),
          const SizedBox(height: 12),
          // Birthday List
          Column(
            children: _birthdays.map((b) {
              final name = b['name'] as String;
              final date = b['date'] as DateTime;
              final imageUrl = b['imageUrl'] as String?;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        imageUrl ?? 'https://i.pravatar.cc/150?img=8',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                    Text(
                      _getDayText(date),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
