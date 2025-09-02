import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Color Constants
  static const Color primaryGreen = Color(0xFF00FF41);
  static const Color primaryGreenDark = Color(0xFF00CC33);
  static const Color primaryGreenLight = Color(0xFF33FF66);
  
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFF2A2A2A);
  
  static const Color errorRed = Color(0xFFFF4444);
  static const Color warningOrange = Color(0xFFFF8800);
  static const Color successGreen = Color(0xFF00FF41);
  static const Color infoBlue = Color(0xFF00AAFF);
  
  static const Color textPrimary = Color(0xFF00FF41);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textDisabled = Color(0xFF666666);

  // Dark Theme Colors
  static const ColorScheme darkColors = ColorScheme.dark(
    primary: primaryGreen,
    primaryContainer: Color(0xFF004411),
    secondary: primaryGreenDark,
    secondaryContainer: Color(0xFF003311),
    surface: surfaceDark,
    background: backgroundDark,
    error: errorRed,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: textPrimary,
    onBackground: textPrimary,
    onError: Colors.white,
    outline: Color(0xFF444444),
    outlineVariant: Color(0xFF333333),
    inverseSurface: Color(0xFFE0E0E0),
    onInverseSurface: backgroundDark,
    inversePrimary: Color(0xFF004411),
  );

  // Light Theme Colors (for future use)
  static const ColorScheme lightColors = ColorScheme.light(
    primary: Color(0xFF004411),
    primaryContainer: Color(0xFFCCFFDD),
    secondary: Color(0xFF003311),
    secondaryContainer: Color(0xFFAAFFCC),
    surface: Colors.white,
    background: Color(0xFFF8F9FA),
    error: Color(0xFFD32F2F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF1A1A1A),
    onBackground: Color(0xFF1A1A1A),
    onError: Colors.white,
  );

  // Typography
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: textPrimary,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: textPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: textSecondary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: textPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: textPrimary,
    ),
  );

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColors,
      textTheme: textTheme,
      fontFamily: 'Roboto',
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryGreen,
          letterSpacing: 1.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 8,
        shadowColor: primaryGreen.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: primaryGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return textDisabled;
            }
            if (states.contains(MaterialState.hovered)) {
              return primaryGreenDark;
            }
            if (states.contains(MaterialState.pressed)) {
              return primaryGreenLight;
            }
            return primaryGreen;
          }),
          foregroundColor: const MaterialStatePropertyAll(Colors.black),
          elevation: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) return 12;
            if (states.contains(MaterialState.pressed)) return 6;
            return 8;
          }),
          shadowColor: MaterialStatePropertyAll(primaryGreen.withOpacity(0.4)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: primaryGreen,
                width: 1,
              ),
            ),
          ),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const MaterialStatePropertyAll(primaryGreen),
          overlayColor: MaterialStatePropertyAll(primaryGreen.withOpacity(0.1)),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const MaterialStatePropertyAll(primaryGreen),
          side: const MaterialStatePropertyAll(
            BorderSide(color: primaryGreen, width: 1),
          ),
          overlayColor: MaterialStatePropertyAll(primaryGreen.withOpacity(0.1)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryGreen.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: const TextStyle(color: primaryGreen),
        hintStyle: const TextStyle(color: textDisabled),
        helperStyle: const TextStyle(color: textSecondary),
        errorStyle: const TextStyle(color: errorRed),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGreen;
          }
          return textDisabled;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGreen.withOpacity(0.3);
          }
          return const Color(0xFF333333);
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGreen,
        inactiveTrackColor: const Color(0xFF333333),
        thumbColor: primaryGreen,
        overlayColor: primaryGreen.withOpacity(0.2),
        valueIndicatorColor: primaryGreen,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearTrackColor: Color(0xFF333333),
        circularTrackColor: Color(0xFF333333),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: primaryGreen,
        disabledColor: const Color(0xFF333333),
        labelStyle: const TextStyle(color: primaryGreen),
        side: const BorderSide(color: primaryGreen),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryGreen,
        unselectedLabelColor: textDisabled,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryGreen, width: 3),
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        surfaceTintColor: primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: primaryGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        titleTextStyle: const TextStyle(
          color: primaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      
      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDark,
        contentTextStyle: const TextStyle(color: textPrimary),
        actionTextColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: primaryGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      
      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: surfaceDark,
        surfaceTintColor: primaryGreen,
        width: 280,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: primaryGreen,
        selectedColor: primaryGreen,
        selectedTileColor: Color(0xFF002211),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: primaryGreen.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: primaryGreen,
        size: 24,
      ),
      
      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: Colors.black,
        size: 24,
      ),
    );
  }

  // Light Theme (for future use)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColors,
      textTheme: textTheme.apply(
        bodyColor: const Color(0xFF1A1A1A),
        displayColor: const Color(0xFF1A1A1A),
      ),
      fontFamily: 'Roboto',
      // Additional light theme configurations...
    );
  }

  // Cyber-specific styling utilities
  static BoxDecoration get cyberCardDecoration => BoxDecoration(
    color: surfaceDark,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: primaryGreen.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryGreen.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get glowingCardDecoration => BoxDecoration(
    color: surfaceDark,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: primaryGreen,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryGreen.withOpacity(0.3),
        blurRadius: 30,
        spreadRadius: 2,
      ),
    ],
  );

  static Gradient get cyberGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      backgroundDark,
      surfaceDark.withOpacity(0.3),
      primaryGreen.withOpacity(0.05),
    ],
  );

  static TextStyle get codeTextStyle => const TextStyle(
    fontFamily: 'Courier',
    fontSize: 12,
    color: primaryGreen,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle get terminalTextStyle => const TextStyle(
    fontFamily: 'Courier',
    fontSize: 13,
    color: primaryGreen,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration slowDuration = Duration(milliseconds: 500);

  // Responsive breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Status colors
  static const Map<String, Color> statusColors = {
    'success': successGreen,
    'error': errorRed,
    'warning': warningOrange,
    'info': infoBlue,
    'neutral': textSecondary,
  };

  // Security level colors
  static const Map<String, Color> securityLevelColors = {
    'critical': Color(0xFFFF0000),
    'high': Color(0xFFFF4444),
    'medium': warningOrange,
    'low': Color(0xFFFFAA00),
    'minimal': successGreen,
  };

  // Helper methods
  static Color getStatusColor(String status) {
    return statusColors[status.toLowerCase()] ?? textSecondary;
  }

  static Color getSecurityLevelColor(String level) {
    return securityLevelColors[level.toLowerCase()] ?? textSecondary;
  }

  static BoxShadow get defaultShadow => BoxShadow(
    color: primaryGreen.withOpacity(0.1),
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 2),
  );

  static BoxShadow get elevatedShadow => BoxShadow(
    color: primaryGreen.withOpacity(0.2),
    blurRadius: 16,
    spreadRadius: 2,
    offset: const Offset(0, 4),
  );
} 