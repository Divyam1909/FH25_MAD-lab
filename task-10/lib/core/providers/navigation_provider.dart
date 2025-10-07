import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationProvider with ChangeNotifier {
  static const String _navPrefsKey = 'nav_items';
  
  // All available features
  static const List<NavItem> allFeatures = [
    NavItem(
      id: 'home',
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      index: 0,
    ),
    NavItem(
      id: 'notes',
      label: 'Notes',
      icon: Icons.note_alt_outlined,
      selectedIcon: Icons.note_alt,
      index: 1,
    ),
    NavItem(
      id: 'deadlines',
      label: 'Deadlines',
      icon: Icons.radar_outlined,
      selectedIcon: Icons.radar,
      index: 2,
    ),
    NavItem(
      id: 'whisper',
      label: 'Whisper',
      icon: Icons.forum_outlined,
      selectedIcon: Icons.forum,
      index: 3,
    ),
    NavItem(
      id: 'split',
      label: 'Split',
      icon: Icons.payments_outlined,
      selectedIcon: Icons.payments,
      index: 4,
    ),
    NavItem(
      id: 'timer',
      label: 'Timer',
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
      index: 5,
    ),
    NavItem(
      id: 'grades',
      label: 'Grades',
      icon: Icons.grade_outlined,
      selectedIcon: Icons.grade,
      index: 6,
    ),
    NavItem(
      id: 'timetable',
      label: 'Timetable',
      icon: Icons.schedule_outlined,
      selectedIcon: Icons.schedule,
      index: 7,
    ),
    NavItem(
      id: 'attendance',
      label: 'Attendance',
      icon: Icons.how_to_reg_outlined,
      selectedIcon: Icons.how_to_reg,
      index: 8,
    ),
  ];

  // Default navigation items (Home is always first)
  List<NavItem> _navItems = [
    allFeatures[0], // Home
    allFeatures[1], // Notes
    allFeatures[2], // Deadlines
    allFeatures[4], // Split
  ];

  List<NavItem> get navItems => _navItems;

  NavigationProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_navPrefsKey);
    
    if (savedIds != null && savedIds.isNotEmpty) {
      // Ensure Home is always first
      if (!savedIds.contains('home')) {
        savedIds.insert(0, 'home');
      } else if (savedIds.first != 'home') {
        savedIds.remove('home');
        savedIds.insert(0, 'home');
      }
      
      // Limit to 4 items
      if (savedIds.length > 4) {
        savedIds.removeRange(4, savedIds.length);
      }
      
      _navItems = savedIds
          .map((id) => allFeatures.firstWhere((f) => f.id == id))
          .toList();
      
      notifyListeners();
    }
  }

  Future<void> updateNavItems(List<NavItem> items) async {
    // Ensure Home is always first
    if (items.isEmpty || items.first.id != 'home') {
      items.insert(0, allFeatures.first);
    }
    
    // Limit to 4 items
    if (items.length > 4) {
      items = items.sublist(0, 4);
    }
    
    _navItems = items;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _navPrefsKey,
      items.map((item) => item.id).toList(),
    );
    
    notifyListeners();
  }

  bool isInNavBar(int screenIndex) {
    return _navItems.any((item) => item.index == screenIndex);
  }

  int? getNavBarIndex(int screenIndex) {
    final navIndex = _navItems.indexWhere((item) => item.index == screenIndex);
    return navIndex >= 0 ? navIndex : null;
  }
}

class NavItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int index;

  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.index,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

