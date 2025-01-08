import 'package:hive/hive.dart';
import 'lesson.dart';
import 'student.dart';

part 'promotion.g.dart';

@HiveType(typeId: 4)
class Promotion {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int year;

  @HiveField(3)
  final List<Lesson> lessons;

  @HiveField(4)
  final List<Student> students;

  Promotion({
    required this.id,
    required this.name,
    required this.year,
    required this.lessons,
    required this.students,
  });
}
