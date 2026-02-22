import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import 'package:share_plus/share_plus.dart';
import '../models/student.dart';
import '../models/payment.dart';

class ExcelService {
  /// Call this to generate and share the Excel report
  static Future<void> exportStudentReport({
    required BuildContext context,
    required List<Student> students,
    required List<Payment> payments,
  }) async {
    try {
      final Workbook workbook = Workbook();

      _buildSummarySheet(workbook, students);
      _buildStudentSheet(workbook, students);
      _buildPaymentSheet(workbook, students, payments);

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Save to temp file
      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName =
          'GLS_FeeReport_${now.day}-${now.month}-${now.year}.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'GLS University Fee Report',
        text: 'Fee report generated on ${_fmtDate(now)}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: const Color(0xFFFF5B5B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SHEET 1 — SUMMARY
  // ═══════════════════════════════════════════════════════════
  static void _buildSummarySheet(
      Workbook workbook, List<Student> students) {
    final sheet = workbook.worksheets.addWithName('Summary');

    // Column widths
    sheet.getRangeByName('A1:A20').columnWidth = 28;
    sheet.getRangeByName('B1:B20').columnWidth = 22;

    // Title
    final title = sheet.getRangeByName('A1:B1');
    title.merge();
    title.setText('GLS University — Fee Summary Report');
    title.cellStyle.bold = true;
    title.cellStyle.fontSize = 14;
    title.cellStyle.fontColor = '#FFFFFF';
    title.cellStyle.backColor = '#003087';
    title.cellStyle.hAlign = HAlignType.center;
    title.cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('A1').rowHeight = 36;

    // Generated date
    final dateRow = sheet.getRangeByName('A2:B2');
    dateRow.merge();
    dateRow.setText(
        'Generated: ${_fmtDate(DateTime.now())}');
    dateRow.cellStyle.fontSize = 10;
    dateRow.cellStyle.fontColor = '#8A94A6';
    dateRow.cellStyle.hAlign = HAlignType.center;

    // Stats
    final totalStudents = students.length;
    final totalFees =
        students.fold<int>(0, (s, e) => s + e.totalFees);
    final totalPaid =
        students.fold<int>(0, (s, e) => s + e.paidFees);
    final totalPending = totalFees - totalPaid;
    final fullyPaid =
        students.where((s) => s.pendingFees == 0).length;
    final overdue =
        students.where((s) => s.isOverdue).length;
    final pct = totalFees > 0
        ? (totalPaid / totalFees * 100).toStringAsFixed(1)
        : '0.0';

    final rows = [
      ['Total Students', '$totalStudents'],
      ['Fully Paid', '$fullyPaid'],
      ['Overdue Students', '$overdue'],
      ['Total Fees', 'Rs. $totalFees'],
      ['Total Collected', 'Rs. $totalPaid'],
      ['Total Pending', 'Rs. $totalPending'],
      ['Collection Rate', '$pct%'],
    ];

    for (var i = 0; i < rows.length; i++) {
      final row = i + 4;
      final labelCell = sheet.getRangeByIndex(row, 1);
      final valueCell = sheet.getRangeByIndex(row, 2);

      labelCell.setText(rows[i][0]);
      valueCell.setText(rows[i][1]);

      labelCell.cellStyle.fontSize = 11;
      valueCell.cellStyle.fontSize = 11;
      valueCell.cellStyle.bold = true;
      labelCell.rowHeight = 24;

      // Alternate row color
      if (i % 2 == 0) {
        labelCell.cellStyle.backColor = '#F4F6FC';
        valueCell.cellStyle.backColor = '#F4F6FC';
      }

      // Color overdue red
      if (rows[i][0] == 'Overdue Students' && overdue > 0) {
        valueCell.cellStyle.fontColor = '#FF5B5B';
      }
      // Color collected green
      if (rows[i][0] == 'Total Collected') {
        valueCell.cellStyle.fontColor = '#00C48C';
      }
      // Color pending red
      if (rows[i][0] == 'Total Pending' &&
          totalPending > 0) {
        valueCell.cellStyle.fontColor = '#FF5B5B';
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SHEET 2 — ALL STUDENTS
  // ═══════════════════════════════════════════════════════════
  static void _buildStudentSheet(
      Workbook workbook, List<Student> students) {
    final sheet =
        workbook.worksheets.addWithName('All Students');

    // Column widths
    sheet.getRangeByIndex(1, 1).columnWidth = 5;
    sheet.getRangeByIndex(1, 2).columnWidth = 22;
    sheet.getRangeByIndex(1, 3).columnWidth = 18;
    sheet.getRangeByIndex(1, 4).columnWidth = 10;
    sheet.getRangeByIndex(1, 5).columnWidth = 14;
    sheet.getRangeByIndex(1, 6).columnWidth = 14;
    sheet.getRangeByIndex(1, 7).columnWidth = 14;
    sheet.getRangeByIndex(1, 8).columnWidth = 14;
    sheet.getRangeByIndex(1, 9).columnWidth = 16;

    // Header row
    final headers = [
      '#', 'Student Name', 'Course', 'Semester',
      'Total Fees', 'Paid Fees', 'Pending Fees',
      'Status', 'Due Date'
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.fontColor = '#FFFFFF';
      cell.cellStyle.backColor = '#003087';
      cell.cellStyle.hAlign = HAlignType.center;
      cell.cellStyle.vAlign = VAlignType.center;
      cell.rowHeight = 28;
    }

    // Data rows
    for (var i = 0; i < students.length; i++) {
      final s = students[i];
      final row = i + 2;
      final isEven = i % 2 == 0;
      final bg = isEven ? '#F4F6FC' : '#FFFFFF';

      String status;
      String statusColor;
      if (s.pendingFees == 0) {
        status = 'PAID';
        statusColor = '#00C48C';
      } else if (s.isOverdue) {
        status = 'OVERDUE';
        statusColor = '#FF5B5B';
      } else if (s.paidFees == 0) {
        status = 'PENDING';
        statusColor = '#FF5B5B';
      } else {
        status = 'PARTIAL';
        statusColor = '#FFA940';
      }

      final rowData = [
        '${i + 1}',
        s.name,
        s.course,
        'Sem ${s.currentSemester}',
        'Rs. ${s.totalFees}',
        'Rs. ${s.paidFees}',
        'Rs. ${s.pendingFees}',
        status,
        s.dueDate != null ? _fmtDate(s.dueDate!) : '—',
      ];

      for (var j = 0; j < rowData.length; j++) {
        final cell = sheet.getRangeByIndex(row, j + 1);
        cell.setText(rowData[j]);
        cell.cellStyle.fontSize = 10;
        cell.cellStyle.backColor = bg;
        cell.rowHeight = 22;

        // Status column color
        if (j == 7) {
          cell.cellStyle.fontColor = statusColor;
          cell.cellStyle.bold = true;
        }
        // Pending red
        if (j == 6 && s.pendingFees > 0) {
          cell.cellStyle.fontColor = '#FF5B5B';
        }
        // Paid green
        if (j == 5 && s.paidFees > 0) {
          cell.cellStyle.fontColor = '#00C48C';
        }
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SHEET 3 — PAYMENT HISTORY
  // ═══════════════════════════════════════════════════════════
  static void _buildPaymentSheet(Workbook workbook,
      List<Student> students, List<Payment> payments) {
    final sheet =
        workbook.worksheets.addWithName('Payment History');

    // Column widths
    sheet.getRangeByIndex(1, 1).columnWidth = 5;
    sheet.getRangeByIndex(1, 2).columnWidth = 22;
    sheet.getRangeByIndex(1, 3).columnWidth = 18;
    sheet.getRangeByIndex(1, 4).columnWidth = 10;
    sheet.getRangeByIndex(1, 5).columnWidth = 14;
    sheet.getRangeByIndex(1, 6).columnWidth = 14;
    sheet.getRangeByIndex(1, 7).columnWidth = 18;

    // Header
    final headers = [
      '#', 'Student Name', 'Course', 'Semester',
      'Amount Paid', 'Method', 'Date & Time'
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.fontColor = '#FFFFFF';
      cell.cellStyle.backColor = '#003087';
      cell.cellStyle.hAlign = HAlignType.center;
      cell.rowHeight = 28;
    }

    // Build student lookup
    final studentMap = {for (final s in students) s.id: s};

    // Sort payments newest first
    final sorted = [...payments]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (var i = 0; i < sorted.length; i++) {
      final p = sorted[i];
      final s = studentMap[p.studentId];
      final row = i + 2;
      final bg = i % 2 == 0 ? '#F4F6FC' : '#FFFFFF';

      final rowData = [
        '${i + 1}',
        s?.name ?? '—',
        s?.course ?? '—',
        'Sem ${p.semester}',
        'Rs. ${p.amount}',
        p.method.toUpperCase(),
        _fmtDateTime(p.createdAt),
      ];

      for (var j = 0; j < rowData.length; j++) {
        final cell = sheet.getRangeByIndex(row, j + 1);
        cell.setText(rowData[j]);
        cell.cellStyle.fontSize = 10;
        cell.cellStyle.backColor = bg;
        cell.rowHeight = 22;

        // Amount green
        if (j == 4) {
          cell.cellStyle.fontColor = '#00C48C';
          cell.cellStyle.bold = true;
        }
        // Method color
        if (j == 5) {
          switch (p.method.toLowerCase()) {
            case 'upi':
              cell.cellStyle.fontColor = '#7C3AED';
              break;
            case 'bank':
              cell.cellStyle.fontColor = '#0284C7';
              break;
            default:
              cell.cellStyle.fontColor = '#00C48C';
          }
          cell.cellStyle.bold = true;
        }
      }
    
  }

  // ── Helpers ──────────────────────────────────────────────────
  static String _fmtDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  static String _fmtDateTime(DateTime d) {
    final h = d.hour > 12 ? d.hour - 12 : d.hour;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${_fmtDate(d)}  $h:$min $ampm';
  }
}