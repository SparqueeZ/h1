import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final secureStorage = const FlutterSecureStorage();

  // Fonction pour gérer la redirection basée sur le rôle
  Future<void> _redirectBasedOnRole() async {
    try {
      // Récupérer le token depuis le stockage sécurisé
      String? token = await secureStorage.read(key: 'auth_token');
      String? role = await secureStorage.read(key: 'user_role'); // Récupérer le rôle

      if (token == null || role == null) {
        // Si aucun token ou rôle n'est trouvé, redirection vers la page de login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      print("Utilisateur connecté avec le rôle : $role");

      // Redirection selon le rôle
      switch (role) {
        case 'eleve':
          Navigator.pushReplacementNamed(context, '/homeEleve');
          break;
        case 'professeur':
          Navigator.pushReplacementNamed(context, '/homeProfessor');
          break;
        case 'admin':
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
