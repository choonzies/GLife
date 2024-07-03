import 'package:flutter/material.dart';

class Achievements extends StatelessWidget {
  const Achievements({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            AchievementCard(
              title: '10 000 Steps!',
              description: 'You walked 10 000 steps in a day!',
            ),
            SizedBox(height: 16),
            AchievementCard(
              title: 'Master of Streaks',
              description: 'Achieved a 7-day streak!',
            ),
            SizedBox(height: 16),
            // Add more AchievementCard widgets as needed
          ],
        ),
      ),
    );
  }
}
  class AchievementCard extends StatelessWidget {
  final String title;
  final String description;

  const AchievementCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              color: Colors.grey[300], // Placeholder color
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}