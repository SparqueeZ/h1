import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

const Color backgroundColor = Color(0xFF141B25);

class DrawerMenu extends StatelessWidget {
  final User? user;
  final VoidCallback onLogout;

  const DrawerMenu({Key? key, required this.user, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String initials = '${user?.firstname[0].toUpperCase() ?? ''}${user?.lastname[0].toUpperCase() ?? ''}';

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.blue,
      ),
      child: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 80, bottom: 40),
              child: Container(
                height: 50, // Adjust the height as needed
                color: backgroundColor,
                child: Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.teal,
                    child: Text(
                      initials,
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

            ListTile(
              leading: Image.asset('assets/icons/home.png', color: Colors.white, width: 24, height: 24),
              title: Text('Accueil', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/user.png', color: Colors.white, width: 24, height: 24),
              title: Text('Mon profil', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/calendar.png', color: Colors.white, width: 24, height: 24),
              title: Text('Calendrier', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/calendar');
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/logout.png', color: Colors.white, width: 24, height: 24),
              title: Text('Déconnexion', style: TextStyle(color: Colors.white)),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}