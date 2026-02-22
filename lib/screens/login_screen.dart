import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;

  static const _navy    = Color(0xFF003087);
  static const _accent  = Color(0xFF4F6EF7);
  static const _danger  = Color(0xFFFF5B5B);
  static const _bg      = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);
  static const _primary = Color(0xFF1A1F36);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please fill all fields', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await _authService.login(email: email, password: password);
      if (user != null && mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) _showSnack('Invalid email or password', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? _danger : _accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
                  decoration: const BoxDecoration(
                    color: _navy,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Image.asset('assets/images/gls_logo.png', height: 52, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 20),
                      const Text('Fees Manager',
                          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                      const SizedBox(height: 6),
                      const Text('GLS University — Fee Management System',
                          style: TextStyle(color: Colors.white60, fontSize: 12.5)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text('Welcome back!',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _primary, letterSpacing: -.4)),
                      const SizedBox(height: 4),
                      const Text('Sign in to continue managing fees',
                          style: TextStyle(fontSize: 13.5, color: _textSub)),
                      const SizedBox(height: 28),
                      _inputField(controller: _emailController, label: 'Email Address',
                          icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: _textSub, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(0x664F6EF7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: _textSub, fontSize: 13.5)),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/register'),
                            child: const Text('Create Account',
                                style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text('Promoted by Gujarat Law Society Since 1927',
                            style: TextStyle(fontSize: 11, color: _textSub.withOpacity(.7))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0D1A1F36), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _primary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _textSub, fontSize: 14),
          prefixIcon: Icon(icon, color: _textSub, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}