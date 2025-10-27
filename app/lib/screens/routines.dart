import 'package:flutter/material.dart';

class RoutinesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Routines'), backgroundColor: Colors.orange),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          RoutineCard(
            title: 'Morning Energy Flow',
            duration: '15 min',
            poses: 8,
            color: Colors.orange,
          ),
          RoutineCard(
            title: 'Evening Relaxation',
            duration: '20 min',
            poses: 10,
            color: Colors.blue,
          ),
          RoutineCard(
            title: 'Core Strengthening',
            duration: '25 min',
            poses: 12,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class RoutineCard extends StatelessWidget {
  final String title;
  final String duration;
  final int poses;
  final Color color;

  RoutineCard({
    required this.title,
    required this.duration,
    required this.poses,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(duration, style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Icon(Icons.self_improvement, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('$poses poses', style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: Text('Start Routine'),
              style: ElevatedButton.styleFrom(backgroundColor: color),
            ),
          ],
        ),
      ),
    );
  }
}
