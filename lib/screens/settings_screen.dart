import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  // Settings state
  bool _darkMode        = false;
  bool _notifications   = true;
  bool _emailAlerts     = false;
  bool _overdueAlerts   = true;
  String _currency      = '₹ INR';
  String _dateFormat    = 'DD/MM/YYYY';

  // ── Design Tokens ───────────────────────────────────────────
  static const _primary = Color(0xFF1A1F36);
  static const _accent  = Color(0xFF4F6EF7);
  static const _danger  = Color(0xFFFF5B5B);
  static const _bg      = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);
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
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _primary,
        centerTitle: true,
        title: const Text('Settings',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Appearance ───────────────────────────────
            _sectionLabel('Appearance'),
            const SizedBox(height: 12),
            _settingsCard([
              _switchTile(
                icon: Icons.dark_mode_rounded,
                iconBg: const Color(0xFF1A1F36),
                iconColor: Colors.white,
                title: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: _darkMode,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  _showSnack(
                      'Dark mode ${v ? 'enabled' : 'disabled'} — coming soon!');
                },
              ),
            ]),

            const SizedBox(height: 20),

            // ── Notifications ────────────────────────────
            _sectionLabel('Notifications'),
            const SizedBox(height: 12),
            _settingsCard([
              _switchTile(
                icon: Icons.notifications_rounded,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: _accent,
                title: 'Push Notifications',
                subtitle: 'Get alerts on your device',
                value: _notifications,
                onChanged: (v) =>
                    setState(() => _notifications = v),
              ),
              _divider(),
              _switchTile(
                icon: Icons.warning_rounded,
                iconBg: const Color(0xFFFFF3F3),
                iconColor: _danger,
                title: 'Overdue Alerts',
                subtitle: 'Alert when fees are overdue',
                value: _overdueAlerts,
                onChanged: (v) =>
                    setState(() => _overdueAlerts = v),
              ),
              _divider(),
              _switchTile(
                icon: Icons.email_rounded,
                iconBg: const Color(0xFFF0FFF8),
                iconColor: _success,
                title: 'Email Alerts',
                subtitle: 'Receive email notifications',
                value: _emailAlerts,
                onChanged: (v) =>
                    setState(() => _emailAlerts = v),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Preferences ──────────────────────────────
            _sectionLabel('Preferences'),
            const SizedBox(height: 12),
            _settingsCard([
              _dropdownTile(
                icon: Icons.currency_rupee_rounded,
                iconBg: const Color(0xFFF0FFF8),
                iconColor: _success,
                title: 'Currency',
                value: _currency,
                items: ['₹ INR', '\$ USD', '€ EUR', '£ GBP'],
                onChanged: (v) =>
                    setState(() => _currency = v!),
              ),
              _divider(),
              _dropdownTile(
                icon: Icons.calendar_month_rounded,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: _accent,
                title: 'Date Format',
                value: _dateFormat,
                items: [
                  'DD/MM/YYYY',
                  'MM/DD/YYYY',
                  'YYYY-MM-DD'
                ],
                onChanged: (v) =>
                    setState(() => _dateFormat = v!),
              ),
            ]),

            const SizedBox(height: 20),

            // ── About ────────────────────────────────────
            _sectionLabel('About'),
            const SizedBox(height: 12),
            _settingsCard([
              _infoTile(
                icon: Icons.info_outline_rounded,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: _accent,
                title: 'App Version',
                value: '1.0.0',
              ),
              _divider(),
              _infoTile(
                icon: Icons.school_rounded,
                iconBg: const Color(0xFFF0FFF8),
                iconColor: _success,
                title: 'Institution',
                value: 'GLS University',
              ),
              _divider(),
              _infoTile(
                icon: Icons.code_rounded,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: _accent,
                title: 'Built With',
                value: 'Flutter + Firebase',
              ),
              _divider(),
              _tapTile(
                icon: Icons.privacy_tip_outlined,
                iconBg: const Color(0xFFFFFBF0),
                iconColor: const Color(0xFFFFA940),
                title: 'Privacy Policy',
                onTap: () => _showSnack('Opening Privacy Policy...'),
              ),
              _divider(),
              _tapTile(
                icon: Icons.help_outline_rounded,
                iconBg: const Color(0xFFF0FFF8),
                iconColor: _success,
                title: 'Help & Support',
                onTap: () => _showSnack('Opening Help & Support...'),
              ),
            ]),

            const SizedBox(height: 28),

            // ── Sign Out ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger.withOpacity(.08),
                  foregroundColor: _danger,
                  elevation: 0,
                  side: BorderSide(
                      color: _danger.withOpacity(.3),
                      width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
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

            Center(
              child: Text(
                'Promoted by Gujarat Law Society Since 1927',
                style: TextStyle(
                    fontSize: 11,
                    color: _textSub.withOpacity(.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _textSub,
          letterSpacing: .4));

  Widget _settingsCard(List<Widget> children) {
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

  Widget _divider() => Divider(
      height: 1,
      color: _bg,
      indent: 56,
      endIndent: 0);

  Widget _switchTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primary)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11.5, color: _textSub)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: _accent,
        ),
      ]),
    );
  }

  Widget _dropdownTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _primary)),
        ),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          style: const TextStyle(
              fontSize: 13,
              color: _accent,
              fontWeight: FontWeight.w600),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e, child: Text(e)))
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _primary)),
        ),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                color: _textSub,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _tapTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _primary)),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: _textSub, size: 20),
        ]),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}