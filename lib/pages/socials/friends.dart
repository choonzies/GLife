import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = 'qwerty';
  
  List<dynamic> friends = [];
  List<dynamic> filteredFriends = [];
  List<dynamic> friendReqs = [];

  Future<void> fetchFriends() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(username).get();
      if (userDoc.exists) {
        setState(() {
          friends = userDoc.get('friends') ?? [];
          filteredFriends.addAll(friends);
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error retrieving document: $e');
    }
  }

  Future<void> fetchFriendReqs() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(username).get();
      if (userDoc.exists) {
        setState(() {
          friendReqs = userDoc.get('friendReqs') ?? [];
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error retrieving document: $e');
    }
  }

  Future<void> deleteFieldListItem(String collection, String document, String field, String item) async {
    try {
      await _firestore.collection(collection).doc(username).update({
        field: FieldValue.arrayRemove([item]),
      });
      print('Item removed from ListField successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addFieldListItem(String collection, String document, String field, String item) async {
    try {
      await _firestore.collection(collection).doc(document).update({
        field: FieldValue.arrayUnion([item]),
      });
      print('Item added to ListField successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFriends();
    fetchFriendReqs();
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
          title: const Text('Add Friend'),
          content: const SingleChildScrollView(
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
                DocumentSnapshot userDoc = await _firestore.collection('users').doc(username).get();
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

  void _showFriendRequestsDialog() {
    final scaffold = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Friend Requests'),
          content: Container(
            width: double.minPositive,
            height: 300.0,
            child: ListView.builder(
              itemCount: friendReqs.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(friendReqs[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          // Firebase stuff - delete from friendReqs, add to Friends
                          addFieldListItem('users', username, 'friends', friendReqs[index]);
                          deleteFieldListItem('users', username, 'friendReqs', friendReqs[index]);
                          
                          // Handle accept friend request
                          scaffold.showSnackBar(
                            SnackBar(
                              content: Text('Added ${friendReqs[index]} as friend'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          setState(() {
                            friends.add(friendReqs[index]);
                            friendReqs.remove(friendReqs[index]);
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          // Firebase stuff
                          deleteFieldListItem('users', username, 'friendReqs', friendReqs[index]);

                          // Handle reject friend request
                          scaffold.showSnackBar(
                            SnackBar(
                              content: Text('Rejected ${friendReqs[index]}'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          setState(() {
                            friendReqs.remove(friendReqs[index]);
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // View user profile
                    print('Tapped on ${friendReqs[index]}');
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
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
                    Icon(Icons.add_reaction, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80.0,
            right: 16.0,
            child: GestureDetector(
              onTap: () {
                // Perform action when the button is tapped
                _showFriendRequestsDialog();
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
                      'Requests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(Icons.quiz_rounded, color: Colors.white),
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