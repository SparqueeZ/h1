import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/promotion.dart';
import '../models/lesson.dart';
import '../models/teacher.dart';
import '../models/student.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final secureStorage = const FlutterSecureStorage();

  final String apiUrl = 'http://172.20.10.2:3000/api/auth/data';

  @override
  void initState() {
    super.initState();
    _initHive();
    _redirectBasedOnRole();
  }

  Future<void> _initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(PromotionAdapter());
    Hive.registerAdapter(LessonAdapter());
    Hive.registerAdapter(TeacherAdapter());
    Hive.registerAdapter(StudentAdapter());
  }

  Future<void> saveData(Map<String, dynamic> jsonData) async {
    // Assurez-vous que la boîte est ouverte
    final userBox = Hive.box('userBox');

    // Sauvegarde de l'utilisateur
    final user = User(
      email: jsonData['user']['email'],
      roles: List<String>.from(jsonData['user']['roles']),
      firstname: jsonData['user']['firstname'],
      lastname: jsonData['user']['lastname'],
      age: jsonData['user']['age'],
    );
    await userBox.put('user', user);

    // Sauvegarde des promotions
    final promotions = (jsonData['promotions'] as List)
        .map((promotionJson) => Promotion(
      name: promotionJson['name'],
      year: promotionJson['year'],
      lessons: (promotionJson['lessons'] as List)
          .map((lessonJson) => Lesson(
        title: lessonJson['title'],
        description: lessonJson['description'],
        date: DateTime.parse(lessonJson['date']),
        duration: lessonJson['duration'],
        teachers: (lessonJson['teachers'] as List)
            .map((teacherJson) => Teacher(
          firstname: teacherJson['fisrtname'],
          lastname: teacherJson['lastname'],
        ))
            .toList(),
        students: (lessonJson['students'] as List)
            .map((studentJson) => Student(
          firstname: studentJson['fisrtname'],
          lastname: studentJson['lastname'],
          isPresent: studentJson['isPresent'],
        ))
            .toList(),
      ))
          .toList(),
    ))
        .toList();
    await userBox.put('promotions', promotions);
  }


  Future<String?> _fetchUserRole(String token) async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'token': '$token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveData(data);

        List<dynamic>? roles = data['user']['roles'];
        if (roles != null && roles.isNotEmpty) {
          return roles[0];
        } else {
          throw Exception('Aucun rôle trouvé dans les données utilisateur.');
        }
      } else {
        throw Exception('Erreur lors de la récupération du rôle.');
      }
    } catch (e) {
      print("Erreur lors de la récupération du rôle : $e");
      return null;
    }
  }

  Future<void> _redirectBasedOnRole() async {
    try {
      String? token = await secureStorage.read(key: 'auth_token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      String? role = await _fetchUserRole(token);

      if (role == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      print("Utilisateur connecté avec le rôle : $role");

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
          Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print("Erreur lors de la redirection : $e");
      Navigator.pushReplacementNamed(context, '/login');
    }
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