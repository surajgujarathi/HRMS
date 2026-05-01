import 'package:flutter/material.dart';
import 'package:flutter_app/features/chat/chat_page.dart';
import 'package:flutter_app/features/chat/tabs.dart';

class TeamVerticalList extends StatefulWidget {
  const TeamVerticalList({super.key});

  @override
  State<TeamVerticalList> createState() => _TeamVerticalListState();
}

class _TeamVerticalListState extends State<TeamVerticalList> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> filters = ["All", "Unread", "Teams", "Managers"];

    final employees = [
      {
        'id': 'e1',
        'name': 'Likitha Reddicherla',
        'role': 'HR Generalist',
        'image': 'https://randomuser.me/api/portraits/men/1.jpg',
        'lastMessage': 'Please review the policy',
        'time': '10:45 AM',
        'unread': 2,
      },
      {
        'id': 'e2',
        'name': 'Praveen Kumar Thalapaneni',
        'role': 'IT Executive',
        'image': 'https://randomuser.me/api/portraits/men/2.jpg',
        'lastMessage': 'Build completed 👍',
        'time': '09:30 AM',
        'unread': 0,
      },
      {
        'id': 'e3',
        'name': 'Shankar Ankepaka',
        'role': 'Flutter Developer',
        'image': 'https://randomuser.me/api/portraits/men/3.jpg',
        'lastMessage': 'Invoice sent',
        'time': 'Yesterday',
        'unread': 5,
      },
      {
        'id': 'e4',
        'name': 'Siddhartha Bhandari',
        'role': 'Functional Consultant',
        'image': 'https://randomuser.me/api/portraits/men/4.jpg',
        'lastMessage': 'Client meeting at 4',
        'time': 'Yesterday',
        'unread': 1,
      },
      {
        'id': 'e4',
        'name': 'Vishnu Madanambeti',
        'role': 'Testing Engineer',
        'image': 'https://randomuser.me/api/portraits/men/3.jpg',
        'lastMessage': 'Technical issue',
        'time': 'Yesterday',
        'unread': 1,
      },
      {
        'id': 'e1',
        'name': 'Karuna Bonthala',
        'role': 'Jr Software Engineer',
        'image': 'https://randomuser.me/api/portraits/men/1.jpg',
        'lastMessage': 'Please review the policy',
        'time': '10:45 AM',
        'unread': 10,
      },
      {
        'id': 'e2',
        'name': 'Pranay Sai Durga Gadi',
        'role': 'Odoo Developer',
        'image': 'https://randomuser.me/api/portraits/men/2.jpg',
        'lastMessage': 'Build completed ',
        'time': '09:30 AM',
        'unread': 0,
      },
      {
        'id': 'e2',
        'name': 'Raman Marikanti',
        'role': 'Odoo Developer',
        'image': 'https://randomuser.me/api/portraits/men/2.jpg',
        'lastMessage': 'Build completed ',
        'time': '09:30 AM',
        'unread': 0,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            'People Connect',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(filters.length, (index) {
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Divider(color: Colors.grey.shade100),
        // const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: employees.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final emp = employees[index];

            return _EmployeeCard(
              name: emp['name'] as String,

              role: emp['role'] as String,
              imageUrl: emp['image'] as String,
              lastMessage: emp['lastMessage'] as String,
              time: emp['time'] as String,
              unreadCount: emp['unread'] as int,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamChatPage(
                      teamId: emp['id'] as String,
                      teamTitle: emp['name'] as String,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final VoidCallback onTap;

  const _EmployeeCard({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          CircleAvatar(radius: 26, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 14),

          /// Name + Last Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(width: 4),

                /// Department / Role
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          /// Time + Unread badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 6),
              if (unreadCount > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blue,
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
