import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/payment.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final Student student;
  const PaymentHistoryScreen({super.key, required this.student});

  // ── Design Tokens ───────────────────────────────────────────
  static const _primary = Color(0xFF1A1F36);
  static const _accent  = Color(0xFF4F6EF7);
  static const _success = Color(0xFF00C48C);
  static const _bg      = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);

  @override
  Widget build(BuildContext context) {
    final paymentsRef = FirebaseFirestore.instance
        .collection('payments')
        .where('studentId', isEqualTo: student.id)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _primary,
        centerTitle: true,
        title: const Text(
          'Payment History',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: paymentsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _accent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState();
          }

          final payments = snapshot.data!.docs
              .map((doc) => Payment.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          // Running total
          final totalPaid =
              payments.fold<int>(0, (sum, p) => sum + p.amount);

          return Column(
            children: [
              // ── Summary Banner ─────────────────────────────
              _summaryBanner(payments.length, totalPaid),

              // ── Timeline List ──────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    return _paymentTile(
                        payments[index], index, payments.length);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SUMMARY BANNER
  // ═══════════════════════════════════════════════════════════
  Widget _summaryBanner(int count, int total) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A56E8), Color(0xFF6A3DE8)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Collected',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('₹$total',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const Text('Payments',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PAYMENT TILE  (timeline style)
  // ═══════════════════════════════════════════════════════════
  Widget _paymentTile(Payment p, int index, int total) {
    final isLast = index == total - 1;
    final methodInfo = _methodInfo(p.method);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline column ─────────────────────────────────
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: methodInfo.color.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(methodInfo.icon,
                    size: 17, color: methodInfo.color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E6F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // ── Card ────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount + method badge
                  Row(
                    children: [
                      Text(
                        '₹${p.amount}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: methodInfo.color.withOpacity(.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(methodInfo.icon,
                                size: 12,
                                color: methodInfo.color),
                            const SizedBox(width: 4),
                            Text(
                              methodInfo.label,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: methodInfo.color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Date + time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 12, color: _textSub),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(p.createdAt),
                        style: const TextStyle(
                            fontSize: 12,
                            color: _textSub,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════
  _MethodInfo _methodInfo(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return _MethodInfo(
            Icons.phone_android_rounded,
            const Color(0xFF7C3AED),
            'UPI');
      case 'bank':
      case 'bank transfer':
        return _MethodInfo(
            Icons.account_balance_rounded,
            const Color(0xFF0284C7),
            'Bank');
      default:
        return _MethodInfo(
            Icons.payments_rounded,
            _success,
            'Cash');
    }
  }

  String _formatDateTime(DateTime d) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = d.hour > 12 ? d.hour - 12 : d.hour;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min  = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month]} ${d.year}  •  $hour:$min $ampm';
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _accent.withOpacity(.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 36, color: _accent),
          ),
          const SizedBox(height: 16),
          const Text('No payments yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primary)),
          const SizedBox(height: 6),
          const Text('Payments will appear here once collected.',
              style: TextStyle(color: _textSub, fontSize: 13)),
        ],
      ),
    );
  }
}

class _MethodInfo {
  final IconData icon;
  final Color color;
  final String label;
  const _MethodInfo(this.icon, this.color, this.label);
}