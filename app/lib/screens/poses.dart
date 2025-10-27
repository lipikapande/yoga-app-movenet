import 'package:flutter/material.dart';

class PosesPage extends StatelessWidget {
  final List<Map<String, String>> poses = [
    {'name': 'Downward Dog', 'difficulty': 'Beginner'},
    {'name': 'Warrior I', 'difficulty': 'Beginner'},
    {'name': 'Warrior II', 'difficulty': 'Beginner'},
    {'name': 'Tree Pose', 'difficulty': 'Intermediate'},
    {'name': 'Cobra Pose', 'difficulty': 'Beginner'},
    {'name': 'Child\'s Pose', 'difficulty': 'Beginner'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poses Library (40 Poses)'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: poses.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.self_improvement, color: Colors.white),
              ),
              title: Text(
                poses[index]['name']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(poses[index]['difficulty']!),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Show pose details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('View ${poses[index]['name']} details'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
