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

final ScrollController _horizontalController = ScrollController();

class _SalaryHistoryScreenState
    extends State<SalaryHistoryScreen> {

  final SalaryHistoryService
  salaryHistoryService =
  SalaryHistoryService();

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';

  String selectedMonthFilter = 'All';

  String selectedYearFilter = 'All';

  final List<String> monthFilters = [

    'All',

    'January',

    'February',

    'March',

    'April',

    'May',

    'June',

    'July',

    'August',

    'September',

    'October',

    'November',

    'December',

  ];

  final List<String> yearFilters = [

    'All',

    '2026',

    '2027',

    '2028',

    '2029',

    '2030',

  ];

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

            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText:
                'Search Staff ID / Name / Account Number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText =
                      value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMonthFilter,
                    decoration: InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: monthFilters.map((month) {

                      return DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      );

                    }).toList(),
                    onChanged: (value) {

                      setState(() {

                        selectedMonthFilter = value!;

                      });

                    },
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYearFilter,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: yearFilters.map((year) {

                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );

                    }).toList(),
                    onChanged: (value) {

                      setState(() {

                        selectedYearFilter = value!;

                      });

                    },
                  ),
                ),

                const SizedBox(width: 20),

                ElevatedButton.icon(
                  onPressed: () {

                    searchController.clear();

                    setState(() {

                      searchText = '';

                      selectedMonthFilter = 'All';

                      selectedYearFilter = 'All';

                    });

                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                  ),

                  icon: const Icon(Icons.clear),

                  label: const Text(
                    'Clear',
                  ),
                ),

              ],
            ),

            const SizedBox(height: 20),

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

                  if (snapshot.hasError) {
                    print(snapshot.error);
                    print(snapshot.stackTrace);

                    return Center(
                      child: Text(snapshot.error.toString()),
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

                  final filteredHistories =
                  histories.where((salary) {

                    final searchMatch =

                        salary.staffId
                            .toLowerCase()
                            .contains(searchText) ||

                            salary.staffName
                                .toLowerCase()
                                .contains(searchText) ||

                            salary.bankAccountNumber
                                .toLowerCase()
                                .contains(searchText);

                    final monthMatch =
                        selectedMonthFilter == 'All' ||

                            salary.month.contains(selectedMonthFilter);

                    final yearMatch =
                        selectedYearFilter == 'All' ||

                            salary.month.contains(selectedYearFilter);

                    return searchMatch &&
                        monthMatch &&
                        yearMatch;

                  }).toList();

                  final Map<String, List<SalaryHistoryModel>> groupedHistory = {};

                  for (final history in filteredHistories) {
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

                            Scrollbar(
                            controller: _horizontalController,
                            thumbVisibility: true,
                            interactive: true,
                            child: SingleChildScrollView(
                            controller: _horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                            constraints: const BoxConstraints(
                            minWidth: 1600,
                            ),
                            child: DataTable(

                                headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFF37474F),
                                ),

                                headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),

                                dataRowMinHeight: 55,

                                dataRowMaxHeight: 55,

                                columnSpacing: 5,
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
                                    label: Text('LIC'),
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
                                          '₹${salary.licAmount.toStringAsFixed(0)}',
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
          .collection('staff')
          .where(
        'staffId',
        isEqualTo: salary.staffId,
      )
          .limit(1)
          .get();

      if (staffSnapshot.docs.isNotEmpty) {

        double lclRestore = 0;

        if (salary.lclDays >= 5 && salary.lclDays <= 7) {
          lclRestore = 0.5;
        } else if (salary.lclDays >= 8 && salary.lclDays <= 10) {
          lclRestore = 1.0;
        } else if (salary.lclDays >= 11 && salary.lclDays <= 13) {
          lclRestore = 1.5;
        } else if (salary.lclDays >= 14 && salary.lclDays <= 16) {
          lclRestore = 2.0;
        } else if (salary.lclDays >= 17 && salary.lclDays <= 19) {
          lclRestore = 2.5;
        }else if (salary.lclDays >= 20 && salary.lclDays <= 22) {
          lclRestore = 3.0;
        } else if (salary.lclDays >= 23 && salary.lclDays <= 25) {
          lclRestore = 3.5;
        } else if (salary.lclDays >= 26 && salary.lclDays <= 28) {
          lclRestore = 4.0;
        } else if (salary.lclDays >= 29 && salary.lclDays <= 31) {
          lclRestore = 4.5;
        }

        double totalClRestore =
            salary.clUsed + lclRestore;

        await StaffService().restoreLeaveBalance(

          documentId: staffSnapshot.docs.first.id,

          clToRestore: totalClRestore,

          odToRestore: salary.odUsed,

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