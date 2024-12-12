import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseServices {
  static Future<void> initializeHive() async {
    // Initialiser Hive
    await Hive.initFlutter();

    // Initialiser les tables si nécessaire
    await _initializeEleveTable();
    await _initializeProfesseurTable();
    await _initializePromotionTable();
    await _initializeLessonTable();
    await _initializeAdministrationTable();

  }
  static Future<void> _initializeAdministrationTable() async {
    final administrationBox = await Hive.openBox('eleves');

    // Exemple d'ajout d'un élève si la table est vide
    if (administrationBox.isEmpty) {
      administrationBox.add({
        'firstname': 'Nicolas',
        'lastname': 'Bazin',
        'age': 12,
        'email': 'nicolas@gmail.com',
        'promotion': '2024',
        'password': 'password',
        'token': 'ze5f9',
      });
    }
  }

  static Future<void> _initializeEleveTable() async {
    final eleveBox = await Hive.openBox('eleves');

    // Exemple d'ajout d'un élève si la table est vide
    if (eleveBox.isEmpty) {
      eleveBox.add({
        'firstname': 'Hugo',
        'lastname': 'Weymiens',
        'age': 20,
        'email': 'hugo@gmail.com',
        'promotion': '2024',
        'password': 'password',
        'token': 'rhqzjs',
      });
    }
  }

  static Future<void> _initializeProfesseurTable() async {
    final professeurBox = await Hive.openBox('professeurs');

    // Exemple d'ajout d'un professeur si la table est vide
    if (professeurBox.isEmpty) {
      professeurBox.add({
        'firstname': 'Baptiste',
        'lastname': 'Dijoux',
        'age': 35,
        'email': 'baptiste@gmail.com',
        'promotion': '2024',
        'password': 'password',
        'token': '4ggesg',
      });
    }
  }

  static Future<void> _initializePromotionTable() async {
    final promotionBox = await Hive.openBox('promotions');

    // Exemple d'ajout d'une promotion si la table est vide
    if (promotionBox.isEmpty) {
      promotionBox.add({
        'name': '2024',
        'year': 2024,
        'students': [], // Liste des étudiants
        'teachers': [], // Liste des enseignants
        'lessons': [],  // Liste des cours
      });
    }
  }

  static Future<void> _initializeLessonTable() async {
    final lessonBox = await Hive.openBox('lessons');

    // Exemple d'ajout d'un cours si la table est vide
    if (lessonBox.isEmpty) {
      lessonBox.add({
        'title': 'Mathématiques',
        'description': 'Cours de mathématiques avancées',
        'date': '2024-12-12',
        'duration': 2,
        'teachers': [], // Liste des enseignants
        'students': [], // Liste des étudiants
        'promotion': '2024',
        'sessionToken': 'session_token_123',
      });
    }
  }
}
