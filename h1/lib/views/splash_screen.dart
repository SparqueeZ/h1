import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final secureStorage = const FlutterSecureStorage();

  // URL de l'API pour récupérer les informations de l'utilisateur
  final String apiUrl = 'http://172.20.10.2:3000/api/auth/data'; // Remplacez par votre URL API

  // Fonction pour récupérer le rôle depuis l'API en utilisant le token JWT
  Future<String?> _fetchUserRole(String token) async {
    try {
      // Requête à l'API pour récupérer les informations de l'utilisateur
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'token': '$token'},
      );

      if (response.statusCode == 200) {
        // L'API a renvoyé les informations de l'utilisateur
        final data = jsonDecode(response.body);
        print(data);

        // Accéder à la liste 'roles' et récupérer le premier rôle
        List<dynamic>? roles = data['user']['roles'];
        if (roles != null && roles.isNotEmpty) {
          return roles[0]; // Retourner le premier rôle
        } else {
          throw Exception('Aucun rôle trouvé dans les données utilisateur.');
        }
      } else {
        throw Exception('Erreur lors de la récupération du rôle.');
      }
    } catch (e) {
      print("Erreur lors de la récupération du rôle : $e");
      return null; // Retourner null en cas d'erreur
    }
  }

  // Fonction pour gérer la redirection basée sur le rôle
  Future<void> _redirectBasedOnRole() async {
    try {
      // Récupérer le token depuis le stockage sécurisé
      String? token = await secureStorage.read(key: 'auth_token');

      if (token == null) {
        // Si aucun token n'est trouvé, redirection vers la page de login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Récupérer le rôle en envoyant une requête à l'API
      String? role = await _fetchUserRole(token);

      if (role == null) {
        // Si le rôle est introuvable, redirection vers la page de login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      print("Utilisateur connecté avec le rôle : $role");

      // Redirection selon le rôle
      switch (role) {
        case 'student':
          Navigator.pushReplacementNamed(context, '/homeEleve');
          break;
        case 'teacher':
          Navigator.pushReplacementNamed(context, '/homeProfessor');
          break;
        case 'moderator':
          Navigator.pushReplacementNamed(context, '/homeAdministration');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/login'); // Rôle inconnu
      }
    } catch (e) {
      print("Erreur lors de la redirection : $e");
      Navigator.pushReplacementNamed(context, '/login'); // En cas d'erreur
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialiser la redirection basée sur le rôle
    _redirectBasedOnRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(75),
                boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
