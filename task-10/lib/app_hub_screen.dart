import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/navigation_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/notes/screens/notes_list_screen.dart';
import 'features/deadlines/screens/deadlines_list_screen.dart';
import 'features/whisper/screens/whisper_screen.dart';
import 'features/split/screens/split_groups_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/study_timer/screens/study_timer_screen.dart';
import 'features/grade_calculator/screens/grade_calculator_screen.dart';
import 'features/timetable/screens/timetable_screen.dart';
import 'features/attendance/screens/attendance_screen.dart';

class AppHubScreen extends StatefulWidget {
  const AppHubScreen({super.key});

  @override
  State<AppHubScreen> createState() => _AppHubScreenState();
}

class _AppHubScreenState extends State<AppHubScreen> {
  int _currentScreenIndex = 0;
  DateTime? _lastBackPressed;

  List<Widget> get _allScreens => <Widget>[
    HomeScreen(onNavigate: (index) => _navigateToScreen(index)),
    const NotesListScreen(),
    const DeadlinesListScreen(),
    const WhisperScreen(),
    const SplitGroupsScreen(),
    const StudyTimerScreen(),
    const GradeCalculatorScreen(),
    const TimetableScreen(),
    const AttendanceScreen(),
  ];

  void _navigateToScreen(int screenIndex) {
    setState(() {
      _currentScreenIndex = screenIndex;
    });
  }

  void _onNavBarItemTapped(int navBarIndex, NavigationProvider navProvider) {
    final screenIndex = navProvider.navItems[navBarIndex].index;
    _navigateToScreen(screenIndex);
  }

  Future<bool> _onWillPop() async {
    // If not on home screen, navigate to home
    if (_currentScreenIndex != 0) {
      _navigateToScreen(0);
      return false; // Don't exit app
    }

    // On home screen, check for double-press to exit
    final now = DateTime.now();
    if (_lastBackPressed == null || 
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      // First press or timeout
      _lastBackPressed = now;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return false; // Don't exit app
    }
    
    // Second press within 2 seconds - exit app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Consumer<NavigationProvider>(
        builder: (context, navProvider, _) {
          final navBarIndex = navProvider.getNavBarIndex(_currentScreenIndex);
          final showNavBar = navBarIndex != null;

          return Scaffold(
            body: IndexedStack(
              index: _currentScreenIndex,
              children: _allScreens,
            ),
            bottomNavigationBar: showNavBar
                ? NavigationBar(
                    selectedIndex: navBarIndex,
                    onDestinationSelected: (index) =>
                        _onNavBarItemTapped(index, navProvider),
                    destinations: navProvider.navItems
                        .map((item) => NavigationDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: item.label,
                            ))
                        .toList(),
                  )
                : null,
            floatingActionButton: _currentScreenIndex == 0
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: const Icon(Icons.settings),
                  )
                : null,
          );
        },
      ),
    );
  }
}