import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  static const _navy    = Color(0xFF003087);
  static const _accent  = Color(0xFF4F6EF7);
  static const _danger  = Color(0xFFFF5B5B);
  static const _bg      = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);
  static const _primary = Color(0xFF1A1F36);
  static const _success = Color(0xFF00C48C);

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: _textSub, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: _textSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email =
        FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _primary,
        centerTitle: true,
        title: const Text('Profile',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          final name = snapshot.hasData && snapshot.data!.exists
              ? (snapshot.data!.data()
                      as Map<String, dynamic>)['name'] ??
                  'User'
              : 'User';

          final role = snapshot.hasData && snapshot.data!.exists
              ? (snapshot.data!.data()
                      as Map<String, dynamic>)['role'] ??
                  'admin'
              : 'admin';

          final initials = name
              .toString()
              .trim()
              .split(' ')
              .take(2)
              .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
              .join();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // ── Profile Hero Card ────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_navy, Color(0xFF1A4A9F)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _navy.withOpacity(.30),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(.15),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              role.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── App Info ─────────────────────────────
                _sectionLabel('App Information'),
                const SizedBox(height: 12),
                _infoCard([
                  _infoRow(Icons.school_rounded,
                      'Institution', 'GLS University'),
                  _infoRow(Icons.location_on_rounded,
                      'Location',
                      'Navrangpura, Ahmedabad'),
                  _infoRow(Icons.verified_user_rounded,
                      'System', 'Fee Management System'),
                  _infoRow(Icons.new_releases_rounded,
                      'Version', '1.0.0'),
                ]),

                const SizedBox(height: 20),

                // ── Account ──────────────────────────────
                _sectionLabel('Account'),
                const SizedBox(height: 12),
                _infoCard([
                  _infoRow(Icons.email_outlined,
                      'Email', email),
                  _infoRow(Icons.badge_outlined,
                      'User ID',
                      uid?.substring(0, 12).toUpperCase() ??
                          '—'),
                ]),

                const SizedBox(height: 20),

                // ── Quick Stats ──────────────────────────
                _sectionLabel('Quick Stats'),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('students')
                      .snapshots(),
                  builder: (context, snap) {
                    final total =
                        snap.data?.docs.length ?? 0;
                    final paid = snap.data?.docs
                            .where((d) {
                              final data = d.data()
                                  as Map<String, dynamic>;
                              return (data['paidFees'] ??
                                      0) >=
                                  (data['totalFees'] ?? 1);
                            })
                            .length ??
                        0;
                    return Row(children: [
                      Expanded(
                          child: _quickStat(
                              '$total',
                              'Total Students',
                              Icons.people_rounded,
                              const Color(0xFFEEF2FF),
                              _accent)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _quickStat(
                              '$paid',
                              'Fully Paid',
                              Icons.check_circle_rounded,
                              const Color(0xFFF0FFF8),
                              _success)),
                    ]);
                  },
                ),

                const SizedBox(height: 28),

                // ── Sign Out Button ──────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _danger.withOpacity(.08),
                      foregroundColor: _danger,
                      elevation: 0,
                      side: BorderSide(
                          color: _danger.withOpacity(.3),
                          width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14)),
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded,
                        size: 20),
                    label: const Text('Sign Out',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Promoted by Gujarat Law Society Since 1927',
                  style: TextStyle(
                      fontSize: 11,
                      color: _textSub.withOpacity(.6)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _textSub,
          letterSpacing: .4));

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _accent.withOpacity(.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: _textSub)),
              const SizedBox(height: 1),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _primary)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _quickStat(String value, String label,
      IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _primary)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10.5, color: _textSub)),
        ]),
      ]),
    );
  }
}