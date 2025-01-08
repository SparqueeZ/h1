import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final List<String> roles;

  @HiveField(3)
  final String firstname;

  @HiveField(4)
  final String lastname;

  @HiveField(5)
  final int age;

  User({
    required this.id,
    required this.email,
    required this.roles,
    required this.firstname,
    required this.lastname,
    required this.age,
  });
}
