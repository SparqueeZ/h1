import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final List<String> roles;

  @HiveField(2)
  final String firstname;

  @HiveField(3)
  final String lastname;

  @HiveField(4)
  final int age;

  User({
    required this.email,
    required this.roles,
    required this.firstname,
    required this.lastname,
    required this.age,
  });
}
