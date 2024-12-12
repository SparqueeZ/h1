import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Méthode pour vérifier les identifiants et récupérer le token
  Future<void> _login() async {
    try {
      final email = emailController.text;
      final password = passwordController.text;

      // Vérification dans la table des élèves
      final eleveBox = await Hive.openBox('eleves');
      final eleve = eleveBox.values.firstWhere(
            (user) => user['email'] == email && user['password'] == password,
        orElse: () => null,
      );

      // Vérification dans la table des professeurs
      final professeurBox = await Hive.openBox('professeurs');
      final professeur = professeurBox.values.firstWhere(
            (user) => user['email'] == email && user['password'] == password,
        orElse: () => null,
      );

      // Vérification dans la table des administrateurs
      final adminBox = await Hive.openBox('administration');
      final admin = adminBox.values.firstWhere(
            (user) => user['email'] == email && user['password'] == password,
        orElse: () => null,
      );

      String? token;
      String? role;

      // Si un utilisateur est trouvé, récupérer le token et définir le rôle
      if (eleve != null) {
        token = eleve['token'];
        role = 'eleve';  // Rôle d'élève
      } else if (professeur != null) {
        token = professeur['token'];
        role = 'professeur';  // Rôle de professeur
      } else if (admin != null) {
        token = admin['token'];
        role = 'administration';  // Rôle d'administrateur
      }

      // Si l'utilisateur est trouvé et qu'un token est disponible
      if (token != null && role != null) {
        // Stocker à la fois le token et le rôle
        await secureStorage.write(key: 'auth_token', value: token);
        await secureStorage.write(key: 'user_role', value: role);

        // Rediriger vers le SplashScreen
        Navigator.pushReplacementNamed(context, '/splash');
      } else {
        _showErrorDialog('Identifiants incorrects ou token absent.');
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la connexion : $e');
    }
  }



  // Méthode pour afficher un dialog d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Connexion'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo en haut de la page
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(75),
                  boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
                ),
              ),
              SizedBox(height: 40),

              // Champ Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.teal),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),

              // Champ Mot de passe
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: TextStyle(color: Colors.teal),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
              SizedBox(height: 40),

              // Bouton Se connecter
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                  EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Se connecter',
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
