import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import 'package:intl/intl.dart';

import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;

import '../../models/salary_history_model.dart';
import '../../utils/department_list.dart';

class PayrollPdfService {

  Future<Uint8List> generateMonthlyPayrollPdf({

    required String month,

    required List<SalaryHistoryModel> records,

  }) async {

    // Load Unicode fonts so the ₹ symbol renders correctly
    final regularFontData = await rootBundle.load(
      'assets/fonts/NotoSans-Regular.ttf',
    );
    final boldFontData = await rootBundle.load(
      'assets/fonts/NotoSans-Bold.ttf',
    );
    final regularFont = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
      ),
    );

    final totalSalary = records.fold<double>(
      0,
          (sum, item) => sum + item.finalSalary,
    );

    final totalGross = records.fold<double>(
      0,
          (sum, item) => sum + item.grossSalary,
    );

    final totalPf = records.fold<double>(
      0,
          (sum, item) => sum + item.pfAmount,
    );

    final totalEsi = records.fold<double>(
      0,
          (sum, item) => sum + item.esiAmount,
    );

    final totalRd = records.fold<double>(
      0,
          (sum, item) => sum + item.rdAmount,
    );

    final totalLic = records.fold<double>(
      0,
          (sum, item) => sum + item.licAmount,
    );

    final totalTds = records.fold<double>(
      0,
          (sum, item) => sum + item.tdsAmount,
    );

    final totalNetSalary = records.fold<double>(
      0,
          (sum, item) => sum + item.finalSalary,
    );

    // ---- Group records by department ----
    final Map<String, List<SalaryHistoryModel>> grouped = {};

    for (final r in records) {
      final dept = r.department.isEmpty ? 'Unassigned' : r.department;
      grouped.putIfAbsent(dept, () => []).add(r);
    }

    // Sort each department's staff by Staff ID
    for (final list in grouped.values) {
      list.sort((a, b) => a.staffId.compareTo(b.staffId));
    }

    // Sort departments in fixed order; unknown/Unassigned goes last
    final sortedDepartments = grouped.keys.toList()
      ..sort((a, b) {
        final ia = kDepartments.indexOf(a);
        final ib = kDepartments.indexOf(b);
        final ra = ia == -1 ? 999 : ia;
        final rb = ib == -1 ? 999 : ib;
        return ra.compareTo(rb);
      });

    const headers = [
      'Staff ID',
      'Name',
      'Account No',
      'Gross Salary',
      'PF',
      'ESI',
      'RD',
      'LIC',
      'TDS',
      'Net Salary',
    ];

    List<String> rowFor(SalaryHistoryModel s) => [
      s.staffId,
      s.staffName,
      s.bankAccountNumber,
      s.grossSalary.toStringAsFixed(0),
      s.pfAmount.toStringAsFixed(0),
      s.esiAmount.toStringAsFixed(2),
      s.rdAmount.toStringAsFixed(0),
      s.licAmount.toStringAsFixed(0),
      s.tdsAmount.toStringAsFixed(0),
      s.finalSalary.toStringAsFixed(0),
    ];

    pdf.addPage(

      pw.MultiPage(

        pageFormat: PdfPageFormat.a4,

        margin: const pw.EdgeInsets.all(25),

        build: (context) {

          return [

            pw.Text(

              'P.K.R Arts College for Women',

              style: pw.TextStyle(

                fontSize: 22,

                fontWeight: pw.FontWeight.bold,

              ),

            ),

            pw.SizedBox(height: 5),

            pw.Text(

              'Staff Salary Register',

              style: pw.TextStyle(

                fontSize: 16,

                fontWeight: pw.FontWeight.bold,

              ),

            ),

            pw.SizedBox(height: 20),

            pw.Row(

              mainAxisAlignment:

              pw.MainAxisAlignment.spaceBetween,

              children: [

                pw.Text(
                  'Month : $month',
                ),

                pw.Text(
                  'Generated : ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())}',
                ),

              ],

            ),

            pw.Divider(),

            // ---- Department-wise tables ----
            for (final dept in sortedDepartments) ...[

              pw.SizedBox(height: 12),

              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                color: PdfColors.blueGrey100,
                child: pw.Text(
                  dept,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 6),

              pw.Table.fromTextArray(

                border: pw.TableBorder.all(),

                headerStyle: pw.TextStyle(

                  fontWeight: pw.FontWeight.bold,

                  color: PdfColors.white,

                ),

                headerDecoration: const pw.BoxDecoration(

                  color: PdfColors.blueGrey800,

                ),

                cellStyle: const pw.TextStyle(

                  fontSize: 9,

                ),

                headerHeight: 25,

                cellHeight: 22,

                headers: headers,

                data: grouped[dept]!.map(rowFor).toList(),

              ),

            ],

            pw.SizedBox(height: 12),

            pw.Divider(),

            pw.SizedBox(height: 6),

            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              color: PdfColors.grey300,
              child: pw.Text(
                'TOTAL',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 6),

            pw.Table.fromTextArray(

              border: pw.TableBorder.all(),

              headerStyle: pw.TextStyle(

                fontWeight: pw.FontWeight.bold,

                color: PdfColors.white,

              ),

              headerDecoration: const pw.BoxDecoration(

                color: PdfColors.blueGrey800,

              ),

              cellStyle: const pw.TextStyle(

                fontSize: 9,

                fontWeight: pw.FontWeight.bold,

              ),

              headerHeight: 25,

              cellHeight: 22,

              headers: const [
                'Gross Salary',
                'PF',
                'ESI',
                'RD',
                'LIC',
                'TDS',
                'Net Salary',
              ],

              data: [
                [
                  '₹${totalGross.toStringAsFixed(0)}',
                  '₹${totalPf.toStringAsFixed(0)}',
                  '₹${totalEsi.toStringAsFixed(2)}',
                  '₹${totalRd.toStringAsFixed(0)}',
                  '₹${totalLic.toStringAsFixed(0)}',
                  '₹${totalTds.toStringAsFixed(0)}',
                  '₹${totalNetSalary.toStringAsFixed(0)}',
                ],
              ],

            ),

            pw.SizedBox(height: 20),

            pw.Row(

              mainAxisAlignment:

              pw.MainAxisAlignment.spaceBetween,

              children: [

                pw.Text(

                  'Total Staff : ${records.length}',

                  style: pw.TextStyle(

                    fontWeight: pw.FontWeight.bold,

                  ),

                ),

                pw.Text(

                  'Total Salary : Rs.${totalSalary.toStringAsFixed(2)}',

                  style: pw.TextStyle(

                    fontWeight: pw.FontWeight.bold,

                  ),

                ),

              ],

            ),

            pw.SizedBox(height: 30),

            pw.Center(

              child: pw.Text(

                '*** Monthly Payroll Statement ***',

                style: const pw.TextStyle(

                  fontSize: 10,

                ),

              ),

            ),

          ];

        },

      ),

    );
    return pdf.save();

  }

}