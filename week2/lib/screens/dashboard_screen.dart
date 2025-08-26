import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/sidebar_navigation.dart';
import 'upload_screen.dart';
import 'test_screen.dart';
import 'metrics_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Row(
            children: [
              const SidebarNavigation(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A0A0A),
                        const Color(0xFF1A1A1A).withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: _buildCurrentScreen(appState.currentIndex),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentScreen(int index) {
    switch (index) {
      case 0:
        return const UploadScreen();
      case 1:
        return const TestScreen();
      case 2:
        return const MetricsScreen();
      default:
        return const UploadScreen();
    }
  }
}