import 'package:flutter/material.dart';
import 'package:jan_aushadhi_sarthak/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jan Aushadhi Sarthak',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        // Add responsive design considerations
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Ensure app uses full screen height on all devices
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const Splashscreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
