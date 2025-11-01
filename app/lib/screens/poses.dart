// import 'package:flutter/material.dart';

// class PosesPage extends StatelessWidget {
//   final List<Map<String, String>> poses = [
//     {'name': 'Downward Dog', 'difficulty': 'Beginner'},
//     {'name': 'Warrior I', 'difficulty': 'Beginner'},
//     {'name': 'Warrior II', 'difficulty': 'Beginner'},
//     {'name': 'Tree Pose', 'difficulty': 'Intermediate'},
//     {'name': 'Cobra Pose', 'difficulty': 'Beginner'},
//     {'name': 'Child\'s Pose', 'difficulty': 'Beginner'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Poses Library (40 Poses)'),
//         backgroundColor: Colors.teal,
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: poses.length,
//         itemBuilder: (context, index) {
//           return Card(
//             margin: EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: Colors.teal,
//                 child: Icon(Icons.self_improvement, color: Colors.white),
//               ),
//               title: Text(
//                 poses[index]['name']!,
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(poses[index]['difficulty']!),
//               trailing: Icon(Icons.arrow_forward_ios),
//               onTap: () {
//                 // TODO: Show pose details
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('View ${poses[index]['name']} details'),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class PosesPage extends StatelessWidget {
  final List<Map<String, String>> poses = [
    // Standing poses
    {
      'name': 'Tadasana',
      'display': 'Tadasana (Mountain Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Uttanasana',
      'display': 'Uttanasana (Forward Fold)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Ardha Uttanasana',
      'display': 'Ardha Uttanasana (Half Forward Fold)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Utthita Ashwa Sanchalanasana',
      'display': 'Utthita Ashwa Sanchalanasana (High Lunge)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Anjaneyasana',
      'display': 'Anjaneyasana (Low Lunge)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Urdhva Hastasana',
      'display': 'Urdhva Hastasana (Upward Salute)',
      'difficulty': 'Beginner',
    },

    // Core Surya Namaskar poses
    {
      'name': 'Adho Mukha Svanasana',
      'display': 'Adho Mukha Svanasana (Downward Dog)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Urdhva Mukha Svanasana',
      'display': 'Urdhva Mukha Svanasana (Upward Dog)',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Chaturanga Dandasana',
      'display': 'Chaturanga Dandasana (Four-Limbed Staff)',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Phalakasana',
      'display': 'Phalakasana (Plank Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Bhujangasana',
      'display': 'Bhujangasana (Cobra Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Ashtanga Namaskara',
      'display': 'Ashtanga Namaskara (Eight-Limbed Pose)',
      'difficulty': 'Beginner',
    },

    // Warriors & Standing
    {
      'name': 'Virabhadrasana I',
      'display': 'Virabhadrasana I (Warrior I)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Virabhadrasana II',
      'display': 'Virabhadrasana II (Warrior II)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Utthita Trikonasana',
      'display': 'Utthita Trikonasana (Triangle Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Utthita Parsvakonasana',
      'display': 'Utthita Parsvakonasana (Extended Side Angle)',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Vriksasana',
      'display': 'Vriksasana (Tree Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Ardha Chandrasana',
      'display': 'Ardha Chandrasana (Half Moon Pose)',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Garudasana',
      'display': 'Garudasana (Eagle Pose)',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Utkatasana',
      'display': 'Utkatasana (Chair Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Prasarita Padottanasana',
      'display': 'Prasarita Padottanasana (Wide-Legged Forward Fold)',
      'difficulty': 'Beginner',
    },

    // Forward Bends & Seated
    {
      'name': 'Paschimottanasana',
      'display': 'Paschimottanasana (Seated Forward Bend)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Dandasana',
      'display': 'Dandasana (Staff Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Sukhasana',
      'display': 'Sukhasana (Easy Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Padmasana',
      'display': 'Padmasana (Lotus Pose)',
      'difficulty': 'Advanced',
    },
    {
      'name': 'Baddha Konasana',
      'display': 'Baddha Konasana (Butterfly Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Janu Sirsasana',
      'display': 'Janu Sirsasana (Head-to-Knee Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Malasana',
      'display': 'Malasana (Garland Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Ardha Matsyendrasana',
      'display': 'Ardha Matsyendrasana (Half Lord of Fishes)',
      'difficulty': 'Intermediate',
    },

    // Backbends
    {
      'name': 'Setu Bandha Sarvangasana',
      'display': 'Setu Bandha Sarvangasana (Bridge Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Dhanurasana',
      'display': 'Dhanurasana (Bow Pose)',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Ustrasana',
      'display': 'Ustrasana (Camel Pose)',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Matsyasana',
      'display': 'Matsyasana (Fish Pose)',
      'difficulty': 'Beginner',
    },

    // Hip Openers
    {
      'name': 'Eka Pada Rajakapotasana',
      'display': 'Eka Pada Rajakapotasana (Pigeon Pose)',
      'difficulty': 'Intermediate',
    },

    // Restorative & Gentle
    {
      'name': 'Balasana',
      'display': 'Balasana (Child\'s Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Savasana',
      'display': 'Savasana (Corpse Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Marjaryasana',
      'display': 'Marjaryasana (Cat Pose)',
      'difficulty': 'Beginner',
    },
    {
      'name': 'Bitilasana',
      'display': 'Bitilasana (Cow Pose)',
      'difficulty': 'Beginner',
    },

    // Core & Arm Balance
    {
      'name': 'Vasisthasana',
      'display': 'Vasisthasana (Side Plank)',
      'difficulty': 'Intermediate',
    },
    {
      'name': 'Salabhasana',
      'display': 'Salabhasana (Locust Pose)',
      'difficulty': 'Beginner',
    },
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
                poses[index]['display']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(poses[index]['difficulty']!),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Show pose image in a dialog
                _showPoseDialog(context, poses[index]);
              },
            ),
          );
        },
      ),
    );
  }

  void _showPoseDialog(BuildContext context, Map<String, String> pose) {
    String imagePath = 'assets/pose_library/${pose['name']!.toLowerCase()}.png';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pose['display']!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Difficulty: ${pose['difficulty']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    height: 400, // Increased height
                    width: double.infinity,
                    fit: BoxFit.contain, // Changed from cover to contain
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 400,
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
                            Text(
                              imagePath,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
