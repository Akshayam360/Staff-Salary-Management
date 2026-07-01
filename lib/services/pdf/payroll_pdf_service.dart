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

                'LOP',

                'PF',

                'ESI',

                'RD',

                'TDS',

                'LLP',

                'Net Salary',

              ],

              data: records.map((salary) {

                return [

                  salary.staffId,

                  salary.staffName,

                  salary.bankAccountNumber,

                  salary.grossSalary.toStringAsFixed(0),

                  salary.lopAmount.toStringAsFixed(0),

                  salary.pfAmount.toStringAsFixed(0),

                  salary.esiAmount.toStringAsFixed(2),

                  salary.rdAmount.toStringAsFixed(0),

                  salary.tdsAmount.toStringAsFixed(0),

                  salary.llpDays.toString(),

                  salary.finalSalary.toStringAsFixed(0),

                ];

              }).toList(),

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