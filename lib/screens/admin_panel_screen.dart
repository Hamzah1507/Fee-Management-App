import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/payment.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  static const _navy    = Color(0xFF003087);
  static const _accent  = Color(0xFF4F6EF7);
  static const _success = Color(0xFF00C48C);
  static const _danger  = Color(0xFFFF5B5B);
  static const _warning = Color(0xFFFFA940);
  static const _bg      = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _primary = Color(0xFF1A1F36);
  static const _textSub = Color(0xFF8A94A6);

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _primary,
        centerTitle: true,
        title: const Text('Admin Panel',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .snapshots(),
        builder: (context, studentSnap) {
          final students = (studentSnap.data?.docs ?? [])
              .map((d) => Student.fromMap(
                  d.id, d.data() as Map<String, dynamic>))
              .toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('payments')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, paySnap) {
              final payments = (paySnap.data?.docs ?? [])
                  .map((d) => Payment.fromMap(
                      d.id, d.data() as Map<String, dynamic>))
                  .toList();

              return _buildContent(
                  context, students, payments, email);
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      List<Student> students,
      List<Payment> payments,
      String email) {
    // Compute stats
    final totalStudents = students.length;
    final totalFees =
        students.fold<int>(0, (s, e) => s + e.totalFees);
    final totalPaid =
        students.fold<int>(0, (s, e) => s + e.paidFees);
    final totalPending = totalFees - totalPaid;
    final overdueCount =
        students.where((s) => s.isOverdue).length;
    final fullyPaid =
        students.where((s) => s.pendingFees == 0).length;
    final collectionPct = totalFees > 0
        ? (totalPaid / totalFees * 100).toStringAsFixed(1)
        : '0.0';

    // Recent payments (last 5)
    final recentPayments = payments.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Admin Info Card ──────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_navy, Color(0xFF1A4A9F)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: _navy.withOpacity(.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fee Administrator',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(email,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('ADMIN ACCESS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                    ),
                  ],
                ),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // ── System Overview ──────────────────────────
          _sectionLabel('System Overview'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard(
                'Total Students', '$totalStudents',
                Icons.people_rounded,
                const Color(0xFFEEF2FF), _accent)),
            const SizedBox(width: 12),
            Expanded(child: _statCard(
                'Fully Paid', '$fullyPaid',
                Icons.check_circle_rounded,
                const Color(0xFFF0FFF8), _success)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard(
                'Overdue', '$overdueCount',
                Icons.warning_rounded,
                const Color(0xFFFFF3F3), _danger)),
            const SizedBox(width: 12),
            Expanded(child: _statCard(
                'Collection', '$collectionPct%',
                Icons.trending_up_rounded,
                const Color(0xFFFFFBF0), _warning)),
          ]),

          const SizedBox(height: 24),

          // ── Financial Summary ────────────────────────
          _sectionLabel('Financial Summary'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: _primary.withOpacity(.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3))],
            ),
            child: Column(children: [
              _finRow('Total Fee Structure',
                  '₹${_fmt(totalFees)}', _primary),
              const Divider(height: 20),
              _finRow('Total Collected',
                  '₹${_fmt(totalPaid)}', _success),
              const Divider(height: 20),
              _finRow('Total Pending',
                  '₹${_fmt(totalPending)}',
                  totalPending > 0 ? _danger : _success),
              const Divider(height: 20),
              _finRow('Total Payments',
                  '${payments.length} transactions', _accent),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Student Status Breakdown ─────────────────
          _sectionLabel('Student Status Breakdown'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: _primary.withOpacity(.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3))],
            ),
            child: Column(children: [
              _statusBar('Fully Paid', fullyPaid,
                  totalStudents, _success),
              const SizedBox(height: 12),
              _statusBar('Partial Payment',
                  totalStudents - fullyPaid - overdueCount,
                  totalStudents, _warning),
              const SizedBox(height: 12),
              _statusBar('Overdue', overdueCount,
                  totalStudents, _danger),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Recent Transactions ──────────────────────
          _sectionLabel('Recent Transactions'),
          const SizedBox(height: 12),

          if (recentPayments.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                  child: Text('No transactions yet',
                      style: TextStyle(color: _textSub))),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: _primary.withOpacity(.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3))],
              ),
              child: Column(
                children: recentPayments.asMap().entries.map((e) {
                  final idx = e.key;
                  final p = e.value;
                  final student = students.firstWhere(
                    (s) => s.id == p.studentId,
                    orElse: () => Student(
                        id: '', name: 'Unknown',
                        course: '', totalFees: 0,
                        paidFees: 0, createdAt: DateTime.now()),
                  );

                  return Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(.10),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              student.name.isNotEmpty
                                  ? student.name[0]
                                      .toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _accent,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(student.name,
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                      fontSize: 13.5,
                                      color: _primary)),
                              Text(
                                  'Sem ${p.semester} • ${p.method.toUpperCase()}',
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color: _textSub)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text('₹${p.amount}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _success,
                                    fontSize: 14)),
                            Text(_fmtDate(p.createdAt),
                                style: const TextStyle(
                                    fontSize: 10.5,
                                    color: _textSub)),
                          ],
                        ),
                      ]),
                    ),
                    if (idx < recentPayments.length - 1)
                      const Divider(height: 1, indent: 16),
                  ]);
                }).toList(),
              ),
            ),

          const SizedBox(height: 24),

          // ── Quick Actions ────────────────────────────
          _sectionLabel('Quick Actions'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _actionBtn(
                context,
                icon: Icons.person_add_rounded,
                label: 'Add Student',
                color: _accent,
                onTap: () => Navigator.pushNamed(
                    context, '/add-student'))),
            const SizedBox(width: 12),
            Expanded(child: _actionBtn(
                context,
                icon: Icons.bar_chart_rounded,
                label: 'Analytics',
                color: _success,
                onTap: () => Navigator.pushNamed(
                    context, '/analytics'))),
          ]),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _primary,
          letterSpacing: -.2));

  Widget _statCard(String label, String value,
      IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
            color: _primary.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 3))],
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
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
                fontSize: 10.5, color: _textSub)),
            Text(value, style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color)),
          ],
        )),
      ]),
    );
  }

  Widget _finRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(
            fontSize: 13.5, color: _textSub)),
        Text(value, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color)),
      ],
    );
  }

  Widget _statusBar(String label, int count,
      int total, Color color) {
    final pct = total > 0
        ? (count / total).clamp(0.0, 1.0)
        : 0.0;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _primary)),
          Text('$count / $total',
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700)),
        ],
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 6,
          backgroundColor: const Color(0xFFF0F2F8),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ]);
  }

  Widget _actionBtn(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: color.withOpacity(.3), width: 1.5),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color)),
        ]),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  String _fmtDate(DateTime d) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr',
        'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month]}';
  }
}