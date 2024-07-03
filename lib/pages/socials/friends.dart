import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<dynamic> friends = [];
  List<dynamic> filteredFriends = [];

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc('qwerty').get();
      if (userDoc != null && userDoc!.exists) {
        setState(() {
          friends = userDoc!.get('friends') ?? [];
          filteredFriends.addAll(friends);
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error retrieving document: $e');
    }
  }

  

  @override
  void initState() {
    super.initState();
    fetchUserData();
    //filteredFriends.addAll(friends);
  }

  void filterFriends(String query) {
    if (query.isNotEmpty) {
      List<String> temp = [];
      friends.forEach((friend) {
        if (friend.toLowerCase().contains(query.toLowerCase())) {
          temp.add(friend);
        }
      });
      setState(() {
        filteredFriends.clear();
        filteredFriends.addAll(temp);
      });
    } else {
      setState(() {
        filteredFriends.clear();
        filteredFriends.addAll(friends);
      });
    }
  }

  void showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Friend'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('Enter Friend username'),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Friend username',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                DocumentSnapshot userDoc = await _firestore.collection('users').doc('qwerty').get();
                print(userDoc.get('friends'));
                // Perform add friend action
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => filterFriends(value),
              decoration: InputDecoration(
                hintText: 'Search Friends',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredFriends[index]),
                  onTap: () {
                    // Handle friend selection
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${filteredFriends[index]} as friend.'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0, // Adjust as needed
            right: 16.0, // Adjust as needed
            child: GestureDetector(
              onTap: () {
                // Perform action when the button is tapped
                showAddFriendDialog(context);
              },
              child: Container(
                width: 120,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add Friend',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(Icons.add, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}