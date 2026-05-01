import 'package:flutter/material.dart';
import 'package:flutter_app/features/chat/chat_page.dart';

class TeamHorizontalList extends StatelessWidget {
  const TeamHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    final teams = [
      {
        'id': 'e1',
        'name': 'Sales',
        'count': 12,
        'image': 'https://randomuser.me/api/portraits/men/1.jpg',
      },
      {
        'id': 'e2',
        'name': 'Finance',
        'count': 5,
        'image': 'https://randomuser.me/api/portraits/men/2.jpg',
      },
      {
        'id': 'e3',
        'name': 'Dev',
        'count': 4,
        'image': 'https://randomuser.me/api/portraits/men/3.jpg',
      },
      {
        'id': 'e4',
        'name': 'TA',
        'count': 6,
        'image': 'https://randomuser.me/api/portraits/men/4.jpg',
      },
      {
        'id': 'e1',
        'name': 'IT support',
        'count': 3,
        'image': 'https://randomuser.me/api/portraits/men/1.jpg',
      },
      {
        'id': 'e3',
        'name': 'HR & Admin',
        'count': 7,
        'image': 'https://randomuser.me/api/portraits/men/3.jpg',
      },
      {
        'id': 'e4',
        'name': 'Marketing',
        'count': 7,
        'image': 'https://randomuser.me/api/portraits/men/4.jpg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Teams Hub',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          // margin: const EdgeInsets.symmetric(horizontal: 12),
          // padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // ✅ fixed
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: teams.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final team = teams[index];

                return _TeamCard(
                  name: team['name'] as String,
                  count: team['count'] as int,
                  imageUrl: team['image'] as String,
                  onTap: () {
                    _openTeam(
                      context,
                      team['name'] as String,
                      team['id'] as String,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _openTeam(BuildContext context, String name, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamChatPage(teamId: id, teamTitle: name),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String name;
  final int count;
  final String imageUrl;
  final VoidCallback onTap;

  const _TeamCard({
    required this.name,
    required this.count,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Avatar with count badge
          Stack(
            children: [
              CircleAvatar(radius: 32, backgroundImage: NetworkImage(imageUrl)),
              Positioned(
                right: -2,
                top: -2,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blue,
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            '$count members',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
