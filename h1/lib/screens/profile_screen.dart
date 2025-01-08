import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../components/drawer_menu.dart';
import '../models/promotion.dart';
import '../models/user.dart';

const Color backgroundColor = Color(0xFF141B25);

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Box<User> userBox;
  User? user;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    userBox = await Hive.openBox<User>('users');
    setState(() {
      user = userBox.getAt(0);
    });
  }

  Future<void> _logout() async {
    await Hive.box<User>('users').clear();
    await Hive.box<Promotion>('promotions').clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  String translateRole(String role) {
    switch (role) {
      case 'student':
        return 'Élève';
      case 'teacher':
        return 'Enseignant';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: Text('No user information available.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final String initials = '${user!.firstname[0].toUpperCase()}${user!.lastname[0].toUpperCase()}';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                child: Text(
                  initials,
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '${user!.firstname} ${user!.lastname}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '${user!.email}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '${user!.roles.map(translateRole).join(', ')}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              // Add more user information here if needed
            ],
          ),
        ),
      ),
    );
  }
}