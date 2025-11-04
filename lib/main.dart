import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/response_screen.dart';
import 'screens/threat_analysis_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final provider = AppProvider();
        provider.initializeSharedContent();
        return provider;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UnPhishy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          // Primary colors
          primary: Color(0xFF66CBD2),           // Soft teal
          onPrimary: Colors.white,              // White text on primary
          primaryContainer: Color(0xFFC2F9F6),  // Light mint container
          onPrimaryContainer: Color(0xFF003A3D), // Dark text on container
          
          // Secondary colors
          secondary: Color(0xFF66CBD2),         // Same as primary for consistency
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFC2F9F6),
          onSecondaryContainer: Color(0xFF003A3D),
          
          // Surface colors
          surface: Colors.white,                // Pure white background
          onSurface: Color(0xFF2D1B1B),         // Dark brown text
          surfaceContainerHighest: Color(0xFFC2F9F6),    // Light mint variant
          onSurfaceVariant: Color(0xFF003A3D),  // Dark teal text
          
          // Error colors (keeping default but adjusted)
          error: Color(0xFFBA1A1A),
          onError: Colors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF410002),
          
          // Outline and other colors
          outline: Color(0xFF66CBD2),           // Soft teal outline
          outlineVariant: Color(0xFFC2F9F6),    // Light mint outline
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF2D1B1B),
          onInverseSurface: Color(0xFFF6D5CC),
          inversePrimary: Color(0xFFC2F9F6),
        ),
        
        // Custom component themes
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF66CBD2),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Color(0x1A000000),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF66CBD2),
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: Color(0x33000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Color(0xFF66CBD2),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Color(0x33000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          ),
        ),
        
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: Color(0x1A000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          margin: EdgeInsets.all(8),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF66CBD2), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF66CBD2), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF66CBD2), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF66CBD2)),
          hintStyle: TextStyle(color: Color(0xFF66CBD2).withValues(alpha: 0.7)),
        ),
        
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF66CBD2),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/response': (context) => const ResponseScreen(),
        '/threat-analysis': (context) => const ThreatAnalysisScreen(),
      },
    );
  }
}