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
  int _semester = 1;
  bool _loading = false;

  // ── Design Tokens ───────────────────────────────────────────
  static const _primary = Color(0xFF1A1F36);
  static const _accent  = Color(0xFF4F6EF7);
  static const _danger  = Color(0xFFFF5B5B);
  static const _bg      = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);

  @override
  void initState() {
    super.initState();
    _semester = widget.student.currentSemester;
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _collectFee() async {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      _showSnack('Enter a valid amount', isError: true);
      return;
    }

    if (amount > widget.student.pendingFees) {
      _showSnack('Amount exceeds pending fees', isError: true);
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

      // Update paid fees + current semester
      await studentRef.update({
        'paidFees': FieldValue.increment(amount),
        'currentSemester': _semester,
      });

      // Save payment with semester
      final payment = Payment(
        id: paymentRef.id,
        studentId: widget.student.id,
        amount: amount,
        method: _method,
        semester: _semester,
        createdAt: DateTime.now(),
      );

      await paymentRef.set(payment.toMap());

      if (mounted) {
        Navigator.pop(context);
        _showSnack('Payment of ₹$amount collected successfully!');
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }

    if (mounted) setState(() => _loading = false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _danger : _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.student.pendingFees;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _primary,
        centerTitle: true,
        title: const Text(
          'Collect Fee',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Student Info ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.student.name[0].toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: _accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.student.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: _primary)),
                        Text(widget.student.course,
                            style: const TextStyle(
                                fontSize: 12.5, color: _textSub)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Pending',
                          style:
                              TextStyle(fontSize: 11, color: _textSub)),
                      Text(
                        '₹$pending',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _danger),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Payment Details',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _primary)),
            const SizedBox(height: 14),

            // ── Semester Selector ────────────────────────────
            _label('Semester'),
            const SizedBox(height: 8),
            Container(
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
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2,
                ),
                itemCount: 8,
                itemBuilder: (context, i) {
                  final sem = i + 1;
                  final selected = _semester == sem;
                  return GestureDetector(
                    onTap: () => setState(() => _semester = sem),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected
                            ? _accent
                            : _accent.withOpacity(.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Sem $sem',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                selected ? Colors.white : _accent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Amount Field ─────────────────────────────────
            _label('Amount (₹)'),
            const SizedBox(height: 8),
            Container(
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
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _primary),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  hintStyle: const TextStyle(color: _textSub),
                  prefixIcon: const Icon(Icons.currency_rupee_rounded,
                      color: _textSub, size: 20),
                  suffixText: 'Max ₹$pending',
                  suffixStyle:
                      const TextStyle(color: _textSub, fontSize: 12),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Payment Method ───────────────────────────────
            _label('Payment Method'),
            const SizedBox(height: 8),
            Row(
              children: [
                _methodChip('cash', Icons.payments_rounded,
                    const Color(0xFF00C48C)),
                const SizedBox(width: 10),
                _methodChip('upi', Icons.phone_android_rounded,
                    const Color(0xFF7C3AED)),
                const SizedBox(width: 10),
                _methodChip('bank', Icons.account_balance_rounded,
                    const Color(0xFF0284C7)),
              ],
            ),

            const SizedBox(height: 32),

            // ── Collect Button ───────────────────────────────
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
                onPressed: _loading ? null : _collectFee,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Collect ₹${_amountController.text.isEmpty ? '0' : _amountController.text} — Sem $_semester',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textSub,
            letterSpacing: .3),
      );

  Widget _methodChip(String value, IconData icon, Color color) {
    final selected = _method == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _method = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? Colors.white : color),
              const SizedBox(height: 4),
              Text(
                value.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}