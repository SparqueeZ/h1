import 'package:hive/hive.dart';
import 'lesson.dart';

part 'promotion.g.dart';

@HiveType(typeId: 1)
class Promotion {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int year;

  @HiveField(2)
  final List<Lesson> lessons;

  Promotion({
    required this.name,
    required this.year,
    required this.lessons,
  });
}
