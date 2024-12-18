import 'package:hive/hive.dart';
import 'student.dart';
import 'teacher.dart';

part 'lesson.g.dart';

@HiveType(typeId: 2)
class Lesson {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final int duration;

  @HiveField(4)
  final List<Teacher> teachers;

  @HiveField(5)
  final List<Student> students;

  Lesson({
    required this.title,
    required this.description,
    required this.date,
    required this.duration,
    required this.teachers,
    required this.students,
  });
}
