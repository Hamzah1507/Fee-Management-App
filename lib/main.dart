import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_student_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Fees Management',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),

      // ── Named Routes ──────────────────────────────────────
      initialRoute: '/',
      routes: {
        '/':            (_) => const WelcomeScreen(),
        '/login':       (_) => const LoginScreen(),
        '/register':    (_) => const RegisterScreen(),
        '/home':        (_) => const HomeScreen(),
        '/add-student': (_) => const AddStudentScreen(),
        '/analytics':   (_) => const AnalyticsScreen(),
        '/profile':     (_) => const ProfileScreen(),
        '/settings':    (_) => const SettingsScreen(),
      },
    );
  }
}