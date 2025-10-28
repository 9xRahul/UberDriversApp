
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uberdriverapp/screens/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drivers App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'MontserratRegular',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.white, // Text and icon color
          secondary: Colors.grey, // Accent color
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900], // Button color
            foregroundColor: Colors.white, // Text color
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
