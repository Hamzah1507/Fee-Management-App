import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import 'add_student_screen.dart';
import 'student_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _userName = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimController;

  static const _primary = Color(0xFF1A1F36);
  static const _accent  = Color(0xFF4F6EF7);
  static const _success = Color(0xFF00C48C);
  static const _warning = Color(0xFFFFA940);
  static const _danger  = Color(0xFFFF5B5B);
  static const _surface = Color(0xFFFFFFFF);
  static const _bg      = Color(0xFFF4F6FC);
  static const _textSub = Color(0xFF8A94A6);

  // ✅ Single stream cached — no duplicate Firestore calls
  late final Stream<QuerySnapshot> _studentsStream;

  // ✅ Cached box decorations — not rebuilt every frame
  static final _cardDecoration = BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Color(0x121A1F36),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  static final _searchDecoration = BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Color(0x0F1A1F36),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _studentsStream = FirebaseFirestore.instance
        .collection('students')
        .orderBy('createdAt', descending: true)
        .snapshots();

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        _userName = (doc.data()?['name'] ?? '').toString().trim();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: _studentsStream, // ✅ single stream
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _searchBar(),
                  if (snapshot.hasData) _dashboard(docs),
                  _sectionLabel('Students'),
                  Expanded(child: _studentList(snapshot, docs)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabAnimController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          elevation: 4,
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () => Navigator.pushNamed(context, '/add-student'),
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
          label: const Text(
            'Add Student',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: .3),
          ),
        ),
      ),
    );
  }

  Widget _studentList(AsyncSnapshot<QuerySnapshot> snapshot, List<QueryDocumentSnapshot> docs) {
    if (snapshot.connectionState == ConnectionState.waiting && docs.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (docs.isEmpty) return _emptyState();

    final q = _searchQuery.toLowerCase();
    final filtered = q.isEmpty
        ? docs
        : docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['name'] ?? '').toString().toLowerCase().contains(q) ||
                   (data['course'] ?? '').toString().toLowerCase().contains(q);
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: _textSub.withOpacity(.5)),
            const SizedBox(height: 12),
            const Text('No matching students', style: TextStyle(color: _textSub)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: filtered.length,
      // ✅ Cache extent improves scroll performance
      cacheExtent: 300,
      itemBuilder: (context, index) {
        final doc = filtered[index];
        final student = Student.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        return RepaintBoundary( // ✅ isolates each card repaint
          child: _studentCard(context, student),
        );
      },
    );
  }

  Widget _buildHeader() {
    final displayName = _userName.isNotEmpty ? _userName.split(' ').first : 'There';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $displayName 👋',
                style: const TextStyle(fontSize: 13.5, color: _textSub, fontWeight: FontWeight.w500, letterSpacing: .3),
              ),
              const SizedBox(height: 2),
              const Text('Fees Manager',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _primary, letterSpacing: -.5)),
            ],
          ),
          const Spacer(),
          _headerBtn(Icons.admin_panel_settings_rounded, const Color(0xFFFFA940), '/admin'),
          const SizedBox(width: 10),
          _headerBtn(Icons.bar_chart_rounded, _accent, '/analytics'),
          const SizedBox(width: 10),
          _headerBtn(Icons.person_rounded, const Color(0xFF003087), '/profile'),
        ],
      ),
    );
  }

  Widget _headerBtn(IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: _searchDecoration, // ✅ cached
        child: TextField(
          controller: _searchController,
          autofocus: false,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14.5, color: _primary, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Search by name or course…',
            hintStyle: const TextStyle(color: _textSub, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: _textSub, size: 22),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: _textSub, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dashboard(List<QueryDocumentSnapshot> docs) {
    int totalFees = 0, totalPaid = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalFees += (data['totalFees'] ?? 0) as int;
      totalPaid += (data['paidFees'] ?? 0) as int;
    }
    final pending  = totalFees - totalPaid;
    final progress = totalFees > 0 ? (totalPaid / totalFees).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3A56E8), Color(0xFF6A3DE8)],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(color: Color(0x594F6EF7), blurRadius: 24, offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Total Collected',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: .3)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text('${docs.length} Students',
                          style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('₹${_fmt(totalPaid)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${(progress * 100).toStringAsFixed(1)}% of ₹${_fmt(totalFees)} collected',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _miniStat('Total Fees', '₹${_fmt(totalFees)}', Icons.receipt_long_rounded, const Color(0xFFEEF2FF), _accent)),
              const SizedBox(width: 12),
              Expanded(child: _miniStat('Pending', '₹${_fmt(pending)}', Icons.hourglass_top_rounded, const Color(0xFFFFF3F3), _danger)),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  Widget _miniStat(String label, String value, IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D1A1F36), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11.5, color: _textSub, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primary, letterSpacing: -.2)),
    );
  }

  Color _statusColor(Student s) {
    if (s.pendingFees == 0) return _success;
    if (s.isOverdue) return _danger;
    if (s.paidFees == 0) return _danger;
    return _warning;
  }

  String _statusText(Student s) {
    if (s.pendingFees == 0) return 'Paid';
    if (s.isOverdue) return 'Overdue';
    if (s.paidFees == 0) return 'Pending';
    return 'Partial';
  }

  IconData _statusIcon(Student s) {
    if (s.pendingFees == 0) return Icons.check_circle_rounded;
    if (s.isOverdue) return Icons.warning_rounded;
    if (s.paidFees == 0) return Icons.cancel_rounded;
    return Icons.timelapse_rounded;
  }

  Widget _studentCard(BuildContext context, Student student) {
    final color    = _statusColor(student);
    final pct      = student.totalFees > 0 ? (student.paidFees / student.totalFees).clamp(0.0, 1.0) : 0.0;
    final initials = student.name.isNotEmpty
        ? student.name.trim().split(' ').take(2).map((e) => e[0].toUpperCase()).join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration, // ✅ cached static decoration
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StudentDetailsScreen(student: student)),
          ),
          onLongPress: () => _confirmDelete(context, student),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0x1A4F6EF7),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(initials,
                            style: const TextStyle(fontWeight: FontWeight.w800, color: _accent, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _primary)),
                          const SizedBox(height: 2),
                          Text(student.course,
                              style: const TextStyle(fontSize: 12.5, color: _textSub, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(student), size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(_statusText(student),
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color, letterSpacing: .2)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (student.isOverdue) ...[
                  _dueBanner(
                    '${student.daysOverdue} day${student.daysOverdue == 1 ? '' : 's'} overdue — Due: ${_fmtDate(student.dueDate!)}',
                    _danger, Icons.alarm_rounded,
                  ),
                ] else if (student.dueDate != null && student.pendingFees > 0) ...[
                  _dueBanner('Due: ${_fmtDate(student.dueDate!)}', _warning, Icons.calendar_today_rounded),
                ],
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${student.paidFees} paid',
                            style: const TextStyle(fontSize: 11.5, color: _textSub, fontWeight: FontWeight.w500)),
                        Text('₹${student.pendingFees} due',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xCCFF5B5B), fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFF0F2F8),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dueBanner(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Student', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${student.name}"? This action cannot be undone.',
            style: const TextStyle(color: _textSub, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _textSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('students').doc(student.id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Student deleted'),
          backgroundColor: _danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: const Color(0x144F6EF7), borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.school_rounded, size: 40, color: _accent),
          ),
          const SizedBox(height: 16),
          const Text('No students yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _primary)),
          const SizedBox(height: 6),
          const Text('Tap "Add Student" to get started.',
              style: TextStyle(color: _textSub, fontSize: 13.5)),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}