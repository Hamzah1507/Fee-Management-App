import 'package:flutter/material.dart';
import '../models/student.dart';
import 'collect_fee_screen.dart';
import 'payment_history_screen.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Student student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Details'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ NAME
            Text(
              student.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // ✅ COURSE
            Text(
              'Course: ${student.course}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // ✅ FEES SUMMARY CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _feeRow('Total Fees', student.totalFees, Colors.black),
                    const SizedBox(height: 8),
                    _feeRow('Paid Fees', student.paidFees, Colors.green),
                    const SizedBox(height: 8),
                    _feeRow('Pending Fees', student.pendingFees, Colors.red),
                  ],
                ),
              ),
            ),

            const Spacer(),

            const SizedBox(height: 12),

            // ✅ VIEW PAYMENT HISTORY
            const SizedBox(height: 12),

            // ✅ VIEW PAYMENT HISTORY
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentHistoryScreen(student: student),
                    ),
                  );
                },
                child: const Text('View Payment History'),
              ),
            ),

            // ✅ COLLECT FEE BUTTON (we wire next step)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CollectFeeScreen(student: student),
                    ),
                  );
                },
                child: const Text('Collect Fee'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feeRow(String title, int amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          '₹$amount',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
