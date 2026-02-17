import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final student = Student(
      name: _nameController.text.trim(),
      course: _courseController.text.trim(),
      fees: int.tryParse(_feesController.text.trim()) ?? 0,
    );

    final box = Hive.box<Student>('students');
    await box.add(student);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ⭐ TOP ICON
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 44,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 24),

                // ⭐ NAME FIELD
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Enter student name'
                          : null,
                ),

                const SizedBox(height: 16),

                // ⭐ COURSE FIELD
                TextFormField(
                  controller: _courseController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    prefixIcon: Icon(Icons.menu_book_outlined),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Enter course'
                          : null,
                ),

                const SizedBox(height: 16),

                // ⭐ FEES FIELD
                TextFormField(
                  controller: _feesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fees Amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Enter fees amount'
                          : null,
                ),

                const SizedBox(height: 28),

                // ⭐ SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveStudent,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
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
