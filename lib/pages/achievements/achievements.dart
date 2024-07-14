import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Achievements extends StatefulWidget {
  Achievements({Key? key}) : super(key: key);

  @override
  _AchievementsState createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String username;
  List<dynamic> achievements = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getUsername();
    await fetchAchievements();
  }

  Future<void> _getUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      String temp = await getUsernameFromEmail(email) ?? 'Username not found';
      setState(() {
        username = temp;
      });
    } else {
      print('No user signed in');
    }
  }

  Future<String?> getUsernameFromEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  Future<void> fetchAchievements() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(username).get();
      if (userDoc.exists) {
        setState(() {
          achievements = userDoc.get('achievements') ?? [];
        });
        print('achievements: $achievements');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error retrieving document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: _firestore.collection('achievements').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // If there's no data, show a message
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No achievements found'));
            }

            // Build the list view with retrieved data
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var achievement = snapshot.data!.docs[index];
                return achievements[index]
                    ? UnlockedAchievementCard(
                        title: achievement['title'],
                        description: achievement['description'],
                        photoURL: achievement['photoURL'],
                      )
                    : LockedAchievementCard(
                        title: achievement['title'],
                        description: achievement['description'],
                      );
              },
            );
          },
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final String photoURL;
  final bool obtained;

  const AchievementCard({
    required this.title,
    required this.description,
    required this.photoURL,
    required this.obtained,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: obtained ? Color.fromARGB(255, 207, 235, 47) : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              color: Color.fromARGB(255, 240, 240, 240),
              child: Image.asset(photoURL),
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
                    style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 95, 95, 95)),
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

class UnlockedAchievementCard extends AchievementCard {
  const UnlockedAchievementCard({
    required super.title,
    required super.description,
    required super.photoURL,
  }) : super(
          obtained: true,
        );
}

class LockedAchievementCard extends AchievementCard {
  const LockedAchievementCard({
    required super.title,
    required super.description,
  }) : super(
          photoURL: 'assets/images/achievements/a0.jpeg',
          obtained: false,
        );
}