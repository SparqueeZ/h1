import 'package:flutter/material.dart';
import 'package:h1_baptiste/screens/calendar_view_screen.dart';
import 'package:h1_baptiste/screens/profile_screen.dart';
import 'package:h1_baptiste/splash_screen.dart';
import 'package:h1_baptiste/home_page_screen.dart';
import 'package:h1_baptiste/home_page_teacher_screen.dart';
import 'home_page_moderator_screen.dart';
import 'login_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/lesson.dart';
import 'models/promotion.dart';
import 'models/student.dart';
import 'models/teacher.dart';
import 'models/user.dart';
import 'time_of_day_adapter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'time_of_day_adapter.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PromotionAdapter());
  Hive.registerAdapter(LessonAdapter());
  Hive.registerAdapter(TeacherAdapter());
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());

  await dotenv.load(fileName: "assets/.env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Define routes
      initialRoute: '/login', // Initial page, LoginScreen
      routes: {
        '/login': (context) => LoginScreen(),
        '/splash': (context) => SplashScreen(),
        '/home': (context) => const HomePageScreen(),
        '/teacher': (context) => const HomePageTeacherScreen(),
        '/moderator': (context) => const HomePageModeratorScreen(),
        '/profile': (context) => ProfileScreen(),
        '/calendar': (context) => CalendarViewScreen()
      },
    );
  }
}