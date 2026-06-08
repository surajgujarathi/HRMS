import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class PerformanceReviewPage extends StatelessWidget {
  PerformanceReviewPage({super.key});

  final String employeeName = "Praveen Kumar";
  final String role = "Marketing Manager";
  final String department = "Marketing";
  final String reviewPeriod = "Jan 2022 – Dec 2022";

  final List<Map<String, dynamic>> kpis = [
    {"title": "Communication Skills", "rating": 4.5, "progress": 0.9},
    {"title": "Teamwork", "rating": 4.5, "progress": 0.9},
    {"title": "Problem Solving", "rating": 4.5, "progress": 0.9},
    {"title": "Project Management", "rating": 4.0, "progress": 0.8},
    {"title": "Job Knowledge", "rating": 4.5, "progress": 0.8},
  ];

  final List<String> managerComments = [
    "Great leadership and consistently meets deadlines.",
    "Needs to improve analytics skills for projects.",
  ];

  final double overallRating = 4.5;
  final String goalsAchieved = "3 / 4 Completed";
  final List<String> improvementSuggestions = [
    "Advanced analytics training",
    "Enhance presentation skills",
  ];

  Widget buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (rating >= i) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
      } else if (rating > i - 1 && rating < i) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
      }
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.performance_review_title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/women/44.jpg',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employeeName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(role, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                            const SizedBox(height: 2),
                            Text(
                              "Dept: $department",
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Review: $reviewPeriod",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Performance Ratings
              Text(
                l10n.performance_ratings,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Column(
                children: kpis
                    .map(
                      (kpi) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kpi['title'], style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                            const SizedBox(height: 4),
                            buildStarRating(kpi['rating']),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: kpi['progress'],
                              color: Colors.blue,
                              backgroundColor: Colors.grey.shade300,
                              minHeight: 6,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),

              // Manager Comments
              Text(
                l10n.managers_comments,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: managerComments
                        .map(
                          (comment) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.comment, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(comment, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Review Summary
              Text(
                l10n.review_summary,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(l10n.overall_rating_label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                              const SizedBox(height: 4),
                              buildStarRating(overallRating),
                            ],
                          ),
                          Column(
                            children: [
                              Text(l10n.goals_achieved, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                              const SizedBox(height: 4),
                              Text(goalsAchieved, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: improvementSuggestions
                            .map(
                              (s) => Row(
                                children: [
                                  const Icon(Icons.check, size: 16),
                                  const SizedBox(width: 4),
                                  Text(s, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons wrapped in SafeArea + SingleChildScrollView avoids overflow
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: Text(l10n.previous_reviews),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: Text(l10n.download_pdf),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(l10n.submit_review),
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
}
