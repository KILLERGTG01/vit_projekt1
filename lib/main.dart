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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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