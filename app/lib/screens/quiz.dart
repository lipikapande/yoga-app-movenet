import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Which pose is best for back pain relief?',
      'options': ['Cobra Pose', 'Headstand', 'Warrior III', 'Crow Pose'],
      'answer': 0,
    },
    {
      'question': 'What is the ideal knee angle in Warrior II?',
      'options': ['45°', '90°', '120°', '180°'],
      'answer': 1,
    },
    {
      'question': 'Which pose improves balance?',
      'options': ['Child Pose', 'Tree Pose', 'Corpse Pose', 'Cobra Pose'],
      'answer': 1,
    },
  ];

  void answerQuestion(int selectedIndex) {
    if (selectedIndex == questions[currentQuestion]['answer']) {
      setState(() {
        score++;
      });
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Quiz Complete!'),
          content: Text('Your score: $score/${questions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  currentQuestion = 0;
                  score = 0;
                });
                Navigator.of(ctx).pop();
              },
              child: Text('Restart'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yoga Quiz'), backgroundColor: Colors.pink),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentQuestion + 1}/${questions.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              questions[currentQuestion]['question'],
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 30),
            ...List.generate(
              questions[currentQuestion]['options'].length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () => answerQuestion(index),
                  child: Text(questions[currentQuestion]['options'][index]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
