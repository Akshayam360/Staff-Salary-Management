import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/salary_history_model.dart';
import '../../models/staff_model.dart';
import '../../utils/department_list.dart';

/// Builds the department-wise consolidated leave report
/// (CL, LCL, OD, LOD, LOP, LLP, Total Days per staff) for a chosen period.
class AttendanceReportPdfService {
  Future<Uint8List> generateConsolidatedReport({
    required String periodLabel,
    required List<StaffModel> staffs,
    required List<SalaryHistoryModel> records,
  }) async {
    // One row per staff. Seed from the staff list so staff with no leave
    // in the period still appear (same as the paper register).
    final Map<String, _StaffLeaveRow> rowsById = {};

    for (final staff in staffs) {
      rowsById[staff.staffId] = _StaffLeaveRow(
        staffId: staff.staffId,
        name: staff.name,
        department: _cleanDepartment(staff.department),
      );
    }

    // Add up every salary record that falls inside the period.
    for (final record in records) {
      final row = rowsById.putIfAbsent(
        record.staffId,
            () => _StaffLeaveRow(
          staffId: record.staffId,
          name: record.staffName,
          department: _cleanDepartment(record.department),
        ),
      );

      row.cl += record.clUsed.toDouble();
      // LCL / LLP columns show the days actually deducted, not the
      // late count. The rule is monthly, so it runs on each record.
      row.lcl += _lateDeduction(record.lclDays.toDouble());
      row.od += record.odUsed.toDouble();
      row.lod += record.lodDays.toDouble();
      row.llp += _lateDeduction(record.llpDays.toDouble());
      row.al += record.alDays.toDouble();

      // LOP days = absent days that CL did not cover
      // (same rule as the salary calculator).
      final lop = record.absentDays.toDouble() - record.clUsed.toDouble();
      row.lop += lop < 0 ? 0 : lop;
    }

    // Group by department.
    final Map<String, List<_StaffLeaveRow>> byDepartment = {};
    for (final row in rowsById.values) {
      byDepartment.putIfAbsent(row.department, () => []).add(row);
    }

    // Departments follow the fixed order in kDepartments; any department
    // not in that list goes last, sorted by name.
    final departmentNames = byDepartment.keys.toList()
      ..sort((a, b) {
        final rankA = _departmentRank(a);
        final rankB = _departmentRank(b);

        if (rankA != rankB) return rankA.compareTo(rankB);

        return a.compareTo(b);
      });

    for (final rows in byDepartment.values) {
      rows.sort((a, b) => _compareStaffId(a.staffId, b.staffId));
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
        build: (context) {
          final List<pw.Widget> widgets = [];

          widgets.add(
            pw.Text(
              'Consolidated Leave Report',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 4));

          widgets.add(
            pw.Text(
              'Period : $periodLabel',
              style: const pw.TextStyle(fontSize: 10),
            ),
          );

          widgets.add(
            pw.Text(
              'Generated on : ${_formatDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          );

          widgets.add(pw.SizedBox(height: 14));

          if (departmentNames.isEmpty) {
            widgets.add(
              pw.Text(
                'No records found for this period.',
                style: const pw.TextStyle(fontSize: 10),
              ),
            );
            return widgets;
          }

          for (final department in departmentNames) {
            widgets.add(
              pw.Text(
                'Department : ${department.toUpperCase()}',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 5));

            widgets.add(_buildTable(byDepartment[department]!));

            widgets.add(pw.SizedBox(height: 16));
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildTable(List<_StaffLeaveRow> rows) {
    const headers = [
      'S.No',
      'Per Id',
      'Name',
      'CL',
      'LCL',
      'OD',
      'LOD',
      'LOP',
      'LLP',
      'AL',
      'Total Days',
    ];

    final List<pw.TableRow> tableRows = [];

    tableRows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: headers
            .map((h) => _cell(h, bold: true))
            .toList(),
      ),
    );

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];

      tableRows.add(
        pw.TableRow(
          children: [
            _cell('${i + 1}'),
            _cell(row.staffId),
            _cell(row.name, align: pw.Alignment.centerLeft),
            _cell(_fmt(row.cl)),
            _cell(_fmt(row.lcl)),
            _cell(_fmt(row.od)),
            _cell(_fmt(row.lod)),
            _cell(_fmt(row.lop)),
            _cell(_fmt(row.llp)),
            _cell(_fmt(row.al)),
            _cell(_fmt(row.totalDays), bold: true),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(62),
        2: const pw.FlexColumnWidth(),
        3: const pw.FixedColumnWidth(30),
        4: const pw.FixedColumnWidth(30),
        5: const pw.FixedColumnWidth(30),
        6: const pw.FixedColumnWidth(30),
        7: const pw.FixedColumnWidth(30),
        8: const pw.FixedColumnWidth(30),
        9: const pw.FixedColumnWidth(30),
        10: const pw.FixedColumnWidth(48),
      },
      children: tableRows,
    );
  }

  pw.Widget _cell(
      String text, {
        bool bold = false,
        pw.Alignment align = pw.Alignment.center,
      }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// First 2 late entries in a month are free. After that, every
  /// complete group of 3 late entries deducts 0.5 day
  /// (same rule as the salary calculator).
  double _lateDeduction(double lateCount) {
    if (lateCount <= 2) return 0;

    final completedGroups = (lateCount - 2) ~/ 3;
    return completedGroups * 0.5;
  }

  int _departmentRank(String department) {
    final index = kDepartments.indexWhere(
          (d) => d.toLowerCase() == department.trim().toLowerCase(),
    );

    return index == -1 ? 999 : index;
  }

  String _cleanDepartment(String? department) {
    final value = (department ?? '').trim();
    return value.isEmpty ? 'Others' : value;
  }

  /// Sorts IDs like P/TS/3, P/TS/126 by the trailing number first,
  /// then falls back to plain text comparison.
  int _compareStaffId(String a, String b) {
    final numA = int.tryParse(a.split('/').last);
    final numB = int.tryParse(b.split('/').last);

    if (numA != null && numB != null && numA != numB) {
      return numA.compareTo(numB);
    }

    return a.compareTo(b);
  }

  String _fmt(double value) {
    if (value == 0) return '-';

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }
}

class _StaffLeaveRow {
  _StaffLeaveRow({
    required this.staffId,
    required this.name,
    required this.department,
  });

  final String staffId;
  final String name;
  final String department;

  double cl = 0;
  double lcl = 0;
  double od = 0;
  double lod = 0;
  double lop = 0;
  double llp = 0;
  double al = 0;

  // lcl and llp already hold deducted days, so both count in the total.
  // al (Allowed Leave) is informational only and is not part of the total.
  double get totalDays => cl + lcl + od + lod + lop + llp;
}