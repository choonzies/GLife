import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glife/pages/socials/user_details.dart';

class Friends extends StatefulWidget {
  Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = '';
  
  List<dynamic> friends = [];
  List<dynamic> filteredFriends = [];
  List<dynamic> friendReqs = [];

  Future<void> _getUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      String temp = await getUsernameFromEmail(email) ?? 'Username not found';
      username = temp;
    } else {
      print('No user signed in');
    }
  }

  Future<String?> getUsernameFromEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there's only one document per email, return the first username found
        return querySnapshot.docs.first.id;
      } else {
        // Handle case where no document with the given email is found
        return null;
      }
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

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
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getUsername();
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
    TextEditingController textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Friend'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: textFieldController,
                  decoration: const InputDecoration(
                    hintText: 'Friend username',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                // Retrieve friend's username from TextField
                String friendUsername = textFieldController.text.trim();
                
                if (friendUsername.isNotEmpty) {
                  // Check if the user document exists in Firestore
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(friendUsername).get();
                  bool userExists =  userDoc.exists;
                  
                  if (userExists) {
                    // Send friend request to the friend
                    await addFieldListItem('users', friendUsername, 'friendReqs', username);
                    Navigator.of(context).pop(); // Close the dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.of(context).pop(true);
                        });
                        return const AlertDialog(
                          title: Text('Friend request sent!'),
                        );
                      },
                    );
                  } else {
                    // Show error dialog for invalid username
                    showDialog(
                      context: context,
                      builder: (context) {
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.of(context).pop(true);
                        });
                        return const AlertDialog(
                          title: Text('Username not found!'),
                        );
                      },
                    );
                  }
                } else {
                  // Username is empty, show error dialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.of(context).pop(true);
                      });
                      return const AlertDialog(
                        title: Text('Invalid username!'),
                      );
                    },
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Friend Requests'),
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
                            icon: const Icon(Icons.check),
                            onPressed: () async {
                              // Firebase stuff - delete from friendReqs, add to Friends
                              await addFieldListItem('users', username, 'friends', friendReqs[index]);
                              await addFieldListItem('users', friendReqs[index], 'friends', username);
                              await deleteFieldListItem('users', username, 'friendReqs', friendReqs[index]);
                              
                              // Handle accept friend request
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text('Added ${friendReqs[index]} as friend'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                              setState(() {
                                friends.add(friendReqs[index]);
                                filteredFriends.add(friendReqs[index]);
                                friendReqs.remove(friendReqs[index]);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              // Firebase stuff - delete from friendReqs
                              await deleteFieldListItem('users', username, 'friendReqs', friendReqs[index]);

                              // Handle reject friend request
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text('Rejected ${friendReqs[index]}'),
                                  duration: const Duration(seconds: 1),
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
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
        // After dialog is closed, trigger a rebuild of the friends list
        setState(() {});
      });
  }

  Widget _buildFriendsList() {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filteredFriends.length,
        itemBuilder: (context, index) {
          String friend = filteredFriends[index];
          return GestureDetector(
            onTap:  () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserDetails(friend))
              );
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF1F4F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                friend,
                style: TextStyle(
                  color: Color(0xFF101213),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              )
            )
          );
        },
      ),
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
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          _buildFriendsList(),
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
                child: const Row(
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
                child: const Row(
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