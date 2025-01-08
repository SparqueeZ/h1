import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user.dart';

class DatabaseServices {
  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());

    await _initializeUserTable();
  }

  static Future<void> _initializeUserTable() async {
    final userBox = await Hive.openBox<User>('users');

    if (userBox.isEmpty) {
      userBox.add(User(
        id: '1',
        firstname: 'Nicolas',
        lastname: 'Bazin',
        age: 12,
        email: 'nicolas@gmail.com',
        roles: ['student'],
      ));
    }
  }
}