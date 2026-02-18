import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String course;
  final int totalFees;
  final int paidFees;
  final int currentSemester;
  final DateTime createdAt;
  final DateTime? dueDate; // NEW

  Student({
    required this.id,
    required this.name,
    required this.course,
    required this.totalFees,
    required this.paidFees,
    this.currentSemester = 1,
    required this.createdAt,
    this.dueDate,
  });

  int get pendingFees => totalFees - paidFees;

  // Is overdue if due date passed AND still has pending fees
  bool get isOverdue {
    if (dueDate == null) return false;
    if (pendingFees <= 0) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // How many days overdue
  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate!).inDays;
  }

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      course: data['course'] ?? '',
      totalFees: data['totalFees'] ?? 0,
      paidFees: data['paidFees'] ?? 0,
      currentSemester: data['currentSemester'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course': course,
      'totalFees': totalFees,
      'paidFees': paidFees,
      'currentSemester': currentSemester,
      'createdAt': createdAt,
      'dueDate': dueDate,
    };
  }
}
