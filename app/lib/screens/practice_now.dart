import 'package:flutter/material.dart';

class PracticeNowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Now'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Start Webcam Practice',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Connect to your Python backend here',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Connect to Flask/FastAPI backend
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Starting pose detection...')),
                );
              },
              icon: Icon(Icons.play_arrow),
              label: Text('Start Detection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
