import 'package:hive/hive.dart';
import 'student.dart';
import 'teacher.dart';
import 'package:flutter/material.dart';
import '../time_of_day_adapter.dart';


part 'lesson.g.dart';

@HiveType(typeId: 1)
class Lesson {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int duration;

  @HiveField(5)
  final List<Teacher> teachers;

  @HiveField(6)
  final List<Student> students;

  @HiveField(7)
  final List<String> promotions;

  @HiveField(8)
  final TimeOfDay startTime;

  @HiveField(9)
  final TimeOfDay endTime;

  @HiveField(10)
  final String sessionToken;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.duration,
    required this.teachers,
    required this.students,
    required this.promotions,
    required this.startTime,
    required this.endTime,
    required this.sessionToken
  });
}
