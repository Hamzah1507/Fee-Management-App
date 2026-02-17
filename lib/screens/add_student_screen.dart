import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _feesController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  // ✅ SAVE TO FIRESTORE (PRODUCTION)
  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final studentsRef = FirebaseFirestore.instance.collection('students');

      final docRef = studentsRef.doc();

      final student = Student(
        id: docRef.id,
        name: _nameController.text.trim(),
        course: _courseController.text.trim(),
        totalFees: int.tryParse(_feesController.text.trim()) ?? 0,
        paidFees: 0,
        createdAt: DateTime.now(),
      );

      await docRef.set({
        ...student.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully')),
        );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ⭐ ICON
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 44,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 24),

                // NAME
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter student name'
                      : null,
                ),

                const SizedBox(height: 16),

                // COURSE
                TextFormField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    prefixIcon: Icon(Icons.menu_book_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter course'
                      : null,
                ),

                const SizedBox(height: 16),

                // FEES
                TextFormField(
                  controller: _feesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Fees',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter fees amount'
                      : null,
                ),

                const SizedBox(height: 28),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveStudent,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Student',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
