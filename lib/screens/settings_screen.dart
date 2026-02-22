import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart' show themeNotifier;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  bool _darkMode      = themeNotifier.isDark;
  bool _notifications = true;
  bool _emailAlerts   = false;
  bool _overdueAlerts = true;
  String _currency    = '₹ INR';
  String _dateFormat  = 'DD/MM/YYYY';

  static const _accent  = Color(0xFF4F6EF7);
  static const _danger  = Color(0xFFFF5B5B);
  static const _success = Color(0xFF00C48C);

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
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
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FC);
    final surface = isDark ? const Color(0xFF1A1F2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F36);
    final textSub = isDark ? const Color(0xFF8A94A6) : const Color(0xFF8A94A6);
    final divColor = isDark ? const Color(0xFF2A2F42) : const Color(0xFFF4F6FC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: textPrimary,
        centerTitle: true,
        title: Text('Settings',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Appearance ───────────────────────────────
            _sectionLabel('Appearance', textSub),
            const SizedBox(height: 12),
            _card(surface, [
              _switchTile(
                icon: Icons.dark_mode_rounded,
                iconBg: const Color(0xFF1A1F36),
                iconColor: Colors.white,
                title: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: _darkMode,
                textPrimary: textPrimary,
                textSub: textSub,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  themeNotifier.toggle(v);
                },
              ),
            ], divColor),

            const SizedBox(height: 20),

            // ── Notifications ────────────────────────────
            _sectionLabel('Notifications', textSub),
            const SizedBox(height: 12),
            _card(surface, [
              _switchTile(
                icon: Icons.notifications_rounded,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: _accent,
                title: 'Push Notifications',
                subtitle: 'Get alerts on your device',
                value: _notifications,
                textPrimary: textPrimary,
                textSub: textSub,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              Divider(height: 1, color: divColor, indent: 56),
              _switchTile(
                icon: Icons.warning_rounded,
                iconBg: const Color(0xFFFFF3F3),
                iconColor: _danger,
                title: 'Overdue Alerts',
                subtitle: 'Alert when fees are overdue',
                value: _overdueAlerts,
                textPrimary: textPrimary,
                textSub: textSub,
                onChanged: (v) => setState(() => _overdueAlerts = v),
              ),
              Divider(height: 1, color: divColor, indent: 56),
              _switchTile(
                icon: Icons.email_rounded,
                iconBg: const Color(0xFFF0FFF8),
                iconColor: _success,
                title: 'Email Alerts',
                subtitle: 'Receive email notifications',
                value: _emailAlerts,
                textPrimary: textPrimary,
                textSub: textSub,
                onChanged: (v) => setState(() => _emailAlerts = v),
              ),
            ], divColor),

            const SizedBox(height: 20),

            // ── Preferences ──────────────────────────────
            _sectionLabel('Preferences', textSub),
            const SizedBox(height: 12),
            _card(surface, [
              _dropdownTile(
                icon: Icons.currency_rupee_rounded,
                iconBg: const Color(0xFFF0FFF8),
                iconColor: _success,
                title: 'Currency',
                value: _currency,
                textPrimary: textPrimary,
                items: ['₹ INR', '\$ USD', '€ EUR', '£ GBP'],
                onChanged: (v) => setState(() => _currency = v!),
              ),
              Divider(height: 1, color: divColor, indent: 56),
              _dropdownTile(
                icon: Icons.calendar_today_rounded,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: _accent,
                title: 'Date Format',
                value: _dateFormat,
                textPrimary: textPrimary,
                items: ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
                onChanged: (v) => setState(() => _dateFormat = v!),
              ),
            ], divColor),

            const SizedBox(height: 20),

            // ── About ────────────────────────────────────
            _sectionLabel('About', textSub),
            const SizedBox(height: 12),
            _card(surface, [
              _infoTile(
                icon: Icons.info_outline_rounded,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: _accent,
                title: 'App Version',
                value: '1.0.0',
                textPrimary: textPrimary,
                textSub: textSub,
              ),
              Divider(height: 1, color: divColor, indent: 56),
              _infoTile(
                icon: Icons.school_rounded,
                iconBg: const Color(0xFFF0FFF8),
                iconColor: _success,
                title: 'Institution',
                value: 'GLS University',
                textPrimary: textPrimary,
                textSub: textSub,
              ),
              Divider(height: 1, color: divColor, indent: 56),
              _infoTile(
                icon: Icons.phone_android_rounded,
                iconBg: const Color(0xFFFFF3F3),
                iconColor: _danger,
                title: 'Built With',
                value: 'Flutter + Firebase',
                textPrimary: textPrimary,
                textSub: textSub,
              ),
            ], divColor),

            const SizedBox(height: 20),

            // ── Quick Links ──────────────────────────────
            _sectionLabel('Quick Links', textSub),
            const SizedBox(height: 12),
            _card(surface, [
              _tapTile(
                icon: Icons.currency_exchange_rounded,
                iconBg: const Color(0xFFF0FFF8),
                iconColor: _success,
                title: 'Live Currency Rates',
                textPrimary: textPrimary,
                textSub: textSub,
                onTap: () => Navigator.pushNamed(context, '/currency'),
              ),
            ], divColor),

            const SizedBox(height: 28),

            // ── Sign Out ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, Color color) => Text(
        label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1),
      );

  Widget _card(Color surface, List<Widget> children, Color divColor) =>
      Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(children: children),
      );

  Widget _switchTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Color textPrimary,
    required Color textSub,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary)),
              Text(subtitle,
                  style: TextStyle(fontSize: 11.5, color: textSub)),
            ],
          ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged, activeColor: _accent),
      ]),
    );
  }

  Widget _dropdownTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required Color textPrimary,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary)),
        ),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          dropdownColor: themeNotifier.isDark ? const Color(0xFF1A1F2E) : Colors.white,
          style: const TextStyle(
              fontSize: 13, color: _accent, fontWeight: FontWeight.w600),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ]),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required Color textPrimary,
    required Color textSub,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 13, color: textSub, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _tapTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Color textPrimary,
    required Color textSub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary)),
          ),
          Icon(Icons.chevron_right_rounded, color: textSub, size: 20),
        ]),
      ),
    );
  }
}