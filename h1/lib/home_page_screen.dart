import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'models/student.dart';
import 'services/data_service.dart';
import 'models/lesson.dart';
import 'models/promotion.dart';
import 'models/user.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'components/drawer_menu.dart';

const Color backgroundColor = Color(0xFF141B25);
const Color bottomNavBgColor = Color(0xFF1A1A1A);
const Color primaryColor = Color(0xFF00796B);
const Color cardBgColor = Color(0xFF004748);
const Color warningColor = Color(0xFFFFA726);
const Color successColor = Color(0xFF66BB6A);
const Color errorColor = Color(0xFFEF5350);

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late Box<User> userBox;
  late Box<Promotion> promotionBox;
  User? user;
  List<Lesson> upcomingLessons = [];
  List<Lesson> pastLessons = [];
  List<Lesson> currentLessons = [];
  List<Promotion> promotions = [];
  bool isLoading = true;
  int selectedTabIndex = 0;
  Promotion? selectedPromotion;
  final DataService dataService = DataService();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });

    final startTime = DateTime.now();

    try {
      await dataService.fetchUserData();
      await _openBox();

      if (user != null) {
        if (user!.roles.contains('teacher')) {
          Navigator.pushReplacementNamed(context, '/teacher');
        } else if (user!.roles.contains('student')) {
          if (ModalRoute.of(context)?.settings.name != '/home') {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } catch (e) {
      // Handle error
      print(e);
    } finally {
      final elapsedTime = DateTime.now().difference(startTime);
      final delay = Duration(seconds: 1) - elapsedTime;

      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openBox() async {
    userBox = await Hive.openBox<User>('users');
    promotionBox = await Hive.openBox<Promotion>('promotions');

    user = userBox.getAt(0);
    promotions = promotionBox.values.toList();

    if (promotions.isNotEmpty) {
      selectedPromotion = promotions.first;
    }

    List<Lesson> allLessons = [];
    for (var promo in promotions) {
      allLessons.addAll(promo.lessons);
    }

    final now = DateTime.now();
    currentLessons = allLessons.where((lesson) => _isLessonOngoing(lesson)).toList();
    upcomingLessons = allLessons.where((lesson) => lesson.date.isAfter(now) && !_isLessonOngoing(lesson)).toList();
    pastLessons = allLessons.where((lesson) => lesson.date.isBefore(now)).toList();

    upcomingLessons.sort((a, b) => a.date.compareTo(b.date));
    pastLessons.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _logout() async {
    // await Hive.box<User>('users').clear();
    // await Hive.box<Promotion>('promotions').clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  bool _isUserPresentInLesson(Lesson lesson) {
    if (user == null) return false;
    for (var student in lesson.students) {
      if (student.firstname.toLowerCase() == user!.firstname.toLowerCase() &&
          student.lastname.toLowerCase() == user!.lastname.toLowerCase()) {
        return student.isPresent;
      }
    }
    return false;
  }

  bool _isLessonOngoing(Lesson lesson) {
    final now = DateTime.now();
    final lessonStart = DateTime(lesson.date.year, lesson.date.month, lesson.date.day, lesson.startTime.hour, lesson.startTime.minute);
    final lessonEnd = DateTime(lesson.date.year, lesson.date.month, lesson.date.day, lesson.endTime.hour, lesson.endTime.minute);
    return now.isAfter(lessonStart) && now.isBefore(lessonEnd);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(cardBgColor),
          ),
        ),
      );
    }

    final String initials = '${user?.firstname[0].toUpperCase() ?? ''}${user?.lastname[0].toUpperCase() ?? ''}';

    return Scaffold(
      backgroundColor: const Color(0xFF141B25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          '${user?.firstname ?? ''} ${user?.lastname ?? ''}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      drawer: DrawerMenu(user: user, onLogout: _logout),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour ${user?.firstname ?? ''},',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Voici un résumé de vos cours',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(
                          initials,
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 32.0),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabButton('Mes cours', 0),
                      SizedBox(width: 25),
                      _buildTabButton('Ma promotion', 1),
                      SizedBox(width: 25),
                      _buildTabButton('Mes absences', 2),
                      SizedBox(width: 25),
                      _buildTabButton('Mon emploi du temps', 3),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 1),
                        end: Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: selectedTabIndex == 0
                      ? _buildCourseList()
                      : _buildPromotionList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isSelected = selectedTabIndex == index;
    return Container(
      width: 180, // Set fixed width
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? primaryColor : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Max rounded corners
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.white, // Add border when not selected
            ),
          ),
        ),
        onPressed: () => setState(() => selectedTabIndex = index),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.white70),
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    if (upcomingLessons.isEmpty && pastLessons.isEmpty && currentLessons.isEmpty) {
      return Center(
        child: Text(
          'Aucun cours disponible pour le moment.',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (currentLessons.isNotEmpty) ...[
          _buildSectionTitle('Votre cours actuel'),
          ...currentLessons.map((lesson) => Column(
            children: [
              _buildLessonCard(lesson, false),
              SizedBox(height: 16), // Add space between cards
            ],
          )),
        ],
        if (upcomingLessons.isNotEmpty) ...[
          _buildSectionTitle('Vos prochains cours'),
          ...upcomingLessons.map((lesson) => Column(
            children: [
              _buildLessonCard(lesson, true),
              SizedBox(height: 16), // Add space between cards
            ],
          )),
        ],
        if (pastLessons.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildSectionTitle('Vos cours passés'),
          ...pastLessons.map((lesson) => Column(
            children: [
              _buildLessonCard(lesson, false),
              SizedBox(height: 16), // Add space between cards
            ],
          )),
        ],
      ],
    );
  }

  Widget _buildPromotionList() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: DropdownButtonFormField<Promotion>(
            value: selectedPromotion,
            hint: Text('Sélectionnez une promotion', style: TextStyle(color: Colors.white)),
            dropdownColor: cardBgColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            style: TextStyle(color: Colors.white),
            items: promotions.map((promotion) {
              return DropdownMenuItem<Promotion>(
                value: promotion,
                child: Text(promotion.name, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (Promotion? newPromotion) {
              setState(() {
                selectedPromotion = newPromotion;
              });
            },
          ),
        ),
        if (selectedPromotion != null) _buildStudentList(selectedPromotion!),
      ],
    );
  }

  Widget _buildStudentList(Promotion promotion) {
    if (promotion.students.isEmpty) {
      return Center(
        child: Text(
          'Aucun élève dans cette promotion.',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: promotion.students.length,
        itemBuilder: (context, index) {
          final student = promotion.students[index];
          final initials = '${student.firstname[0].toUpperCase()}${student.lastname[0].toUpperCase()}';
          return Card(
            color: cardBgColor,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[700],
                child: Text(
                  initials,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                '${student.firstname} ${student.lastname}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson, bool isUpcoming) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (_isLessonOngoing(lesson)) {
      bool isPresent = _isUserPresentInLesson(lesson);
      if (isPresent) {
        statusText = 'Vous êtes présent';
        statusColor = successColor;
        statusIcon = Icons.check_circle;
      } else {
        statusText = 'Vous êtes en retard';
        statusColor = warningColor;
        statusIcon = Icons.warning;
      }
    } else if (lesson.date.isBefore(DateTime.now())) {
      bool isPresent = _isUserPresentInLesson(lesson);
      if (isPresent) {
        statusText = 'Vous êtes présent';
        statusColor = successColor;
        statusIcon = Icons.check_circle;
      } else {
        statusText = 'Vous avez manqué le cours';
        statusColor = errorColor;
        statusIcon = Icons.error;
      }
    } else {
      statusText = 'Cours à venir';
      statusColor = primaryColor;
      statusIcon = Icons.schedule;
    }

    String formattedDate = DateFormat('dd/MM/yyyy').format(lesson.date);
    String formattedTime = '${lesson.startTime.format(context)} - ${lesson.endTime.format(context)}';
    String teacherInitials = lesson.teachers.isNotEmpty
        ? '${lesson.teachers.first.firstname[0].toUpperCase()}${lesson.teachers.first.lastname[0].toUpperCase()}'
        : '';

    String formattedTitle = lesson.title[0].toUpperCase() + lesson.title.substring(1).toLowerCase();
    String formattedTeacher = lesson.teachers.isNotEmpty
        ? '${lesson.teachers.first.firstname[0].toUpperCase()}${lesson.teachers.first.firstname.substring(1).toLowerCase()} ${lesson.teachers.first.lastname[0].toUpperCase()}${lesson.teachers.first.lastname.substring(1).toLowerCase()}'
        : 'Aucun enseignant assigné';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Card(
          color: cardBgColor,
          margin: EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(6),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedTitle,
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey[700],
                            child: Text(
                              teacherInitials,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            formattedTeacher,
                            style: TextStyle(color: Color(0xFF9C9B9B)),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            child: Image.asset("assets/icons/clock.png", width: 14, height: 14, color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(width: 16),
                          Container(
                            child: Image.asset("assets/icons/calendar.png", width: 14, height: 14, color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildBottomNavBar() {
    return SafeArea(
      child: Container(
        height: 48,
        width: 50,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.fromLTRB(100, 0, 100, 0),
        decoration: BoxDecoration(
          color: const Color(0xFF0B121F).withOpacity(0.8),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Image.asset('assets/icons/home.png', width: 24, height: 24, color: Colors.white),
              onPressed: () {
                if (user != null && user!.roles == 'teacher') {
                  Navigator.pushReplacementNamed(context, '/teacher');
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
            IconButton(
              icon: Image.asset("assets/icons/code.png", width: 24, height: 24, color: Colors.white),
              onPressed: () {
                _showCodePopup(context);
              },
            ),
            IconButton(
              icon: Image.asset("assets/icons/user.png", width: 24, height: 24, color: Colors.white),
              onPressed: () {
                // Add functionality for user icon if needed
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCodePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141B25),
          title: Text('Entrez le code', style: TextStyle(color: Colors.white)),
          content: CodeInputFields(
            onSubmit: (sessionToken) {
              _submitCode(sessionToken);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  String _collectSessionToken() {
    return _CodeInputFieldsState().collectSessionToken();
  }

  void _submitCode(String sessionToken) async {
    if (currentLessons.isEmpty) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showNoOngoingLessonsDialog();
          }
        });
      }
      return;
    }

    final lessonId = currentLessons.first.id;

    // Log the lesson and its ID to the console for debugging
    print('Lesson ID: $lessonId');
    print('User ID: ${user!.id}');
    print('Session Token: $sessionToken');

    // If the lessonId is not defined, showNoOnGoingLessonsDialog
    if (lessonId == null || lessonId.isEmpty) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showNoOngoingLessonsDialog();
          }
        });
      }
      return;
    }

    if (sessionToken.isEmpty) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showNoOngoingLessonsDialog();
          }
        });
      }
    }

    final body = jsonEncode({
      'sessionToken': sessionToken,
      'lessonId': lessonId,
    });

    try {
      final String? apiBaseUrl = dotenv.env['API_BASE_URL'];
      final String apiUrl = '$apiBaseUrl/api/student/badge/${user!.id}';
      if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
        throw Exception('API_BASE_URL is not defined in .env');
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        _updatePresenceStatus(lessonId);
      } else {
        _showErrorDialog('Code invalide');
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la soumission du code');
    }
  }

  void _updatePresenceStatus(String lessonId) {
    setState(() {
      for (var lesson in currentLessons) {
        if (lesson.id == lessonId) {
          for (var i = 0; i < lesson.students.length; i++) {
            var student = lesson.students[i];
            if (student.firstname.toLowerCase() == user!.firstname.toLowerCase() &&
                student.lastname.toLowerCase() == user!.lastname.toLowerCase()) {
              lesson.students[i] = Student(
                id: student.id,
                firstname: student.firstname,
                lastname: student.lastname,
                isPresent: true,
              );
            }
          }
        }
      }
    });
  }

  void _showNoOngoingLessonsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141B25), // Match the home page background color
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.yellow),
              SizedBox(width: 8),
              Text('Attention', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            "Vous n'avez pas de cours actuellement.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                return;
              },
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141B25), // Match the home page background color
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.yellow),
              SizedBox(width: 8),
              Text('Attention', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                return;
              },
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class CodeInputFields extends StatefulWidget {
  final Function(String) onSubmit;

  CodeInputFields({required this.onSubmit});

  @override
  _CodeInputFieldsState createState() => _CodeInputFieldsState();
}

class _CodeInputFieldsState extends State<CodeInputFields> {
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());
  FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Automatically focus the first text field when the popup is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  String collectSessionToken() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 4) {
        _focusNodes[index + 1].requestFocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _onKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final LogicalKeyboardKey key = event.logicalKey;
      for (int index = 0; index < _controllers.length; index++) {
        if (_focusNodes[index].hasFocus) {
          if (key == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
              _controllers[index - 1].clear();
            }
          }
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _keyboardFocusNode,
      onKey: (_, event) {
        _onKeyPress(event);
        return KeyEventResult.handled;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return Container(
                width: 40,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.text,
                  cursorColor: Color(0xFF00796B), // Color of the text cursor
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A), // Darker background color
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00796B), width: 2.0),
                    ),
                  ),
                  onChanged: (value) => _onChanged(value, index),
                ),
              );
            }),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final sessionToken = collectSessionToken();
              widget.onSubmit(sessionToken);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}