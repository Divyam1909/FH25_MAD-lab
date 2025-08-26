import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          width: 250,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            border: Border(
              right: BorderSide(
                color: Color(0xFF00FF41),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      size: 48,
                      color: const Color(0xFF00FF41),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'CYBER LAB',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00FF41),
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      'Security Testing Suite',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF333333)),
              
              // Navigation Items
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      _buildNavItem(
                        icon: Icons.upload_file,
                        title: 'Upload Code',
                        index: 0,
                        isSelected: appState.currentIndex == 0,
                        onTap: () => appState.setCurrentIndex(0),
                      ),
                      _buildNavItem(
                        icon: Icons.play_circle,
                        title: 'Test Code',
                        index: 1,
                        isSelected: appState.currentIndex == 1,
                        onTap: () => appState.setCurrentIndex(1),
                      ),
                      _buildNavItem(
                        icon: Icons.analytics,
                        title: 'Metrics',
                        index: 2,
                        isSelected: appState.currentIndex == 2,
                        onTap: () => appState.setCurrentIndex(2),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Divider(color: Color(0xFF333333)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00FF41),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'System Online',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00FF41).withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: const Color(0xFF00FF41), width: 1)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF00FF41) : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00FF41) : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}