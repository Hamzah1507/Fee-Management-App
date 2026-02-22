import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../services/notification_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _courseController = TextEditingController();
  final _feesController   = TextEditingController();

  DateTime? _dueDate;
  bool _loading = false;

  // ── Design Tokens ───────────────────────────────────────────
  static const _primary = Color(0xFF1A1F36);
  static const _accent  = Color(0xFF4F6EF7);
  static const _danger  = Color(0xFFFF5B5B);
  static const _bg      = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _accent,
              onPrimary: Colors.white,
              surface: _surface,
              onSurface: _primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final docRef =
          FirebaseFirestore.instance.collection('students').doc();

      final student = Student(
        id: docRef.id,
        name: _nameController.text.trim(),
        course: _courseController.text.trim(),
        totalFees: int.tryParse(_feesController.text.trim()) ?? 0,
        paidFees: 0,
        currentSemester: 1,
        createdAt: DateTime.now(),
        dueDate: _dueDate,
      );

      await docRef.set({
        ...student.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'dueDate': _dueDate != null ? Timestamp.fromDate(_dueDate!) : null,
      });

      if (mounted) {
        // 🔔 Show notification first
        await NotificationService().showStudentAdded(
          studentName: _nameController.text.trim(),
          course: _courseController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Student added successfully'),
            backgroundColor: _accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _primary,
        centerTitle: true,
        title: const Text('Add Student',
            style:
                TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Avatar Icon ──────────────────────────────
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(.10),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.school_rounded,
                        size: 40, color: _accent),
                  ),
                ),

                const SizedBox(height: 28),
                _sectionLabel('Student Information'),
                const SizedBox(height: 12),

                // ── Name ─────────────────────────────────────
                _inputField(
                  controller: _nameController,
                  label: 'Student Name',
                  icon: Icons.person_outline_rounded,
                  capitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter student name'
                      : null,
                ),

                const SizedBox(height: 12),

                // ── Course ───────────────────────────────────
                _inputField(
                  controller: _courseController,
                  label: 'Course / Program',
                  icon: Icons.menu_book_outlined,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter course'
                      : null,
                ),

                const SizedBox(height: 12),

                // ── Total Fees ───────────────────────────────
                _inputField(
                  controller: _feesController,
                  label: 'Total Fees (₹)',
                  icon: Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter fees amount'
                      : null,
                ),

                const SizedBox(height: 24),
                _sectionLabel('Fee Due Date'),
                const SizedBox(height: 12),

                // ── Due Date Picker ──────────────────────────
                GestureDetector(
                  onTap: _pickDueDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _dueDate != null
                            ? _accent.withOpacity(.4)
                            : Colors.transparent,
                        width: 1.5,
                      ),
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
                            color: _dueDate != null
                                ? _accent.withOpacity(.10)
                                : _textSub.withOpacity(.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: _dueDate != null
                                ? _accent
                                : _textSub,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dueDate != null
                                    ? 'Fee Due Date'
                                    : 'Set Fee Due Date (Optional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _dueDate != null
                                      ? _textSub
                                      : _textSub,
                                ),
                              ),
                              if (_dueDate != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(_dueDate!),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (_dueDate != null)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _dueDate = null),
                            child: const Icon(
                                Icons.cancel_rounded,
                                color: _textSub,
                                size: 20),
                          )
                        else
                          const Icon(Icons.chevron_right_rounded,
                              color: _textSub),
                      ],
                    ),
                  ),
                ),

                // Due date warning
                if (_dueDate != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 14, color: _accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Student will be marked OVERDUE if fees are unpaid after ${_formatDate(_dueDate!)}',
                            style: const TextStyle(
                                fontSize: 11.5, color: _accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // ── Save Button ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: _accent.withOpacity(.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _loading ? null : _saveStudent,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5),
                          )
                        : const Text(
                            'Save Student',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
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

  // ── Helpers ──────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textSub,
            letterSpacing: .4),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _primary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: _textSub, fontSize: 14),
          prefixIcon: Icon(icon, color: _textSub, size: 20),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: _danger.withOpacity(.5)),
          ),
        ),
        validator: validator,
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}