import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String studentId;
  final int amount;
  final String method;
  final int semester; // NEW
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.method,
    required this.semester,
    required this.createdAt,
  });

  factory Payment.fromMap(String id, Map<String, dynamic> data) {
    return Payment(
      id: id,
      studentId: data['studentId'] ?? '',
      amount: data['amount'] ?? 0,
      method: data['method'] ?? 'cash',
      semester: data['semester'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'amount': amount,
      'method': method,
      'semester': semester,
      'createdAt': createdAt,
    };
  }
}