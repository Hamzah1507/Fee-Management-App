import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/payment.dart';
import '../services/receipt_service.dart';
import 'collect_fee_screen.dart';
import 'payment_history_screen.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Student student;
  const StudentDetailsScreen({super.key, required this.student});

  static const _primary = Color(0xFF1A1F36);
  static const _accent = Color(0xFF4F6EF7);
  static const _success = Color(0xFF00C48C);
  static const _danger = Color(0xFFFF5B5B);
  static const _bg = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);

  @override
  Widget build(BuildContext context) {
    final studentRef = FirebaseFirestore.instance
        .collection('students')
        .doc(student.id);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _primary,
        centerTitle: true,
        title: const Text(
          'Student Details',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: studentRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Student not found'));
          }
          final live = Student.fromMap(
            snapshot.data!.id,
            snapshot.data!.data() as Map<String, dynamic>,
          );
          return _buildContent(context, live);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Student s) {
    final pct = s.totalFees > 0
        ? (s.paidFees / s.totalFees).clamp(0.0, 1.0)
        : 0.0;
    final initials = s.name
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    Color statusColor;
    String statusText;
    if (s.pendingFees == 0) {
      statusColor = _success;
      statusText = 'Fully Paid';
    } else if (s.paidFees == 0) {
      statusColor = _danger;
      statusText = 'Not Paid';
    } else {
      statusColor = const Color(0xFFFFA940);
      statusText = 'Partial';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile Hero ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: _accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.course,
                        style: const TextStyle(fontSize: 13.5, color: _textSub),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Semester ${s.currentSemester}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Fee Summary Card ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3A56E8), Color(0xFF6A3DE8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(.30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fee Summary',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _summaryItem('Total', '₹${s.totalFees}', Colors.white),
                    _summaryItem(
                      'Paid',
                      '₹${s.paidFees}',
                      const Color(0xFF7EFFD4),
                    ),
                    _summaryItem(
                      'Pending',
                      '₹${s.pendingFees}',
                      const Color(0xFFFFADAD),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: Colors.white.withOpacity(.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(pct * 100).toStringAsFixed(1)}% of total fees collected',
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Quick Stats ───────────────────────────────────────
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('payments')
                .where('studentId', isEqualTo: s.id)
                .snapshots(),
            builder: (context, snap) {
              final count = snap.data?.docs.length ?? 0;
              final lastPay = snap.hasData && snap.data!.docs.isNotEmpty
                  ? (snap.data!.docs.first.data()
                            as Map<String, dynamic>)['createdAt']
                        as Timestamp?
                  : null;
              final lastDate = lastPay != null
                  ? _fmtDate(lastPay.toDate())
                  : '—';
              return Row(
                children: [
                  Expanded(
                    child: _quickStat(
                      Icons.receipt_long_rounded,
                      '$count',
                      'Transactions',
                      const Color(0xFFEEF2FF),
                      _accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickStat(
                      Icons.calendar_today_rounded,
                      lastDate,
                      'Last Payment',
                      const Color(0xFFF0FFF8),
                      _success,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Action Buttons ────────────────────────────────────
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
          const SizedBox(height: 12),

          // Collect Fee — primary
          _actionButton(
            context,
            icon: Icons.add_card_rounded,
            label: 'Collect Fee',
            bg: _accent,
            fg: Colors.white,
            border: _accent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CollectFeeScreen(student: s)),
            ),
          ),

          const SizedBox(height: 10),

          // View History
          _actionButton(
            context,
            icon: Icons.history_rounded,
            label: 'View Payment History',
            bg: _surface,
            fg: _primary,
            border: const Color(0xFFE2E6F0),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentHistoryScreen(student: s),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Generate last receipt
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('payments')
                .where('studentId', isEqualTo: s.id)
                .orderBy('createdAt', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snap) {
              final hasPayments = snap.hasData && snap.data!.docs.isNotEmpty;
              return _actionButton(
                context,
                icon: Icons.picture_as_pdf_rounded,
                label: 'Download Last Receipt',
                bg: const Color(0xFFFFF3F3),
                fg: _danger,
                border: _danger.withOpacity(.3),
                onTap: hasPayments
                    ? () async {
                        final doc = snap.data!.docs.first;
                        final payment = Payment.fromMap(
                          doc.id,
                          doc.data() as Map<String, dynamic>,
                        );
                        await ReceiptService.generateReceipt(
                          student: s,
                          payment: payment,
                        );
                      }
                    : null,
              );
            },
          ),

          const SizedBox(height: 10),

          // Full semester report
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('payments')
                .where('studentId', isEqualTo: s.id)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              final hasPayments = snap.hasData && snap.data!.docs.isNotEmpty;
              return _actionButton(
                context,
                icon: Icons.summarize_rounded,
                label: 'Full Semester Report (PDF)',
                bg: const Color(0xFFEEF2FF),
                fg: _accent,
                border: _accent.withOpacity(.3),
                onTap: hasPayments
                    ? () async {
                        final payments = snap.data!.docs
                            .map(
                              (doc) => Payment.fromMap(
                                doc.id,
                                doc.data() as Map<String, dynamic>,
                              ),
                            )
                            .toList();
                        await ReceiptService.generateSemesterReport(
                          student: s,
                          payments: payments,
                        );
                      }
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStat(
    IconData icon,
    String value,
    String label,
    Color bg,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: _textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    required Color border,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: onTap == null ? bg.withOpacity(.5) : bg,
          foregroundColor: fg,
          elevation: 0,
          side: BorderSide(color: border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
