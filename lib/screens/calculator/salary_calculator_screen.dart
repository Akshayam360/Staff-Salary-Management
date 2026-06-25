import 'package:flutter/material.dart';

import '../../models/staff_model.dart';
import '../../services/staff_service.dart';
import '../../services/salary_history_service.dart';
import '../../models/salary_history_model.dart';
import '../../utils/salary_calculator.dart';

class SalaryCalculatorScreen
    extends StatefulWidget {

  const SalaryCalculatorScreen({
    super.key,
  });

  @override
  State<SalaryCalculatorScreen>
  createState() =>
      _SalaryCalculatorScreenState();
}
class _SalaryCalculatorScreenState
    extends State<
        SalaryCalculatorScreen> {

  final StaffService staffService =
  StaffService();

  final SalaryHistoryService
  salaryHistoryService =
  SalaryHistoryService();

  final TextEditingController
  staffIdController =
  TextEditingController();
  Future<void> findStaff() async {

    final staffs =
    await staffService
        .getStaffs()
        .first;

    try {

      final staff = staffs.firstWhere(
            (staff) =>
        staff.staffId
            .toLowerCase() ==
            staffIdController.text
                .trim()
                .toLowerCase(),
      );

      setState(() {
        selectedStaff = staff;
      });

    } catch (e) {

      setState(() {
        selectedStaff = null;
      });
    }
  }

  void validateLeaveFields() {

    if (selectedStaff == null) {
      return;
    }

    final clUsed =
        int.tryParse(
          clController.text,
        ) ??
            0;

    final odUsed =
        int.tryParse(
          odController.text,
        ) ??
            0;

    setState(() {

      clError = null;
      odError = null;

      // CL Validation
      if (selectedStaff!.clBalance == 0) {

        clError = 'CL Over';

      } else if (clUsed >
          selectedStaff!.clBalance) {

        clError =
        'CL exceeds available balance '
            '(Available: ${selectedStaff!.clBalance})';
      }

      // OD Validation
      if (selectedStaff!.odDays == 0) {

        odError = 'OD Over';

      } else if (odUsed >
          selectedStaff!.odDays) {

        odError =
        'OD exceeds available balance '
            '(Available: ${selectedStaff!.odDays})';
      }
    });
  }

  double calculateLateDeductionDays(
      int lateDays,
      ) {
    if (lateDays <= 2) {
      return 0;
    }

    final eligibleDays =
        lateDays - 2;

    final blocks =
        eligibleDays ~/ 3;

    return blocks * 0.5;
  }



  void calculateSalary() {

    if (selectedStaff == null) {
      return;
    }

    setState(() {

      result = {
        'workingDays': totalWorkingDays,
        'presentDays': presentDays,
        'absentDays':
        totalWorkingDays -
            presentDays,

        'clUsed':
        int.tryParse(
          clController.text,
        ) ??
            0,

        'odUsed':
        int.tryParse(
          odController.text,
        ) ??
            0,

        'lod':
        int.tryParse(
          lodController.text,
        ) ??
            0,

        'lcl':
        int.tryParse(
          lclController.text,
        ) ??
            0,

        'llp':
        int.tryParse(
          llpController.text,
        ) ??
            0,

        'grossSalary':
        selectedStaff!
            .baseSalary,
      };
    });
  }



  final TextEditingController
  clController =
  TextEditingController(text: '0');

  final TextEditingController
  odController =
  TextEditingController(text: '0');

  final TextEditingController
  lodController =
  TextEditingController(text: '0');

  final TextEditingController
  lclController =
  TextEditingController(text: '0');

  final TextEditingController
  llpController =
  TextEditingController(text: '0');

  final workingDaysController =
  TextEditingController();

  final presentDaysController =
  TextEditingController();

  String? workingDaysError;

  String? presentDaysError;

  String? clError;
  String? odError;

  StaffModel? selectedStaff;

  Map<String, dynamic>? result;

  int totalWorkingDays = 30;

  int presentDays = 30;

  late String selectedMonth;



  late List<String> months;

  @override
  void initState() {
    super.initState();

    final currentDate = DateTime.now();

    selectedMonth =
    '${_monthName(currentDate.month)} ${currentDate.year}';

    workingDaysController.text =
        DateTime(
          DateTime.now().year,
          DateTime.now().month + 1,
          0,
        ).day.toString();

    presentDaysController.text =
        workingDaysController.text;

    months = [];

    for (int year = currentDate.year - 5;
    year <= currentDate.year + 5;
    year++) {

      for (int month = 1; month <= 12; month++) {

        months.add(
          '${_monthName(month)} $year',
        );
      }
    }

  }
  String _monthName(int month) {
    const names = [
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

    return names[month - 1];
  }
  void validateDays() {

    final workingDays =
        int.tryParse(
          workingDaysController.text,
        ) ??
            0;

    final presentDays =
        int.tryParse(
          presentDaysController.text,
        ) ??
            0;

    final maxDays =
        DateTime(
          DateTime.now().year,
          DateTime.now().month + 1,
          0,
        ).day;

    setState(() {

      workingDaysError = null;
      presentDaysError = null;

      if (workingDays > maxDays) {

        workingDaysError =
        'Working days cannot exceed $maxDays';
      }

      if (presentDays > workingDays) {

        presentDaysError =
        'Present days cannot exceed Working Days';
      }

      totalWorkingDays =
          workingDays;

      this.presentDays =
          presentDays;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            const Text(
              'Salary Calculator',
              style: TextStyle(
                fontSize: 32,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Calculate staff salary with CL, OD, LCL, LLP, PF, ESI and TDS deductions.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedMonth,
                          decoration: InputDecoration(
                            labelText: 'Month',
                            filled: true,
                            fillColor: Colors.white,

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          items: months.map((month) {
                            return DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth =
                              value!;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: TextField(
                          controller: workingDaysController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Working Days',
                            filled: true,
                            fillColor: Colors.white,

                            suffixIcon: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [

                                InkWell(
                                  onTap: () {

                                    final value =
                                        int.tryParse(
                                          workingDaysController.text,
                                        ) ??
                                            0;

                                    final maxDays =
                                        DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month + 1,
                                          0,
                                        ).day;

                                    if (value < maxDays) {

                                      workingDaysController.text =
                                      '${value + 1}';

                                      validateDays();
                                    }
                                  },
                                  child: const Icon(
                                    Icons.keyboard_arrow_up,
                                    size: 18,
                                  ),
                                ),

                                InkWell(
                                  onTap: () {

                                    final value =
                                        int.tryParse(
                                          workingDaysController.text,
                                        ) ??
                                            0;

                                    if (value > 1) {

                                      workingDaysController.text =
                                      '${value - 1}';

                                      validateDays();
                                    }
                                  },
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            errorText:
                            workingDaysError,
                          ),
                          onChanged: (value) {
                            validateDays();
                          },
                        ),
                      ),
                      const SizedBox(width: 20),

                      Expanded(
                        child: TextField(
                          controller:
                          presentDaysController,
                          keyboardType:
                          TextInputType.number,
                          decoration:
                          InputDecoration(
                            labelText:
                            'Present Days',
                            filled: true,
                            fillColor: Colors.white,

                            suffixIcon: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [

                                InkWell(
                                  onTap: () {

                                    final value =
                                        int.tryParse(
                                          presentDaysController.text,
                                        ) ??
                                            0;

                                    if (value <
                                        totalWorkingDays) {

                                      presentDaysController.text =
                                      '${value + 1}';

                                      validateDays();
                                    }
                                  },
                                  child: const Icon(
                                    Icons.keyboard_arrow_up,
                                    size: 18,
                                  ),
                                ),

                                InkWell(
                                  onTap: () {

                                    final value =
                                        int.tryParse(
                                          presentDaysController.text,
                                        ) ??
                                            0;

                                    if (value > 0) {

                                      presentDaysController.text =
                                      '${value - 1}';

                                      validateDays();
                                    }
                                  },
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),

                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            errorText:
                            presentDaysError,
                          ),
                          onChanged: (value) {
                            validateDays();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Absent Days : ${totalWorkingDays - presentDays}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 25),

                  TextField(
                    controller: staffIdController,
                    decoration: InputDecoration(
                      labelText: 'Staff ID',
                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(
                          color: Color(0xFF08152E),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      findStaff();
                    },
                  ),
                  const SizedBox(height: 10),
                  if (staffIdController.text.isNotEmpty)

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedStaff != null
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: selectedStaff != null

                          ? Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            'Name : ${selectedStaff!.name}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Base Salary : ₹${selectedStaff!.baseSalary.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Available CL : ${selectedStaff!.clBalance}',
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Available OD : ${selectedStaff!.odDays}',
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      )

                          : const Text(
                        '❌ Staff Not Found',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 25),

                  Row(
                    children: [

                      Expanded(
                        child: TextField(
                          controller: clController,
                          keyboardType: TextInputType.number,

                          enabled:
                          selectedStaff != null &&
                              selectedStaff!.clBalance > 0,

                          onChanged: (value) {
                            validateLeaveFields();
                          },


                          decoration: InputDecoration(

                            labelText: 'CL',

                            errorText: clError,

                            filled: true,
                            fillColor: Colors.white,

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(
                                color: Color(0xFF08152E),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(width: 15),

                      Expanded(
                        child: TextField(
                          controller: odController,
                          keyboardType: TextInputType.number,

                          enabled:
                          selectedStaff != null &&
                              selectedStaff!.odDays > 0,

                          decoration: InputDecoration(
                            labelText: 'OD',

                            errorText: odError,

                            filled: true,
                            fillColor: Colors.white,

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(
                                color: Color(0xFF08152E),
                                width: 2,
                              ),
                            ),
                          ),

                          onChanged: (value) {
                            validateLeaveFields();
                          },
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: TextField(
                          controller: lodController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'LOD',
                            filled: true,
                            fillColor: Colors.white,

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(
                                color: Color(0xFF08152E),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: TextField(
                          controller: lclController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'LCL',
                            filled: true,
                            fillColor: Colors.white,

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),

                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(
                                color: Color(0xFF08152E),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: llpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'LLP',
                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(
                          color: Color(0xFF08152E),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: calculateSalary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF08152E),
                      ),
                      child: const Text(
                        'Calculate Salary',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}