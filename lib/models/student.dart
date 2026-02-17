import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String course;
  final int totalFees;
  final int paidFees;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.course,
    required this.totalFees,
    required this.paidFees,
    required this.createdAt,
  });

  int get pendingFees => totalFees - paidFees;

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      course: data['course'] ?? '',
      totalFees: data['totalFees'] ?? 0,
      paidFees: data['paidFees'] ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course': course,
      'totalFees': totalFees,
      'paidFees': paidFees,
      'createdAt': createdAt,
    };
  }
}
