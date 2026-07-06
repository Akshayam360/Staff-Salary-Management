import 'dart:typed_data';

import 'package:intl/intl.dart';

import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;

import '../../models/salary_history_model.dart';

class PayrollPdfService {

  Future<Uint8List> generateMonthlyPayrollPdf({

    required String month,

    required List<SalaryHistoryModel> records,

  }) async {

    final pdf = pw.Document();

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

              headers: const [

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

              ],

              data: [

                ...records.map((salary) {

                  return [

                    salary.staffId,

                    salary.staffName,

                    salary.bankAccountNumber,

                    salary.grossSalary.toStringAsFixed(0),

                    salary.pfAmount.toStringAsFixed(0),

                    salary.esiAmount.toStringAsFixed(2),

                    salary.rdAmount.toStringAsFixed(0),

                    salary.licAmount.toStringAsFixed(0),

                    salary.tdsAmount.toStringAsFixed(0),

                    salary.finalSalary.toStringAsFixed(0),

                  ];

                }),

                [

                  'TOTAL',

                  '',

                  '',

                  totalGross.toStringAsFixed(0),

                  totalPf.toStringAsFixed(0),

                  totalEsi.toStringAsFixed(2),

                  totalRd.toStringAsFixed(0),

                  totalLic.toStringAsFixed(0),

                  totalTds.toStringAsFixed(0),

                  totalNetSalary.toStringAsFixed(0),

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