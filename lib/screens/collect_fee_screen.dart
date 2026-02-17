import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/payment.dart';

class CollectFeeScreen extends StatefulWidget {
  final Student student;

  const CollectFeeScreen({super.key, required this.student});

  @override
  State<CollectFeeScreen> createState() => _CollectFeeScreenState();
}

class _CollectFeeScreenState extends State<CollectFeeScreen> {
  final _amountController = TextEditingController();
  String _method = 'cash';
  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _collectFee() async {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter valid amount')));
      return;
    }

    setState(() => _loading = true);

    try {
      final studentRef = FirebaseFirestore.instance
          .collection('students')
          .doc(widget.student.id);

      final paymentRef = FirebaseFirestore.instance
          .collection('payments')
          .doc();

      await studentRef.update({'paidFees': FieldValue.increment(amount)});

      // ✅ Save payment record
      final payment = Payment(
        id: paymentRef.id,
        studentId: widget.student.id,
        amount: amount,
        method: _method,
        createdAt: DateTime.now(),
      );

      await paymentRef.set(payment.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment collected')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.student.pendingFees;

    return Scaffold(
      appBar: AppBar(title: const Text('Collect Fee'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Pending display
            Card(
              child: ListTile(
                title: const Text('Pending Fees'),
                trailing: Text(
                  '₹$pending',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Amount field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Payment method
            DropdownButtonFormField<String>(
              value: _method,
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'upi', child: Text('UPI')),
                DropdownMenuItem(value: 'bank', child: Text('Bank')),
              ],
              onChanged: (v) => setState(() => _method = v!),
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            // ✅ Collect button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _collectFee,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Collect Fee'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
