import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/salary_history_model.dart';
import '../../services/salary_history_service.dart';
import 'package:printing/printing.dart';

import '../../services/pdf/payroll_pdf_service.dart';
import '../../services/staff_service.dart';

class SalaryHistoryScreen extends StatefulWidget {
  const SalaryHistoryScreen({super.key});

  @override
  State<SalaryHistoryScreen> createState() =>
      _SalaryHistoryScreenState();
}

class _SalaryHistoryScreenState
    extends State<SalaryHistoryScreen> {

  final SalaryHistoryService
  salaryHistoryService =
  SalaryHistoryService();

  final StaffService
  staffService =
  StaffService();

  final PayrollPdfService payrollPdfService =
  PayrollPdfService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Salary History',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Immutable log of every salary run.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: StreamBuilder<List<SalaryHistoryModel>>(
                stream: salaryHistoryService.getSalaryHistory(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Salary History Found',
                      ),
                    );
                  }

                  final histories = snapshot.data!;

                  final Map<String, List<SalaryHistoryModel>> groupedHistory = {};

                  for (final history in histories) {
                    groupedHistory.putIfAbsent(
                      history.month,
                          () => [],
                    );

                    groupedHistory[history.month]!.add(history);
                  }

                  return ListView(
                    children: groupedHistory.entries.map((entry) {

                      final month = entry.key;
                      final records = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 35),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [

                                Text(
                                  month,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const Spacer(),

                                OutlinedButton.icon(
                                  onPressed: () async {

                                    final pdf = await payrollPdfService.generateMonthlyPayrollPdf(
                                      month: month,
                                      records: records,
                                    );

                                    await Printing.sharePdf(
                                      bytes: pdf,
                                      filename: '$month Salary Register.pdf',
                                    );

                                  },
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text("PDF"),
                                ),

                                const SizedBox(width: 12),

                                ElevatedButton.icon(
                                  onPressed: () {

                                    // Print Next Step

                                  },
                                  icon: const Icon(Icons.print),
                                  label: const Text(
                                    'Print',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(

                                columnSpacing: 80,

                                columns: const [

                                  DataColumn(
                                    label: Text('Staff ID'),
                                  ),

                                  DataColumn(
                                    label: Text('Name'),

                                  ),

                                  DataColumn(
                                    label: Text('Account No'),
                                  ),

                                  DataColumn(
                                    label: Text('Gross'),
                                  ),

                                  DataColumn(
                                    label: Text('LOP'),
                                  ),

                                  DataColumn(
                                    label: Text('PF'),
                                  ),

                                  DataColumn(
                                    label: Text('ESI'),
                                  ),

                                  DataColumn(
                                    label: Text('RD'),
                                  ),

                                  DataColumn(
                                    label: Text('TDS'),
                                  ),

                                  DataColumn(
                                    label: Text('LLP'),
                                  ),

                                  DataColumn(
                                    label: Text('Deduction'),
                                  ),

                                  DataColumn(
                                    label: Text('Final Salary'),
                                  ),

                                  DataColumn(
                                    label: Text('Action'),
                                  ),


                                ],

                                rows: records.map((salary) {

                                  return DataRow(
                                    cells: [

                                      DataCell(Text(salary.staffId)),

                                      DataCell(Text(salary.staffName)),

                                      DataCell(
                                        Text(salary.bankAccountNumber),
                                      ),

                                      DataCell(Text('₹${salary.grossSalary.toStringAsFixed(0)}')),

                                      DataCell(
                                        Text(
                                          '₹${(salary.lopAmount + salary.llpAmount).toStringAsFixed(0)}',
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          '₹${salary.pfAmount.toStringAsFixed(0)}',
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          '₹${salary.esiAmount.toStringAsFixed(2)}',
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          '₹${salary.rdAmount.toStringAsFixed(0)}',
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          '₹${salary.tdsAmount.toStringAsFixed(0)}',
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          '${salary.llpDays}',
                                        ),
                                      ),
                                      DataCell(Text('₹${salary.totalDeduction.toStringAsFixed(0)}')),

                                      DataCell(
                                        Text(
                                          '₹${salary.finalSalary.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),

                                      DataCell(

                                        IconButton(

                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),

                                          onPressed: () {

                                            showDeleteDialog(
                                              salary,
                                            );

                                          },

                                        ),

                                      ),
                                    ],
                                  );

                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );

                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }

  Future<void> showDeleteDialog(
      SalaryHistoryModel salary,
      ) async {

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            'Delete Salary Record',
          ),

          content: Text(

            'Are you sure you want to delete the salary record of\n\n'
                '${salary.staffName}\n'
                '(${salary.staffId})\n\n'
                'for ${salary.month}?\n\n'
                'CL and OD balance will also be restored.',

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child: const Text(
                'Cancel',
              ),

            ),

            ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

              onPressed: () {

                Navigator.pop(context);

                deleteSalaryRecord(
                  salary,
                );

              },

              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),

          ],

        );

      },

    );

  }
  Future<void> deleteSalaryRecord(
      SalaryHistoryModel salary,
      ) async {

    try {

      final staffSnapshot =
      await FirebaseFirestore.instance
          .collection('staffs')
          .where(
        'staffId',
        isEqualTo: salary.staffId,
      )
          .get();

      if (staffSnapshot.docs.isNotEmpty) {

        final staffDoc =
            staffSnapshot.docs.first;

        final currentCl =
        staffDoc['clBalance'];

        final currentOd =
        staffDoc['odDays'];

        await staffService.updateLeaveBalance(
          documentId: staffDoc.id,
          clBalance: currentCl + salary.clUsed.toInt(),
          odDays: currentOd + salary.odUsed.toInt(),
        );
      }

      await salaryHistoryService
          .deleteSalaryHistory(
        salary.id,
      );

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              'Salary record deleted successfully',
            ),

            backgroundColor: Colors.green,

          ),

        );
      }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(
              e.toString(),
            ),

            backgroundColor: Colors.red,

          ),

        );
      }
    }
  }
}