import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarViewScreen extends StatefulWidget {
  @override
  _CalendarViewScreenState createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, int> _lessonsPerDay = {};
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadLessons();
  }

  void _loadLessons() {
    // Simulate loading lessons data
    setState(() {
      _lessonsPerDay = {
        DateTime(_selectedDate.year, _selectedDate.month, 1): 2,
        DateTime(_selectedDate.year, _selectedDate.month, 3): 1,
        DateTime(_selectedDate.year, _selectedDate.month, 5): 3,
        // Add more data as needed
      };
    });
  }

  void _onPageChanged(int pageIndex) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + pageIndex);
      _loadLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar View'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _pageController.previousPage(duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
                },
              ),
              Text(
                DateFormat.yMMMM().format(_selectedDate),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  _pageController.nextPage(duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
                },
              ),
            ],
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, pageIndex) {
                final date = DateTime(_selectedDate.year, _selectedDate.month + pageIndex);
                final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
                final firstDayOfMonth = DateTime(date.year, date.month, 1);
                final startingWeekday = firstDayOfMonth.weekday;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemCount: daysInMonth + startingWeekday - 1,
                  itemBuilder: (context, index) {
                    if (index < startingWeekday - 1) {
                      return Container();
                    } else {
                      final day = index - startingWeekday + 2;
                      final dayDate = DateTime(date.year, date.month, day);
                      final lessonCount = _lessonsPerDay[dayDate] ?? 0;

                      return Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day.toString(),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            if (lessonCount > 0)
                              Text(
                                '$lessonCount lessons',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}