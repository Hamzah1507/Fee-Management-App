import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student.dart';
import '../models/payment.dart';

class ReceiptService {
  /// Call this to show print/share dialog for a single payment receipt
  static Future<void> generateReceipt({
    required Student student,
    required Payment payment,
  }) async {
    final pdfBytes = await _buildPdf(student: student, payment: payment);
    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  }

  /// Call this to show semester-wise full report
  static Future<void> generateSemesterReport({
    required Student student,
    required List<Payment> payments,
  }) async {
    final pdfBytes = await _buildSemesterReport(
      student: student,
      payments: payments,
    );
    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  }

  // ═══════════════════════════════════════════════════════════
  // SINGLE PAYMENT RECEIPT
  // ═══════════════════════════════════════════════════════════
  static Future<Uint8List> _buildPdf({
    required Student student,
    required Payment payment,
  }) async {
    final pdf = pw.Document();

    // Load GLS logo from assets
    final logoImage = await _loadLogo();

    // Colors
    const navyBlue = PdfColor.fromInt(0xFF003087); // GLS navy
    const goldColor = PdfColor.fromInt(0xFFD4A017);
    const lightGrey = PdfColor.fromInt(0xFFF4F6FC);
    const textDark = PdfColor.fromInt(0xFF1A1F36);
    const textSub = PdfColor.fromInt(0xFF8A94A6);
    const greenColor = PdfColor.fromInt(0xFF00C48C);
    const redColor = PdfColor.fromInt(0xFFFF5B5B);

    final receiptNo =
        'GLS/${DateTime.now().year}/${payment.id.substring(0, 8).toUpperCase()}';
    final methodIcon = _methodLabel(payment.method);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) {
          return pw.Column(
            children: [
              // ── Header Band ──────────────────────────────────
              pw.Container(
                width: double.infinity,
                color: navyBlue,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 20,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Logo
                    if (logoImage != null)
                      pw.Image(logoImage, width: 160, height: 52)
                    else
                      pw.Text(
                        'GLS UNIVERSITY',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                    // Receipt title
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'FEE RECEIPT',
                          style: pw.TextStyle(
                            color: goldColor,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          receiptNo,
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Gold Stripe ──────────────────────────────────
              pw.Container(width: double.infinity, height: 4, color: goldColor),

              // ── Body ─────────────────────────────────────────
              pw.Expanded(
                child: pw.Container(
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.all(36),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Date + Semester row
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          _infoChip(
                            'Date',
                            _formatDate(payment.createdAt),
                            textSub,
                          ),
                          _infoChip(
                            'Semester',
                            'Semester ${payment.semester}',
                            navyBlue,
                          ),
                          _infoChip('Method', methodIcon, textDark),
                        ],
                      ),

                      pw.SizedBox(height: 24),
                      pw.Divider(color: PdfColors.grey300),
                      pw.SizedBox(height: 20),

                      // Student details
                      pw.Text(
                        'STUDENT DETAILS',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: textSub,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 12),

                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: lightGrey,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(8),
                          ),
                        ),
                        child: pw.Column(
                          children: [
                            _detailRow(
                              'Student Name',
                              student.name,
                              textDark,
                              textSub,
                            ),
                            pw.SizedBox(height: 10),
                            _detailRow(
                              'Course / Program',
                              student.course,
                              textDark,
                              textSub,
                            ),
                            pw.SizedBox(height: 10),
                            _detailRow(
                              'Student ID',
                              student.id.substring(0, 10).toUpperCase(),
                              textDark,
                              textSub,
                            ),
                            pw.SizedBox(height: 10),
                            _detailRow(
                              'Academic Year',
                              _academicYear(),
                              textDark,
                              textSub,
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 24),

                      // Fee breakdown table
                      pw.Text(
                        'PAYMENT DETAILS',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: textSub,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 12),

                      pw.Table(
                        border: pw.TableBorder.all(
                          color: PdfColors.grey300,
                          width: .5,
                        ),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(3),
                          1: const pw.FlexColumnWidth(1.5),
                          2: const pw.FlexColumnWidth(1.5),
                        },
                        children: [
                          // Header row
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(color: navyBlue),
                            children: [
                              _tableHeader('Description'),
                              _tableHeader('Semester'),
                              _tableHeader('Amount'),
                            ],
                          ),
                          // Data row
                          pw.TableRow(
                            children: [
                              _tableCell('Tuition Fee Payment'),
                              _tableCell('Sem ${payment.semester}'),
                              _tableCell('Rs. ${payment.amount}'),
                            ],
                          ),
                          // Total row
                          pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: navyBlue.shade(.15),
                            ),
                            children: [
                              _tableBoldCell('Amount Paid'),
                              _tableBoldCell(''),
                              _tableBoldCell(
                                'Rs. ${payment.amount}',
                                color: navyBlue,
                              ),
                            ],
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 20),

                      // Running totals
                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.grey300,
                            width: .5,
                          ),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(8),
                          ),
                        ),
                        child: pw.Column(
                          children: [
                            _detailRow(
                              'Total Course Fees',
                              'Rs. ${student.totalFees}',
                              textDark,
                              textSub,
                            ),
                            pw.SizedBox(height: 8),
                            _detailRow(
                              'Total Paid (till date)',
                              'Rs. ${student.paidFees}',
                              greenColor,
                              textSub,
                            ),
                            pw.SizedBox(height: 8),
                            pw.Divider(color: PdfColors.grey300),
                            pw.SizedBox(height: 8),
                            _detailRow(
                              'Balance Pending',
                              'Rs. ${student.pendingFees}',
                              student.pendingFees == 0 ? greenColor : redColor,
                              textSub,
                              bold: true,
                            ),
                          ],
                        ),
                      ),

                      pw.Spacer(),

                      // Footer
                      pw.Divider(color: PdfColors.grey300),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'GLS University, Law Garden,\nNavrangpura, Ahmedabad - 380009',
                                style: const pw.TextStyle(
                                  color: textSub,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.SizedBox(height: 24),
                              pw.Container(
                                width: 120,
                                height: .5,
                                color: textSub,
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Authorised Signatory',
                                style: const pw.TextStyle(
                                  color: textSub,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Center(
                        child: pw.Text(
                          'This is a computer-generated receipt and does not require a physical signature.',
                          style: const pw.TextStyle(
                            color: textSub,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom Band ──────────────────────────────────
              pw.Container(
                width: double.infinity,
                color: navyBlue,
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Center(
                  child: pw.Text(
                    'Promoted by Gujarat Law Society Since 1927  •  www.glsuniversity.ac.in',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════
  // SEMESTER-WISE REPORT (all payments grouped by semester)
  // ═══════════════════════════════════════════════════════════
  static Future<Uint8List> _buildSemesterReport({
    required Student student,
    required List<Payment> payments,
  }) async {
    final pdf = pw.Document();
    final logoImage = await _loadLogo();

    const navyBlue = PdfColor.fromInt(0xFF003087);
    const goldColor = PdfColor.fromInt(0xFFD4A017);
    const lightGrey = PdfColor.fromInt(0xFFF4F6FC);
    const textDark = PdfColor.fromInt(0xFF1A1F36);
    const textSub = PdfColor.fromInt(0xFF8A94A6);
    const greenColor = PdfColor.fromInt(0xFF00C48C);
    const redColor = PdfColor.fromInt(0xFFFF5B5B);

    // Group payments by semester
    final Map<int, List<Payment>> bySemester = {};
    for (final p in payments) {
      bySemester.putIfAbsent(p.semester, () => []).add(p);
    }
    final sortedSems = bySemester.keys.toList()..sort();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) {
          return pw.Column(
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                color: navyBlue,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 20,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Image(logoImage, width: 160, height: 52)
                    else
                      pw.Text(
                        'GLS UNIVERSITY',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'FEE STATEMENT',
                          style: pw.TextStyle(
                            color: goldColor,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Semester-wise Breakdown',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Container(width: double.infinity, height: 4, color: goldColor),

              pw.Expanded(
                child: pw.Container(
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.all(36),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Student info
                      pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: lightGrey,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(8),
                          ),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    student.name,
                                    style: pw.TextStyle(
                                      fontSize: 15,
                                      fontWeight: pw.FontWeight.bold,
                                      color: textDark,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    student.course,
                                    style: const pw.TextStyle(
                                      color: textSub,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'Academic Year',
                                  style: const pw.TextStyle(
                                    color: textSub,
                                    fontSize: 9,
                                  ),
                                ),
                                pw.Text(
                                  _academicYear(),
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: textDark,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 20),
                      pw.Text(
                        'SEMESTER-WISE PAYMENT HISTORY',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: textSub,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 12),

                      // Table header
                      pw.Table(
                        border: pw.TableBorder.all(
                          color: PdfColors.grey300,
                          width: .5,
                        ),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1.5),
                          2: const pw.FlexColumnWidth(1.5),
                          3: const pw.FlexColumnWidth(1),
                        },
                        children: [
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(color: navyBlue),
                            children: [
                              _tableHeader('Semester'),
                              _tableHeader('Date'),
                              _tableHeader('Amount'),
                              _tableHeader('Method'),
                            ],
                          ),
                          // Rows grouped by semester
                          for (final sem in sortedSems)
                            for (final p in bySemester[sem]!)
                              pw.TableRow(
                                children: [
                                  _tableCell('Sem $sem'),
                                  _tableCell(_formatDate(p.createdAt)),
                                  _tableCell('Rs. ${p.amount}'),
                                  _tableCell(_methodLabel(p.method)),
                                ],
                              ),

                          // Grand total
                          pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: navyBlue.shade(.15),
                            ),
                            children: [
                              _tableBoldCell('TOTAL', color: navyBlue),
                              _tableBoldCell(''),
                              _tableBoldCell(
                                'Rs. ${student.paidFees}',
                                color: navyBlue,
                              ),
                              _tableBoldCell(''),
                            ],
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 20),

                      // Summary
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: _summaryBox(
                              'Total Fees',
                              'Rs. ${student.totalFees}',
                              textSub,
                              lightGrey,
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: _summaryBox(
                              'Total Paid',
                              'Rs. ${student.paidFees}',
                              greenColor,
                              lightGrey,
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: _summaryBox(
                              'Pending',
                              'Rs. ${student.pendingFees}',
                              student.pendingFees == 0 ? greenColor : redColor,
                              lightGrey,
                            ),
                          ),
                        ],
                      ),

                      pw.Spacer(),
                      pw.Divider(color: PdfColors.grey300),
                      pw.SizedBox(height: 8),
                      pw.Center(
                        child: pw.Text(
                          'GLS University • Navrangpura, Ahmedabad • www.glsuniversity.ac.in',
                          style: const pw.TextStyle(
                            color: textSub,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.Container(
                width: double.infinity,
                color: navyBlue,
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Center(
                  child: pw.Text(
                    'Promoted by Gujarat Law Society Since 1927  •  www.glsuniversity.ac.in',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════
  static Future<pw.ImageProvider?> _loadLogo() async {
    try {
      final bytes = await rootBundle.load('assets/images/gls_logo.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null; // Falls back to text if logo not found
    }
  }

  static String _formatDate(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  static String _academicYear() {
    final now = DateTime.now();
    final start = now.month >= 6 ? now.year : now.year - 1;
    return '$start-${(start + 1).toString().substring(2)}';
  }

  static String _methodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return 'UPI';
      case 'bank':
        return 'Bank Transfer';
      default:
        return 'Cash';
    }
  }

  // PDF widget helpers
  static pw.Widget _infoChip(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            color: PdfColor.fromInt(0xFF8A94A6),
            fontSize: 9,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _detailRow(
    String label,
    String value,
    PdfColor valueColor,
    PdfColor labelColor, {
    bool bold = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(color: labelColor, fontSize: 10)),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: valueColor,
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          color: PdfColor.fromInt(0xFF1A1F36),
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _tableBoldCell(
    String text, {
    PdfColor color = const PdfColor.fromInt(0xFF1A1F36),
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _summaryBox(
    String label,
    String value,
    PdfColor color,
    PdfColor bg,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              color: PdfColor.fromInt(0xFF8A94A6),
              fontSize: 9,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
