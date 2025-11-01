import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PracticeNowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Now', style: TextStyle(color: Colors.white)),
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
              onPressed: () async {
                final uri = Uri.parse('http://127.0.0.1:8000/start-detection');
                try {
                  final response = await http
                      .get(uri)
                      .timeout(Duration(seconds: 5));
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Starting pose detection...')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Server error: ${response.statusCode}'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to reach server: $e')),
                  );
                }
              },
              icon: Icon(Icons.play_arrow),
              label: Text(
                'Start Detection',
                style: TextStyle(color: Colors.white),
              ),
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
