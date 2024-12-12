import 'package:flutter/material.dart';
import 'package:h1/views/home_eleve_screen.dart';
import 'package:h1/views/home_professor_screen.dart';
import 'package:h1/views/home_administration_screen.dart';
import 'package:h1/views/login_screen.dart';
import 'package:h1/views/splash_screen.dart';
import 'package:h1/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la base de données Hive via DatabaseServices
  await DatabaseServices.initializeHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Définition des routes
      initialRoute: '/login', // Page de base, LoginScreen
      routes: {
        '/login': (context) => LoginScreen(), // Page de Login
        '/splash': (context) => SplashScreen(), // SplashScreen
        '/homeEleve': (context) => HomePageEleve(), // Page d'accueil Eleve
        '/homeProfessor': (context) => HomePageProfessor(), // Page d'accueil Professor
        '/homeAdministration': (context) => HomePageAdministration(), // Page d'accueil Administration
      },
    );
  }
}
