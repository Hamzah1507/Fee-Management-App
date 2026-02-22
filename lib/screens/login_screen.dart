import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _navy    = Color(0xFF003087);
  static const _accent  = Color(0xFF4F6EF7);
  static const _danger  = Color(0xFFFF5B5B);
  static const _bg      = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);
  static const _primary = Color(0xFF1A1F36);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, .06), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }
  
  bool _isValidEmail(String email) {
    return email.trim().toLowerCase().endsWith('@gmail.com') &&
        email.trim().length > '@gmail.com'.length;
  } 

  Future<void> _login() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please fill all fields', isError: true);
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnack('Please enter a valid email address', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await _authService.login(email: email, password: password);
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
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
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // ── Navy Header ──────────────────────────────
              Container(
                width: double.infinity,
                height: h * .42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF003087), Color(0xFF1A4AB0)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(44),
                    bottomRight: Radius.circular(44),
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.18),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset('assets/images/gls_logo.png',
                              height: 52, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 20),
                        const Text('Fees Manager',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.8)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 28, height: 1, color: Colors.white30),
                            const SizedBox(width: 8),
                            const Text('GLS UNIVERSITY',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 3)),
                            const SizedBox(width: 8),
                            Container(width: 28, height: 1, color: Colors.white30),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.13),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(.2), width: 1),
                          ),
                          child: const Text('Fee Management System',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Form ─────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome back! ',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: _primary,
                                  letterSpacing: -.5),
                            ),
                            TextSpan(
                              text: '👋',
                              style: TextStyle(fontSize: 22),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Sign in to continue managing fees',
                          style: TextStyle(
                              fontSize: 14,
                              color: _textSub,
                              height: 1.5)),
                      const SizedBox(height: 24),

                      _inputField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _textSub,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shadowColor: _accent.withOpacity(.35),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text('Sign In',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: .3)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ",
                              style: TextStyle(color: _textSub, fontSize: 13.5)),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text('Create Account',
                                style: TextStyle(
                                    color: _accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          '© Promoted by Gujarat Law Society Since 1927',
                          style: TextStyle(
                              fontSize: 10.5,
                              color: _textSub.withOpacity(.55)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w500, color: _primary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _textSub, fontSize: 14),
          prefixIcon: Icon(icon, color: _textSub, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}