import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'components/drawer_menu.dart';
import 'models/student.dart';
import 'services/data_service.dart';
import 'models/lesson.dart';
import 'models/promotion.dart';
import 'models/user.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

const Color backgroundColor = Color(0xFF141B25);
const Color bottomNavBgColor = Color(0xFF1A1A1A);
const Color primaryColor = Color(0xFF00796B);
const Color cardBgColor = Color(0xFF004748);
const Color warningColor = Color(0xFFFFA726);
const Color successColor = Color(0xFF66BB6A);
const Color errorColor = Color(0xFFEF5350);

class HomePageModeratorScreen extends StatefulWidget {
  const HomePageModeratorScreen({Key? key}) : super(key: key);

  @override
  HomePageModeratorScreenState createState() => HomePageModeratorScreenState();
}

class HomePageModeratorScreenState extends State<HomePageModeratorScreen > {
  late Box<User> userBox;
  late Box<Promotion> promotionBox;
  User? user;
  List<Lesson> upcomingLessons = [];
  List<Lesson> pastLessons = [];
  List<Lesson> currentLessons = [];
  List<Promotion> promotions = [];
  List<Student> students = [];
  bool isLoading = true;
  int selectedTabIndex = 0;
  Promotion? selectedPromotion;
  final DataService dataService = DataService();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await dataService.fetchUserData();
      await _openBox();
      await _fetchStudents();
      await _fetchPromotions();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openBox() async {
    userBox = await Hive.openBox<User>('users');
    promotionBox = await Hive.openBox<Promotion>('promotions');
    final lessonBox = await Hive.openBox<Lesson>('lessons');

    user = userBox.getAt(0);
    promotions = promotionBox.values.toList();
    List<Lesson> allLessons = lessonBox.values.toList();

    final now = DateTime.now();
    currentLessons = allLessons.where((lesson) => _isLessonOngoing(lesson)).toList();
    upcomingLessons = allLessons.where((lesson) => lesson.date.isAfter(now) && !_isLessonOngoing(lesson)).toList();
    pastLessons = allLessons.where((lesson) => lesson.date.isBefore(now)).toList();

    upcomingLessons.sort((a, b) => a.date.compareTo(b.date));
    pastLessons.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _fetchStudents() async {
    final response = await http.get(Uri.parse('http://10.8.0.2:3000/api/students'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        students = data.map((json) {
          return Student(
            id: json['_id'] ?? '',
            firstname: json['firstname'],
            lastname: json['lastname'],
            isPresent: json['isPresent'] ?? false,
          );
        }).toList();
      });
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<void> _fetchPromotions() async {
    final response = await http.get(Uri.parse('http://10.8.0.2:3000/api/promotions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        promotions = data.map((json) {
          return Promotion(
            id: json['_id'] ?? '',
            name: json['name'],
            year: json['year'],
            lessons: [], // Assuming lessons are not needed for this example
            students: [], // Assuming students are not needed for this example
          );
        }).toList();
      });
    } else {
      throw Exception('Failed to load promotions');
    }
  }

  bool _isUserPresentInLesson(Lesson lesson) {
    if (user == null) return false;
    for (var student in lesson.students) {
      if (student.firstname.toLowerCase() == user!.firstname.toLowerCase() &&
          student.lastname.toLowerCase() == user!.lastname.toLowerCase()) {
        return student.isPresent;
      }
    }
    return false;
  }

  bool _isLessonOngoing(Lesson lesson) {
    final now = DateTime.now();
    final lessonStart = DateTime(lesson.date.year, lesson.date.month, lesson.date.day, lesson.startTime.hour, lesson.startTime.minute);
    final lessonEnd = DateTime(lesson.date.year, lesson.date.month, lesson.date.day, lesson.endTime.hour, lesson.endTime.minute);
    return now.isAfter(lessonStart) && now.isBefore(lessonEnd);
  }

  Future<void> _logout() async {
    await Hive.box<User>('users').clear();
    await Hive.box<Promotion>('promotions').clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _assignStudentToPromotion(String studentId, String promotionId) async {
    final response = await http.post(
      Uri.parse('http://10.8.0.2:3000/api/student/addToPromotion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"studentId": studentId, "promotionId": promotionId}),
    );

    print(jsonEncode({"studentId": studentId, "promotionId": promotionId}));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student assigned to promotion successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign student to promotion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAssignStudentPopup(BuildContext context) {
    String? selectedStudentId;
    String? selectedPromotionId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141B25),
          title: Text('Assign Student to Promotion', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Student', labelStyle: TextStyle(color: Colors.white)),
                dropdownColor: const Color(0xFF141B25),
                style: TextStyle(color: Colors.white),
                items: students.map((Student student) {
                  return DropdownMenuItem<String>(
                    value: student.id,
                    child: Text('${student.firstname} ${student.lastname}', style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedStudentId = newValue;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Promotion', labelStyle: TextStyle(color: Colors.white)),
                dropdownColor: const Color(0xFF141B25),
                style: TextStyle(color: Colors.white),
                items: promotions.map((Promotion promotion) {
                  return DropdownMenuItem<String>(
                    value: promotion.id,
                    child: Text(promotion.name, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedPromotionId = newValue;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedStudentId != null && selectedPromotionId != null) {
                  _assignStudentToPromotion(selectedStudentId!, selectedPromotionId!);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select both student and promotion'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(cardBgColor),
          ),
        ),
      );
    }

    final String initials = '${user?.firstname[0].toUpperCase() ?? ''}${user?.lastname[0].toUpperCase() ?? ''}';

    return Scaffold(
      backgroundColor: const Color(0xFF141B25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          '${user?.firstname ?? ''} ${user?.lastname ?? ''}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      drawer: DrawerMenu(user: user, onLogout: _logout),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300, // Fixed width
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showCreateUserPopup(context);
                      },
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text('Ajouter un utilisateur', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 20), // Fixed height
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Space between buttons
                  SizedBox(
                    width: 300, // Fixed width
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAssignStudentPopup(context);
                      },
                      icon: Icon(Icons.assignment, color: Colors.white),
                      label: Text('Assign Student to Promotion', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 20), // Fixed height
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Existing content
            ],
          ),
        ),
      ),
    );
  }
}
void _showCreateUserPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF141B25),
        title: Text('Créer un utilisateur', style: TextStyle(color: Colors.white)),
        content: CreateUserForm(),
      );
    },
  );
}

class CreateUserForm extends StatefulWidget {
  @override
  _CreateUserFormState createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = {
        "firstname": _firstnameController.text,
        "lastname": _lastnameController.text,
        "age": int.parse(_ageController.text),
        "email": _emailController.text,
        "password": _passwordController.text,
        "role": _selectedRole,
      };

      try {
        final response = await http.post(
          Uri.parse('http://10.8.0.2:3000/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(user),
        );

        if (response.statusCode == 200) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Utilisateur créé avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${response.reasonPhrase}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exception: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form validation failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _firstnameController,
            decoration: InputDecoration(labelText: 'Prénom', labelStyle: TextStyle(color: Colors.white)),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un prénom';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _lastnameController,
            decoration: InputDecoration(labelText: 'Nom', labelStyle: TextStyle(color: Colors.white)),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nom';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(labelText: 'Âge', labelStyle: TextStyle(color: Colors.white)),
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un âge';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.white)),
            style: TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Mot de passe', labelStyle: TextStyle(color: Colors.white)),
            style: TextStyle(color: Colors.white),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(labelText: 'Rôle', labelStyle: TextStyle(color: Colors.white)),
            dropdownColor: const Color(0xFF141B25),
            style: TextStyle(color: Colors.white),
            items: ['moderator', 'student', 'teacher'].map((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner un rôle';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }
}