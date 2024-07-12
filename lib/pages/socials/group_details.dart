import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glife/pages/socials/user_details.dart';

class GroupDetails extends StatefulWidget {
  final String groupName;
  final String username;

  const GroupDetails(this.groupName, this.username, {super.key});

  @override
  State<GroupDetails> createState() => _GroupDetailsState(groupName, username);
}

class _GroupDetailsState extends State<GroupDetails> {
  String groupName;
  String username;

  _GroupDetailsState(this.groupName, this.username);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<dynamic> members = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('groups').doc(groupName).get();
      if (userDoc.exists) {
        setState(() {
          members = userDoc.get('members') ?? [];
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error retrieving document: $e');
    }
  }

  String getPhoto() {
    return 'assets/images/emptyprofile.jpeg';
  }

  String getDescription() {
    return 'Let\'s get fit together! Join us!';
  }

  int getHighestStreaks() {
    return 45;
  }

  int getGoodNights() {
    return 258;
  }

  int getSteps() {
    return 200000;
  }

  int getWorkoutHours() {
    return 67;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4B39EF), Color(0xFFEE8B60)],
                    stops: [0, 1],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(getPhoto()),
                ),
              ),
              SizedBox(height: 10),
              Text(
                groupName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Join/leave grp buttons to implement (next time)',
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              Text(
                getDescription(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(0, -1),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Members',
                          style: TextStyle(
                            color: Color(0xFF101213),
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            String member = members[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UserDetails(member))
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F4F8),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  member,
                                  style: TextStyle(
                                    color: Color(0xFF101213),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            );
                          },
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}