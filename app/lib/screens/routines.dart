import 'package:flutter/material.dart';

class RoutinesPage extends StatelessWidget {
  // Define the 3 routines with exact poses
  final List<Map<String, dynamic>> routines = [
    {
      'title': 'Surya Namaskar (Sun Salutation)',
      'duration': '10 min',
      'difficulty': 'Beginner',
      'color': Colors.orange,
      'poses': [
        'tadasana',
        'urdhva hastasana',
        'uttanasana',
        'utthita ashwa sanchalanasana',
        'phalakasana',
        'ashtanga namaskara',
        'bhujangasana',
        'adho mukha svanasana',
        'utthita ashwa sanchalanasana',
        'uttanasana',
        'urdhva hastasana',
        'tadasana',
      ],
    },
    {
      'title': 'Beginner Flow',
      'duration': '12 min',
      'difficulty': 'Beginner',
      'color': Colors.blue,
      'poses': [
        'tadasana',
        'urdhva hastasana',
        'uttanasana',
        'marjaryasana',
        'bitilasana',
        'balasana',
        'adho mukha svanasana',
        'bhujangasana',
        'savasana',
      ],
    },
    {
      'title': 'Intermediate Strength',
      'duration': '18 min',
      'difficulty': 'Intermediate',
      'color': Colors.green,
      'poses': [
        'utthita ashwa sanchalanasana',
        'anjaneyasana',
        'phalakasana',
        'chaturanga dandasana',
        'urdhva mukha svanasana',
        'virabhadrasana i',
        'virabhadrasana ii',
        'utthita trikonasana',
        'utkatasana',
        'setu bandha sarvangasana',
      ],
    },
  ];

  // Pose name mappings for display
  final Map<String, String> poseDisplayNames = {
    'tadasana': 'Tadasana (Mountain Pose)',
    'urdhva hastasana': 'Urdhva Hastasana (Upward Salute)',
    'uttanasana': 'Uttanasana (Forward Fold)',
    'utthita ashwa sanchalanasana': 'Utthita Ashwa Sanchalanasana (High Lunge)',
    'anjaneyasana': 'Anjaneyasana (Low Lunge)',
    'phalakasana': 'Phalakasana (Plank Pose)',
    'ashtanga namaskara': 'Ashtanga Namaskara (Eight-Limbed Pose)',
    'bhujangasana': 'Bhujangasana (Cobra Pose)',
    'adho mukha svanasana': 'Adho Mukha Svanasana (Downward Dog)',
    'marjaryasana': 'Marjaryasana (Cat Pose)',
    'bitilasana': 'Bitilasana (Cow Pose)',
    'balasana': 'Balasana (Child\'s Pose)',
    'savasana': 'Savasana (Corpse Pose)',
    'chaturanga dandasana': 'Chaturanga Dandasana (Four-Limbed Staff)',
    'urdhva mukha svanasana': 'Urdhva Mukha Svanasana (Upward Dog)',
    'virabhadrasana i': 'Virabhadrasana I (Warrior I)',
    'virabhadrasana ii': 'Virabhadrasana II (Warrior II)',
    'utthita trikonasana': 'Utthita Trikonasana (Triangle Pose)',
    'utkatasana': 'Utkatasana (Chair Pose)',
    'setu bandha sarvangasana': 'Setu Bandha Sarvangasana (Bridge Pose)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yoga Routines'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return RoutineCard(
            title: routine['title'],
            difficulty: routine['difficulty'],
            poseCount: routine['poses'].length,
            color: routine['color'],
            onTap: () {
              // Navigate to routine carousel
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoutineCarouselPage(
                    routine: routine,
                    poseDisplayNames: poseDisplayNames,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RoutineCard extends StatelessWidget {
  final String title;
  final String difficulty;
  final int poseCount;
  final Color color;
  final VoidCallback onTap;

  RoutineCard({
    required this.title,
    required this.difficulty,
    required this.poseCount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
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
                  Icon(Icons.self_improvement, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '$poseCount poses',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.star, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(difficulty, style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: onTap,
                child: Text('View Routine'),
                style: ElevatedButton.styleFrom(backgroundColor: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New Carousel Page
class RoutineCarouselPage extends StatefulWidget {
  final Map<String, dynamic> routine;
  final Map<String, String> poseDisplayNames;

  RoutineCarouselPage({required this.routine, required this.poseDisplayNames});

  @override
  _RoutineCarouselPageState createState() => _RoutineCarouselPageState();
}

class _RoutineCarouselPageState extends State<RoutineCarouselPage> {
  late PageController _pageController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poses = widget.routine['poses'] as List<String>;
    final totalSteps = poses.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine['title']),
        backgroundColor: widget.routine['color'],
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            padding: EdgeInsets.all(16),
            color: widget.routine['color'].withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${_currentStep + 1} of $totalSteps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.routine['color'],
                  ),
                ),
                Text(
                  '${((_currentStep + 1) / totalSteps * 100).toInt()}%',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / totalSteps,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(widget.routine['color']),
            minHeight: 6,
          ),

          // Carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemCount: totalSteps,
              itemBuilder: (context, index) {
                final poseName = poses[index];
                final displayName =
                    widget.poseDisplayNames[poseName] ?? poseName;
                final imagePath = 'assets/pose_library/$poseName.png';

                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Step number badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.routine['color'],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'STEP ${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Pose name
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),

                      // Pose image
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Image not found',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Swipe hint
                      Text(
                        '← Swipe to navigate →',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentStep > 0
                      ? () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: Icon(Icons.arrow_back),
                  label: Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.routine['color'],
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _currentStep < totalSteps - 1
                      ? () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : () {
                          // Finished
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('🎉 Routine Complete!'),
                              content: Text(
                                'Great job completing ${widget.routine['title']}!',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Done'),
                                ),
                              ],
                            ),
                          );
                        },
                  icon: Icon(
                    _currentStep < totalSteps - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                  ),
                  label: Text(
                    _currentStep < totalSteps - 1 ? 'Next' : 'Finish',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.routine['color'],
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
