import 'package:flutter/material.dart';
import 'package:glife/pages/Achievements/achievements.dart';
import 'package:glife/pages/Me/me.dart';
import 'package:glife/pages/socials/social.dart';
import 'package:glife/services/auth.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _selectedIndex = 1; // this is to default the ME tab
  Future<void> signOut() async {
    await Auth().signOut();
  }

  List<Widget> _widgetOptions() {
    return <Widget>[
      Achievements(),
      Me(),
      Social(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions().elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Socials',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}