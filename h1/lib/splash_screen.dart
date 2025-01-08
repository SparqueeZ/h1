import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/promotion.dart';
import 'models/user.dart';
import 'services/data_service.dart';
import 'home_page_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DataService dataService = DataService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, load data from local storage
      await _loadLocalData();
    } else {
      // Internet connection available, fetch data from API
      await _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    try {
      await dataService.fetchUserData();
      final userBox = await Hive.openBox<User>('users');
      final user = userBox.getAt(0);

      if (user != null && user.roles.contains('teacher')) {
        _redirectToTeacherHome();
      } else if (user != null && user.roles.contains("moderator")) {
        _redirectToModeratorHome();
      } else {
        _redirectToHome();
      }
    } catch (e) {
      print(e);
      _redirectToLogin();
    }
  }

  Future<void> _loadLocalData() async {
    final userBox = await Hive.openBox<User>('users');
    final promotionBox = await Hive.openBox<Promotion>('promotions');

    final user = userBox.getAt(0);
    final promotions = promotionBox.values.toList();

    if (user != null) {
      if (user.roles.contains('teacher')) {
        _redirectToTeacherHome();
      } else {
        _redirectToHome();
      }
    } else {
      _redirectToLogin();
    }
  }

  void _redirectToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _redirectToTeacherHome() {
    Navigator.pushReplacementNamed(context, '/teacher');
  }


  void _redirectToModeratorHome() {
    Navigator.pushReplacementNamed(context, '/moderator');
  }

  void _redirectToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141B25),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(cardBgColor),
        ),
      ),
    );
  }
}