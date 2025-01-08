import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:h1_baptiste/splash_screen.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'models/user.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

const Color backgroundColor = Color(0xFF141B25);
const Color primaryColor = Color(0xFF00796B);
const Color cardBgColor = Color(0xFF004748);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    // Remove the connectivity check
  }

  Future<void> _login() async {
    final String? apiBaseUrl = dotenv.env['API_BASE_URL'];
    final String apiUrl = '$apiBaseUrl/api/auth/login';
    if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    try {
      final email = emailController.text;
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        _showErrorDialog('Veuillez remplir tous les champs.');
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        if (token != null) {
          await secureStorage.write(key: 'auth_token', value: token);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid credentials')),
          );
        }
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Erreur inconnue.';
        _showErrorDialog('Erreur de connexion : $errorMessage');
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la connexion : $e');
    }
  }

  Future<void> _loadLocalData() async {
    final userBox = await Hive.openBox<User>('users');
    final user = userBox.isNotEmpty ? userBox.getAt(0) : null;

    if (user != null) {
      if (user.roles.contains('teacher')) {
        Navigator.pushReplacementNamed(context, '/teacher');
      } else if (user.roles.contains('moderator')) {
        Navigator.pushReplacementNamed(context, '/moderator');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

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
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'assets/images/login.png',
                  height: 250,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _buildTextField(
                controller: emailController,
                labelText: 'Email',
                iconPath: 'assets/icons/mail.png',
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: passwordController,
                labelText: 'Mot de passe',
                iconPath: 'assets/icons/password.png',
                obscureText: !passwordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Logique à remplir
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Connexion',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OU', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadLocalData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardBgColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Mode hors connexion',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String iconPath,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          height: 24,
          width: 24,
          color: Colors.white,
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              labelText: labelText,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            style: TextStyle(color: Colors.white),
            cursorColor: primaryColor,
          ),
        ),
      ],
    );
  }
}