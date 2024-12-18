import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 3)
class Student {
  @HiveField(0)
  final String firstname;

  @HiveField(1)
  final String lastname;

  @HiveField(2)
  final bool isPresent;

  Student({
    required this.firstname,
    required this.lastname,
    required this.isPresent,
  });
}

