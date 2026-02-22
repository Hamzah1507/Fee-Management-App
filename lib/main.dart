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
import 'screens/admin_panel_screen.dart';
import 'screens/currency_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ── Initialize Notifications ──────────────────────────
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  runApp(const MyApp());
}

// ── Smooth Fade+Slide Transition ──────────────────────────
Route<dynamic> _buildRoute(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: Curves.easeInOut),
      );
      final slideTween = Tween<Offset>(
        begin: const Offset(0.05, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        ),
      );
    },
  );
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
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      // ── Named Routes with Smooth Transitions ─────────────
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final routes = {
          '/':            const WelcomeScreen(),
          '/login':       const LoginScreen(),
          '/register':    const RegisterScreen(),
          '/home':        const HomeScreen(),
          '/add-student': const AddStudentScreen(),
          '/analytics':   const AnalyticsScreen(),
          '/profile':     const ProfileScreen(),
          '/settings':    const SettingsScreen(),
          '/admin':       const AdminPanelScreen(),
          '/currency':    const CurrencyScreen(),
        };

        final screen = routes[settings.name];
        if (screen != null) return _buildRoute(screen);
        return null;
      },
    );
  }
}