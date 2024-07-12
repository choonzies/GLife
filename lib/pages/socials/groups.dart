import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glife/pages/socials/group_details.dart';

class Groups extends StatefulWidget {
  Groups({super.key});

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = '';
  String groupName = '';
  
  List<dynamic> friends = [];
  List<dynamic> selectedFriends = [];

  List<dynamic> groups = [];
  List<dynamic> filteredGroups = [];
  List<dynamic> groupReqs = [];

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
          });
        } else {
          print('Document does not exist');
        }
      } catch (e) {
        print('Error retrieving document: $e');
      }
    }

  Future<void> fetchGroups() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(username).get();
      if (userDoc.exists) {
        setState(() {
          groups = userDoc.get('groups') ?? [];
          filteredGroups.addAll(groups);
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error retrieving document: $e');
    }
  }

  Future<void> fetchGroupReqs() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(username).get();
      if (userDoc.exists) {
        setState(() {
          groupReqs = userDoc.get('groupReqs') ?? [];
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
    fetchGroups();
    fetchGroupReqs();
    fetchFriends();
  }

  void _filterGroups(String query) {
    if (query.isNotEmpty) {
      List<String> temp = [];
      groups.forEach((group) {
        if (group.toLowerCase().contains(query.toLowerCase())) {
          temp.add(group);
        }
      });
      setState(() {
        filteredGroups.clear();
        filteredGroups.addAll(temp);
      });
    } else {
      setState(() {
        filteredGroups.clear();
        filteredGroups.addAll(groups);
      });
    }
  }

  void _showAddGroupDialog(BuildContext context) {
    selectedFriends = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Group'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    String friend = friends[index];
                    return CheckboxListTile(
                      title: Text(friend),
                      value: selectedFriends.contains(friend),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value!) {
                            selectedFriends.add(friend); // Add friend to selectedFriends
                          } else {
                            selectedFriends.remove(friend); // Remove friend from selectedFriends
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Next'),
              onPressed: () {
                Navigator.of(context).pop();
                _getGroupName(context);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _getGroupName(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Group Name'),
          content: TextField(
            onChanged: (value) {
              groupName = value; // Update groupName as user types
            },
            decoration: InputDecoration(
              hintText: 'Group Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Next'),
              onPressed: () {
                Navigator.of(context).pop(groupName);
                _showConfirmationDialog(context, groupName);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog on cancel
              },
            ),
          ],
        );
      }
    );
  }

  void _showConfirmationDialog(BuildContext context, String groupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Group Creation'),
          content: Text('Are you sure you want to create $groupName with ${selectedFriends.length} friends?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                _createGroup(groupName); // Perform group creation logic
                Navigator.of(context).popUntil((route) => route.isFirst); // Pop all dialogs and return to the first screen
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
        // After dialog is closed, trigger a rebuild of the groups list
        setState(() {});
      });
  }

  void _createGroup(String groupName) async {
    for (String friend in selectedFriends) {
      await addFieldListItem('users', friend, 'groupReqs', groupName);  // Send group reqs to members      
    }
    await _firestore.collection('groups').doc(groupName).set({  // Create group
        'leader': username,
        'admin': [],
        'members': [username],
      });
    await addFieldListItem('users', username, 'groups', groupName); // Add group to leader's list
    setState(() {
      groups.add(groupName);
    });
  }
  
  void _showGroupRequestsDialog() {
    final scaffold = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Group Requests'),
              content: Container(
                width: double.minPositive,
                height: 300.0,
                child: ListView.builder(
                  itemCount: groupReqs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(groupReqs[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () async {
                              // Firebase stuff - delete from groupReqs, add to groups
                              await addFieldListItem('users', username, 'groups', groupReqs[index]);
                              await deleteFieldListItem('users', username, 'groupReqs', groupReqs[index]);
                              await addFieldListItem('groups', groupReqs[index], 'members', username); // Add user to groups collection as well
                              
                              // Handle accept friend request
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text('Joined ${groupReqs[index]}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                              setState(() {
                                groups.add(groupReqs[index]);
                                filteredGroups.add(groupReqs[index]);
                                groupReqs.remove(groupReqs[index]);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              // Firebase stuff - delete from groupReqs
                              await deleteFieldListItem('users', username, 'groupReqs', groupReqs[index]);

                              // Handle reject friend request
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text('Rejected ${groupReqs[index]}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                              setState(() {
                                groupReqs.remove(groupReqs[index]);
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // View user profile
                        print('Tapped on ${groupReqs[index]}');
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
        // After dialog is closed, trigger a rebuild of the groups list
        setState(() {});
      });
  }

  Widget _buildGroupsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          String group = groups[index];
          return GestureDetector(
            onTap:  () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupDetails(group, username))
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
                group,
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
              onChanged: (value) => _filterGroups(value),
              decoration: InputDecoration(
                hintText: 'Search Groups',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          _buildGroupsList(),
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
              _showAddGroupDialog(context);
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
                      'New Group',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(Icons.group_add, color: Colors.white),
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
                _showGroupRequestsDialog();
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