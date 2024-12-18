import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/promotion.dart';
import '../models/lesson.dart';
import '../models/teacher.dart';
import '../models/student.dart';

class DatabaseServices {
  /// Initialisation globale de Hive et enregistrement des adaptateurs
  static Future<void> initializeHive() async {
    // Initialiser Hive
    await Hive.initFlutter();

    // Enregistrement des adaptateurs pour les modèles personnalisés
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(PromotionAdapter());
    Hive.registerAdapter(LessonAdapter());
    Hive.registerAdapter(TeacherAdapter());
    Hive.registerAdapter(StudentAdapter());

    // Initialiser les tables/boîtes nécessaires
    await _initializeEleveTable();
    await _initializeProfesseurTable();
    await _initializePromotionTable();
    await _initializeLessonTable();
    await _initializeAdministrationTable();
  }

  /// Initialisation de la boîte pour l'administration
  static Future<void> _initializeAdministrationTable() async {
    final administrationBox = await Hive.openBox('administrationBox');

    // Exemple d'ajout de données si la boîte est vide
    if (administrationBox.isEmpty) {
      administrationBox.add(User(
        firstname: 'Nicolas',
        lastname: 'Bazin',
        email: 'nicolas@gmail.com',
        age: 12,
        roles: ['admin'],
      ));
    }
  }

  /// Initialisation de la boîte pour les élèves
  static Future<void> _initializeEleveTable() async {
    final eleveBox = await Hive.openBox('eleveBox');

    // Exemple d'ajout de données si la boîte est vide
    if (eleveBox.isEmpty) {
      eleveBox.add(User(
        firstname: 'Hugo',
        lastname: 'Weymiens',
        email: 'hugo@gmail.com',
        age: 20,
        roles: ['student'],
      ));
    }
  }

  /// Initialisation de la boîte pour les professeurs
  static Future<void> _initializeProfesseurTable() async {
    final professeurBox = await Hive.openBox('professeurBox');

    // Exemple d'ajout de données si la boîte est vide
    if (professeurBox.isEmpty) {
      professeurBox.add(User(
        firstname: 'Baptiste',
        lastname: 'Dijoux',
        email: 'baptiste@gmail.com',
        age: 35,
        roles: ['teacher'],
      ));
    }
  }

  /// Initialisation de la boîte pour les promotions
  static Future<void> _initializePromotionTable() async {
    final promotionBox = await Hive.openBox('promotionBox');

    // Exemple d'ajout de données si la boîte est vide
    if (promotionBox.isEmpty) {
      promotionBox.add(Promotion(
        name: '2024',
        year: 2024,
        lessons: [],
      ));
    }
  }

  /// Initialisation de la boîte pour les leçons
  static Future<void> _initializeLessonTable() async {
    final lessonBox = await Hive.openBox('lessonBox');

    // Exemple d'ajout de données si la boîte est vide
    if (lessonBox.isEmpty) {
      lessonBox.add(Lesson(
        title: 'Mathématiques',
        description: 'Cours de mathématiques avancées',
        date: DateTime.parse('2024-12-12'),
        duration: 2,
        teachers: [],
        students: [],
      ));
    }
  }
}
