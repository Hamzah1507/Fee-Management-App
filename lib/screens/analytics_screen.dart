import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/payment.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const _primary = Color(0xFF1A1F36);
  static const _accent = Color(0xFF4F6EF7);
  static const _success = Color(0xFF00C48C);
  static const _warning = Color(0xFFFFA940);
  static const _danger = Color(0xFFFF5B5B);
  static const _bg = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _primary,
        centerTitle: true,
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, studentSnap) {
          if (studentSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }

          final students = (studentSnap.data?.docs ?? [])
              .map(
                (d) => Student.fromMap(d.id, d.data() as Map<String, dynamic>),
              )
              .toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('payments')
                .orderBy('createdAt', descending: false)
                .snapshots(),
            builder: (context, paySnap) {
              final payments = (paySnap.data?.docs ?? [])
                  .map(
                    (d) =>
                        Payment.fromMap(d.id, d.data() as Map<String, dynamic>),
                  )
                  .toList();

              return _buildContent(context, students, payments);
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
  ) {
    // ── Compute stats ────────────────────────────────────────
    final totalStudents = students.length;
    final totalFees = students.fold<int>(0, (s, e) => s + e.totalFees);
    final totalPaid = students.fold<int>(0, (s, e) => s + e.paidFees);
    final totalPending = totalFees - totalPaid;
    final collectionPct = totalFees > 0 ? (totalPaid / totalFees) : 0.0;
    final overdueCount = students.where((s) => s.isOverdue).length;
    final fullyPaid = students.where((s) => s.pendingFees == 0).length;

    // Course-wise breakdown
    final Map<String, int> courseFees = {};
    final Map<String, int> coursePaid = {};
    for (final s in students) {
      courseFees[s.course] = (courseFees[s.course] ?? 0) + s.totalFees;
      coursePaid[s.course] = (coursePaid[s.course] ?? 0) + s.paidFees;
    }

    // Monthly collection (last 6 months)
    final now = DateTime.now();
    final Map<String, int> monthly = {};
    for (var i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = _monthKey(m);
      monthly[key] = 0;
    }
    for (final p in payments) {
      final key = _monthKey(p.createdAt);
      if (monthly.containsKey(key)) {
        monthly[key] = (monthly[key] ?? 0) + p.amount;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Overview Cards ───────────────────────────────
          _sectionLabel('Overview'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Total Students',
                  '$totalStudents',
                  Icons.people_rounded,
                  const Color(0xFFEEF2FF),
                  _accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Fully Paid',
                  '$fullyPaid',
                  Icons.check_circle_rounded,
                  const Color(0xFFF0FFF8),
                  _success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Overdue',
                  '$overdueCount',
                  Icons.warning_rounded,
                  const Color(0xFFFFF3F3),
                  _danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Pending Amount',
                  '₹${_fmt(totalPending)}',
                  Icons.hourglass_top_rounded,
                  const Color(0xFFFFFBF0),
                  _warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Collection Rate ──────────────────────────────
          _sectionLabel('Collection Rate'),
          const SizedBox(height: 12),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Collected',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${_fmt(totalPaid)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 28,
                              sections: [
                                PieChartSectionData(
                                  value: collectionPct * 100,
                                  color: Colors.white,
                                  radius: 10,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: (1 - collectionPct) * 100,
                                  color: Colors.white.withOpacity(.2),
                                  radius: 10,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(collectionPct * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: collectionPct,
                    minHeight: 7,
                    backgroundColor: Colors.white.withOpacity(.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_fmt(totalPaid)} collected of ₹${_fmt(totalFees)} total',
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Monthly Bar Chart ────────────────────────────
          _sectionLabel('Monthly Collection'),
          const SizedBox(height: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last 6 Months',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: monthly.values.every((v) => v == 0)
                      ? const Center(
                          child: Text(
                            'No payment data yet',
                            style: TextStyle(color: _textSub),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY:
                                (monthly.values.reduce(
                                          (a, b) => a > b ? a : b,
                                        ) *
                                        1.3)
                                    .toDouble(),
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 44,
                                  getTitlesWidget: (v, _) => Text(
                                    '₹${_fmt(v.toInt())}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: _textSub,
                                    ),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) {
                                    final keys = monthly.keys.toList();
                                    final idx = v.toInt();
                                    if (idx < 0 || idx >= keys.length)
                                      return const SizedBox();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        keys[idx].split('-').first,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: _textSub,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: const Color(0xFFF0F2F8),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: monthly.values
                                .toList()
                                .asMap()
                                .entries
                                .map(
                                  (e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.toDouble(),
                                        color: _accent,
                                        width: 22,
                                        borderRadius: BorderRadius.circular(6),
                                        backDrawRodData:
                                            BackgroundBarChartRodData(
                                              show: true,
                                              toY:
                                                  (monthly.values.reduce(
                                                            (a, b) =>
                                                                a > b ? a : b,
                                                          ) *
                                                          1.3)
                                                      .toDouble(),
                                              color: const Color(0xFFF0F2F8),
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Course-wise Breakdown ────────────────────────
          _sectionLabel('Course-wise Breakdown'),
          const SizedBox(height: 12),
          if (courseFees.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('No data yet', style: TextStyle(color: _textSub)),
              ),
            )
          else
            ...courseFees.entries.map((e) {
              final course = e.key;
              final total = e.value;
              final paid = coursePaid[course] ?? 0;
              final pending = total - paid;
              final pct = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;
              final courseStudents = students
                  .where((s) => s.course == course)
                  .length;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 18,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: _primary,
                                ),
                              ),
                              Text(
                                '$courseStudents student${courseStudents == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: _textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(pct * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: pct == 1.0 ? _success : _accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF0F2F8),
                        valueColor: AlwaysStoppedAnimation(
                          pct == 1.0 ? _success : _accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Collected: ₹${_fmt(paid)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pending: ₹${_fmt(pending)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: pending > 0 ? _danger : _success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // ── Student Status Pie ───────────────────────────
          _sectionLabel('Student Status'),
          const SizedBox(height: 12),
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
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 30,
                      sections: [
                        if (fullyPaid > 0)
                          PieChartSectionData(
                            value: fullyPaid.toDouble(),
                            color: _success,
                            radius: 28,
                            showTitle: false,
                          ),
                        if (overdueCount > 0)
                          PieChartSectionData(
                            value: overdueCount.toDouble(),
                            color: _danger,
                            radius: 28,
                            showTitle: false,
                          ),
                        if (totalStudents - fullyPaid - overdueCount > 0)
                          PieChartSectionData(
                            value: (totalStudents - fullyPaid - overdueCount)
                                .toDouble(),
                            color: _warning,
                            radius: 28,
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendItem(_success, 'Fully Paid', fullyPaid),
                      const SizedBox(height: 10),
                      _legendItem(
                        _warning,
                        'Partial',
                        totalStudents - fullyPaid - overdueCount,
                      ),
                      const SizedBox(height: 10),
                      _legendItem(_danger, 'Overdue', overdueCount),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: _primary,
      letterSpacing: -.2,
    ),
  );

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color bg,
    Color color,
  ) {
    return Container(
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
                  label,
                  style: const TextStyle(fontSize: 11, color: _textSub),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: _textSub),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _primary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String _fmt(int v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  String _monthKey(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month]}-${d.year}';
  }
}
