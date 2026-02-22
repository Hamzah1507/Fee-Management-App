import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _navy    = Color(0xFF003087);
  static const _accent  = Color(0xFF4F6EF7);
  static const _textSub = Color(0xFF8A94A6);
  static const _primary = Color(0xFF1A1F36);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ No animation controller needed — use TweenAnimationBuilder once
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
              child: Container(
                width: double.infinity,
                height: h * .52,
                decoration: const BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Color(0x26000000), blurRadius: 20, offset: Offset(0, 8)),
                        ],
                      ),
                      child: Image.asset('assets/images/icon.png',
                          height: 72, width: 72, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 28),
                    const Text('Fees Manager',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                    const SizedBox(height: 8),
                    const Text('GLS UNIVERSITY',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2.5)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Fee Management System',
                          style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: .5)),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(opacity: value, child: child),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome! 👋',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _primary, letterSpacing: -.4)),
                      const SizedBox(height: 4),
                      const Text('Sign in or create an account\nto start managing fees.',
                          style: TextStyle(fontSize: 13.5, color: _textSub, height: 1.5)),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: Color(0x664F6EF7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          child: const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _accent,
                            side: const BorderSide(color: Color(0x664F6EF7), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Create Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text('Promoted by Gujarat Law Society Since 1927',
                            style: TextStyle(fontSize: 10.5, color: _textSub.withOpacity(.6))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}