import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import de flutter_dotenv
import '../models/user.dart';
import '../models/promotion.dart';
import '../models/lesson.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../time_of_day_adapter.dart';

class DataService {
  final secureStorage = const FlutterSecureStorage();

  Future<void> fetchUserData() async {
    try {
      final String? apiBaseUrl = dotenv.env['API_BASE_URL'];
      if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
        throw Exception('API_BASE_URL is not defined in .env');
      }

      final String apiUrl = '$apiBaseUrl/api/auth/data';

      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'token': '$token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final userJson = data['user'];
        if (userJson != null) {
          final user = User(
            id: userJson['id'] ?? '',
            email: userJson['email'] ?? '',
            roles: List<String>.from(userJson['roles'] ?? []),
            firstname: userJson['firstname'] ?? '',
            lastname: userJson['lastname'] ?? '',
            age: userJson['age'] ?? 0,
          );

          final userBox = await Hive.openBox<User>('users');
          await userBox.clear();
          await userBox.add(user);
        }

        final promotionsJson = data['promotions'] as List<dynamic>? ?? [];
        final promotionBox = await Hive.openBox<Promotion>('promotions');
        await promotionBox.clear();

        for (final promoJson in promotionsJson) {
          final lessons = (promoJson['lessons'] as List<dynamic>? ?? []).map((lessonJson) {
            final teachers = (lessonJson['teachers'] as List<dynamic>? ?? []).map((teacherJson) {
              return Teacher(
                firstname: teacherJson['firstname'] ?? '',
                lastname: teacherJson['lastname'] ?? '',
              );
            }).toList();

            final students = (lessonJson['students'] as List<dynamic>? ?? []).map((studentJson) {
              return Student(
                id: studentJson['_id'] ?? '',
                firstname: studentJson['firstname'] ?? '',
                lastname: studentJson['lastname'] ?? '',
                isPresent: studentJson['isPresent'] ?? false,
              );
            }).toList();

            final DateTime startDateTime = DateTime.parse(lessonJson['date'] ?? DateTime.now().toIso8601String());
            final TimeOfDay startTime = TimeOfDay.fromDateTime(startDateTime);
            final TimeOfDay endTime = TimeOfDay.fromDateTime(startDateTime.add(Duration(minutes: lessonJson['duration'] ?? 0)));

            return Lesson(
              id: lessonJson['id'] ?? '',
              title: lessonJson['title'] ?? '',
              description: lessonJson['description'] ?? '',
              date: startDateTime,
              duration: lessonJson['duration'] ?? 0,
              teachers: teachers,
              students: students,
              promotions: List<String>.from(lessonJson['promotions'] ?? []),
              startTime: startTime,
              endTime: endTime,
              sessionToken: lessonJson['sessionToken'] ?? '',
            );
          }).toList();

          final students = (promoJson['students'] as List<dynamic>? ?? []).map((studentJson) {
            return Student(
              id: studentJson['_id'] ?? '',
              firstname: studentJson['firstname'] ?? '',
              lastname: studentJson['lastname'] ?? '',
              isPresent: studentJson['isPresent'] ?? false,
            );
          }).toList();

          final promotion = Promotion(
            id: promoJson['_id'] ?? '',
            name: promoJson['name'] ?? '',
            year: promoJson['year'] ?? 0,
            lessons: lessons,
            students: students,
          );

          await promotionBox.add(promotion);
        }

        final lessonsJson = data['lessons'] as List<dynamic>? ?? [];
        final lessonBox = await Hive.openBox<Lesson>('lessons');
        await lessonBox.clear();

        for (final lessonJson in lessonsJson) {
          final teachers = (lessonJson['teachers'] as List<dynamic>? ?? []).map((teacherJson) {
            return Teacher(
              firstname: teacherJson['firstname'] ?? '',
              lastname: teacherJson['lastname'] ?? '',
            );
          }).toList();

          final students = (lessonJson['students'] as List<dynamic>? ?? []).map((studentJson) {
            return Student(
              id: studentJson['_id'] ?? '',
              firstname: studentJson['firstname'] ?? '',
              lastname: studentJson['lastname'] ?? '',
              isPresent: studentJson['isPresent'] ?? false,
            );
          }).toList();

          final DateTime startDateTime = DateTime.parse(lessonJson['date'] ?? DateTime.now().toIso8601String());
          final TimeOfDay startTime = TimeOfDay.fromDateTime(startDateTime);
          final TimeOfDay endTime = TimeOfDay.fromDateTime(startDateTime.add(Duration(minutes: lessonJson['duration'] ?? 0)));

          final lesson = Lesson(
            id: lessonJson['id'] ?? '',
            title: lessonJson['title'] ?? '',
            description: lessonJson['description'] ?? '',
            date: startDateTime,
            duration: lessonJson['duration'] ?? 0,
            teachers: teachers,
            students: students,
            promotions: List<String>.from(lessonJson['promotions'] ?? []),
            startTime: startTime,
            endTime: endTime,
            sessionToken: lessonJson['sessionToken'] ?? '',
          );

          await lessonBox.add(lesson);
        }
      } else {
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }
}
