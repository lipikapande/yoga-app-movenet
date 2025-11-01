import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  int? selectedAnswer;
  bool hasAnswered = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Which pose is known as the "King of Asanas"?',
      'options': [
        'Headstand (Sirsasana)',
        'Lotus Pose (Padmasana)',
        'Warrior I',
        'Tree Pose',
      ],
      'answer': 0,
    },
    {
      'question':
          'What is the ideal knee angle in Warrior II (Virabhadrasana II)?',
      'options': ['45°', '90°', '120°', '180°'],
      'answer': 1,
    },
    {
      'question': 'Which pose is best for improving balance?',
      'options': ["Child's Pose", 'Tree Pose', 'Corpse Pose', 'Cobra Pose'],
      'answer': 1,
    },
    {
      'question': 'What does "Surya Namaskar" mean?',
      'options': [
        'Moon Salutation',
        'Sun Salutation',
        'Star Salutation',
        'Earth Salutation',
      ],
      'answer': 1,
    },
    {
      'question': 'Which pose is a resting pose often used between sequences?',
      'options': [
        'Warrior I',
        'Plank Pose',
        'Child\'s Pose (Balasana)',
        'Chair Pose',
      ],
      'answer': 2,
    },
    {
      'question': 'What is the Sanskrit name for Corpse Pose?',
      'options': ['Shavasana', 'Tadasana', 'Savasana', 'Sukhasana'],
      'answer': 0,
    },
    {
      'question': 'Which pose strengthens the core and arms?',
      'options': [
        'Forward Fold',
        'Plank Pose (Phalakasana)',
        'Seated Twist',
        'Butterfly Pose',
      ],
      'answer': 1,
    },
    {
      'question': 'Downward Dog is known in Sanskrit as:',
      'options': [
        'Adho Mukha Svanasana',
        'Urdhva Mukha Svanasana',
        'Bhujangasana',
        'Marjaryasana',
      ],
      'answer': 0,
    },
    {
      'question': 'Which pose helps relieve back pain?',
      'options': [
        'Headstand',
        'Cobra Pose (Bhujangasana)',
        'Crow Pose',
        'Eagle Pose',
      ],
      'answer': 1,
    },
    {
      'question': 'What is the purpose of Savasana at the end of practice?',
      'options': [
        'Build strength',
        'Improve flexibility',
        'Relaxation and integration',
        'Burn calories',
      ],
      'answer': 2,
    },
  ];

  void answerQuestion(int selectedIndex) {
    if (hasAnswered) return;

    setState(() {
      selectedAnswer = selectedIndex;
      hasAnswered = true;
      if (selectedIndex == questions[currentQuestion]['answer']) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        hasAnswered = false;
      });
    } else {
      showResultDialog();
    }
  }

  void showResultDialog() {
    String resultMessage;
    String emoji;

    if (score >= 9) {
      resultMessage = "Perfect! You're a yoga master! 🏆";
      emoji = "🧘‍♀️✨";
    } else if (score >= 7) {
      resultMessage = "Great job! You know your yoga well!";
      emoji = "🎉";
    } else if (score >= 5) {
      resultMessage = "Good effort! Keep practicing!";
      emoji = "💪";
    } else {
      resultMessage = "Keep learning! Practice makes perfect!";
      emoji = "📚";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Quiz Complete! $emoji', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score / ${questions.length}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            SizedBox(height: 10),
            Text(
              resultMessage,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentQuestion = 0;
                score = 0;
                selectedAnswer = null;
                hasAnswered = false;
              });
              Navigator.of(ctx).pop();
            },
            child: Text('Restart Quiz', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color getOptionColor(int index) {
    int correctAnswer = questions[currentQuestion]['answer'];

    // before answering, show neutral light background
    if (!hasAnswered) return Colors.grey.shade200;

    // after answering:
    if (index == correctAnswer) {
      return Colors.green.shade600; // correct -> green
    }

    if (selectedAnswer != null &&
        index == selectedAnswer &&
        selectedAnswer != correctAnswer) {
      return Colors.red.shade600; // selected & wrong -> red
    }

    return Colors.grey.shade300; // others -> neutral
  }

  Color getOptionTextColor(int index) {
    if (!hasAnswered) return Colors.black87;

    int correctAnswer = questions[currentQuestion]['answer'];

    if (index == correctAnswer) return Colors.white;
    if (selectedAnswer != null &&
        index == selectedAnswer &&
        selectedAnswer != correctAnswer)
      return Colors.white;

    return Colors.black87;
  }

  IconData? getOptionIcon(int index) {
    if (!hasAnswered) return null;

    int correctAnswer = questions[currentQuestion]['answer'];

    if (index == correctAnswer) return Icons.check_circle;
    if (selectedAnswer != null &&
        index == selectedAnswer &&
        selectedAnswer != correctAnswer)
      return Icons.cancel;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double progress = (currentQuestion + 1) / questions.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Yoga Quiz'),
        backgroundColor: Colors.pink.shade600,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top progress area
          Container(
            color: Colors.pink.shade600,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentQuestion + 1}/${questions.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Score: $score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.pink.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.pink.shade50,
                  ),
                  minHeight: 6,
                ),
              ],
            ),
          ),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        questions[currentQuestion]['question'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Options - NO AnimatedContainer wrapping the button
                  ...List.generate(questions[currentQuestion]['options'].length, (
                    index,
                  ) {
                    final bg = getOptionColor(index);
                    final textColor = getOptionTextColor(index);
                    final icon = getOptionIcon(index);

                    return Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: ElevatedButton(
                        onPressed: hasAnswered
                            ? null
                            : () => answerQuestion(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bg,
                          padding: EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: hasAnswered ? 0 : 2,
                          // Do not set foregroundColor here because we manually set text/icon colors
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasAnswered
                                    ? (index ==
                                              questions[currentQuestion]['answer']
                                          ? Colors.green.shade700
                                          : (selectedAnswer != null &&
                                                    index == selectedAnswer &&
                                                    selectedAnswer !=
                                                        questions[currentQuestion]['answer']
                                                ? Colors.red.shade700
                                                : Colors.white))
                                    : Colors.white,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: hasAnswered
                                        ? (index ==
                                                      questions[currentQuestion]['answer'] ||
                                                  (selectedAnswer != null &&
                                                      index == selectedAnswer &&
                                                      selectedAnswer !=
                                                          questions[currentQuestion]['answer']))
                                              ? Colors.white
                                              : Colors.black87
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                questions[currentQuestion]['options'][index],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (icon != null) Icon(icon, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Next button appears only after answering
                  SizedBox(height: 8),
                  if (hasAnswered)
                    ElevatedButton(
                      onPressed: nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade600,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        currentQuestion < questions.length - 1
                            ? 'Next Question →'
                            : 'View Results',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
