import 'package:flutter/material.dart';
import './screens/display.dart';
import './screens/create.dart';
import 'package:note_app/screens/general-list.dart';
import 'package:note_app/screens/register.dart';
import 'package:note_app/screens/login.dart';
import 'package:note_app/screens/update-list.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 2;

  final List<Widget> _screens = [
    Display(),
    GeneralList(),
    NewDevotionScreen(),
    Login(),
    UpdateList()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: _screens[_currentIndex],
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.today, color: Colors.orange, size: 30),
            onPressed: () => onTap(0),
          ),
          IconButton(
            icon: Icon(Icons.list, color: Colors.orange, size: 30),
            onPressed: () => onTap(1),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.orange, size: 30),
            onPressed: () => onTap(2),
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.orange, size: 30),
            onPressed: () => onTap(3),
          ),
        ],
      ),
    );
  }
}
