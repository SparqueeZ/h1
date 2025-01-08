import 'package:hive/hive.dart';

part 'teacher.g.dart';

@HiveType(typeId: 2)
class Teacher {
  @HiveField(0)
  final String firstname;

  @HiveField(1)
  final String lastname;

  Teacher({
    required this.firstname,
    required this.lastname,
  });
}