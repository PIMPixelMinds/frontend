import 'package:flutter/material.dart';
import 'package:pim/view/auth/profile_page.dart';
import '../auth/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    Center(child: Text("Home", style: TextStyle(fontSize: 22))),
    Center(child: Text("Search", style: TextStyle(fontSize: 22))),
    Center(child: Text("Notifications", style: TextStyle(fontSize: 22))),
    ProfilePage(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // Icônes sélectionnées en bleu
        unselectedItemColor: Colors.grey, // Icônes non sélectionnées en gris
        type: BottomNavigationBarType.fixed, // Garde la même taille des icônes
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
