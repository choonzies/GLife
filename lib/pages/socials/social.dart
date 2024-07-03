import 'package:flutter/material.dart';
import 'package:glife/pages/socials/Friends.dart';
import 'package:glife/pages/socials/groups.dart';

class Social extends StatefulWidget {
  const Social({super.key});

  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  
  List<Widget> _widgetOptions() {
    return <Widget>[
      Friends(),
      Groups(),
    ];
  }

  bool isFriends = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text('My ${isFriends ? 'Friends' : 'Groups'}',
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0,
              fontWeight: FontWeight.bold
            ),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Row(
              children: [
                Text(
                  'Swap',
                  style: TextStyle(
                    color: Color.fromARGB(255, 56, 54, 54),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.swap_horiz_sharp),
              ],
            ),
            onPressed: () {
              setState(() {
                isFriends = !isFriends;
              });
            },
          ),
        ],
      ),
      
      body: Center(
        child: _widgetOptions().elementAt(isFriends ? 0 : 1),
      )
    );
  }
}
