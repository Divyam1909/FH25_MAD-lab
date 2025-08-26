import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/encryption_service.dart';
import 'services/attack_service.dart';
import 'services/benchmark_service.dart';
import 'models/app_state.dart';

void main() {
  runApp(const CybersecurityLabApp());
}

class CybersecurityLabApp extends StatelessWidget {
  const CybersecurityLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        Provider(create: (_) => EncryptionService()),
        Provider(create: (_) => AttackService()),
        Provider(create: (_) => BenchmarkService()),
      ],
      child: MaterialApp(
        title: 'Cybersecurity Lab',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1A1A),
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF1A1A1A),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(const Color(0xFF00FF41)),
              foregroundColor: MaterialStatePropertyAll(Colors.black),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )),
            ),
          ),
        ),
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}