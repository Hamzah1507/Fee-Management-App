import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/payment.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final Student student;

  const PaymentHistoryScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final paymentsRef = FirebaseFirestore.instance
        .collection('payments')
        .where('studentId', isEqualTo: student.id)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: paymentsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No payments yet'));
          }

          final payments = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final doc = payments[index];
              final payment = Payment.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.currency_rupee),
                  ),
                  title: Text('₹${payment.amount}'),
                  subtitle: Text(payment.method.toUpperCase()),
                  trailing: Text(
                    _formatDate(payment.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
