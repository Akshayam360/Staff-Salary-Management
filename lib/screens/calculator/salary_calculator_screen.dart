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

      updateLclAndLlpStatus();

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

    final lodUsed =
        int.tryParse(
          lodController.text,
        ) ??
            0;

    final lclUsed =
        int.tryParse(
          lclController.text,
        ) ??
            0;

    final llpUsed =
        int.tryParse(
          llpController.text,
        ) ??
            0;


    setState(() {

      clError = null;
      odError = null;

      lodError = null;

      lclError = null;
      lclClDeduction = 0;

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

      // LOD Validation

      if (lodUsed > totalWorkingDays) {
        lodError =
        'LOD cannot exceed Working Days ($totalWorkingDays)';
      }

      // LCL Validation

      if (selectedStaff!.clBalance == 0) {

        lclError = 'LCL disabled (CL Over)';
        lclClDeduction = 0;

      } else {

        if (lclUsed <= 2) {

          lclClDeduction = 0;

        } else {

          // First 2 late entries are free
          int chargeableLate = lclUsed - 2;

          // Only complete groups of 3 are considered
          int completedGroups =
              chargeableLate ~/ 3;

          lclClDeduction =
              completedGroups * 0.5;
        }

        if (lclClDeduction >
            selectedStaff!.clBalance) {

          lclError =
          'Not enough CL Balance';
        }
      }

      // LLP Validation

      if (selectedStaff!.clBalance > 0) {

        llpError =
        'LLP disabled (CL Available)';

        llpSalaryDeduction = 0;

      } else {

        if (llpUsed <= 2) {

          llpSalaryDeduction = 0;

        } else {

          int chargeableLate =
              llpUsed - 2;

          int completedGroups =
              chargeableLate ~/ 3;

          llpSalaryDeduction =
              completedGroups * 0.5;
        }
      }
    });
  }

  bool validateAllFields() {

    bool isValid = true;

    setState(() {

      staffIdError = null;
      workingDaysError = null;
      presentDaysError = null;

      validateLeaveFields();

      if (selectedStaff == null) {
        staffIdError = 'Staff Not Found';
        isValid = false;
      }

      final workingDays =
          int.tryParse(workingDaysController.text) ?? 0;

      final presentDays =
          int.tryParse(presentDaysController.text) ?? 0;

      final maxDays = DateUtils.getDaysInMonth(
        DateTime.now().year,
        DateTime.now().month,
      );

      if (workingDays <= 0 || workingDays > maxDays) {

        workingDaysError =
        'Working Days should be between 1 and $maxDays';

        isValid = false;
      }

      if (presentDays > workingDays) {

        presentDaysError =
        'Present Days cannot exceed Working Days';

        isValid = false;
      }

    });

    return isValid;
  }

  void updateLclAndLlpStatus() {

    if (selectedStaff == null) return;

    setState(() {

      if (selectedStaff!.clBalance <= 0) {

        lclEnabled = false;
        llpEnabled = true;

      } else {

        lclEnabled = true;
        llpEnabled = false;
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
    if (totalWorkingDays <= 0) {
      return;
    }

    final salaryPerDay =
        selectedStaff!.baseSalary /
            totalWorkingDays;

    double absentDeduction =
        (totalWorkingDays - presentDays) *
            salaryPerDay;

    double llpDeduction =
        llpSalaryDeduction *
            salaryPerDay;

    double lopDeduction =
        absentDeduction +
            llpDeduction;

    double grossSalary =
        selectedStaff!.baseSalary;

    double pf =
    selectedStaff!.pfEnabled
        ? 780
        : 0;

    double esi =
    selectedStaff!.esiEnabled
        ? double.parse(
      (grossSalary * 0.0075)
          .toStringAsFixed(2),
    )
        : 0;

    double rd =
        selectedStaff!.rdAmount;

    double tds =
        selectedStaff!.tdsAmount;

    double totalDeduction =
        lopDeduction +
            pf +
            esi +
            rd +
            tds;

    double netSalary =
        grossSalary -
            totalDeduction;

    if (netSalary < 0) {
      netSalary = 0;
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

        'grossSalary': grossSalary,

        'lopDeduction': lopDeduction,

        'salaryPerDay': salaryPerDay,

        'absentDeduction': absentDeduction,

        'llpDeduction': llpDeduction,

        'pf': pf,

        'esi': esi,

        'rd': rd,

        'tds': tds,

        'totalDeduction': totalDeduction,

        'finalSalary': netSalary,


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

  String? staffIdError;

  bool lclEnabled = true;
  bool llpEnabled = false;

  double lclClDeduction = 0;

  String? clError;
  String? odError;

  String? lodError;

  String? lclError;

  String? llpError;

  double llpSalaryDeduction = 0;



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

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                      errorText: staffIdError,
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
                          onChanged: (_){
                            validateLeaveFields();
                          },
                          decoration: InputDecoration(
                            labelText: 'LOD',
                            errorText: lodError,
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
                          enabled: lclEnabled,
                          controller: lclController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'LCL',
                            filled: true,
                            fillColor: Colors.white,

                            helperText: lclEnabled
                                ? '2 days grace applies'
                                : 'LCL unavailable (CL Balance is 0)',

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
                    enabled: llpEnabled,
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
                      onPressed: () {

                        if (validateAllFields()) {

                          calculateSalary();

                        }

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF08152E),
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
            ),
              const SizedBox(width: 25),


            // Salary Slip Card Start
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  'SALARY SLIP',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    letterSpacing: 2,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  selectedStaff?.name ?? '-',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  selectedStaff?.staffId ?? '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                Text(
                                  selectedMonth,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            ElevatedButton.icon(
                              onPressed: result == null
                                  ? null
                                  : () async {

                                if (selectedStaff == null) return;

                                final alreadyExists =
                                await salaryHistoryService.salaryAlreadyGenerated(

                                  staffId: selectedStaff!.staffId,

                                  month: selectedMonth,
                                );

                                if (alreadyExists) {

                                  if (mounted) {

                                    ScaffoldMessenger.of(context).showSnackBar(

                                      const SnackBar(

                                        content: Text(
                                          'Salary already generated for this month.',
                                        ),

                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }

                                  return;
                                }

                                final history = SalaryHistoryModel(

                                  id: '',

                                  staffId: selectedStaff!.staffId,

                                  staffName: selectedStaff!.name,

                                  bankAccountNumber: selectedStaff!.bankAccountNumber,

                                  month: selectedMonth,

                                  workingDays: totalWorkingDays,

                                  presentDays: presentDays,

                                  absentDays: totalWorkingDays - presentDays,

                                  clUsed: double.parse(clController.text),

                                  odUsed: double.parse(odController.text),

                                  lodDays: int.parse(lodController.text),

                                  lclDays: int.parse(lclController.text),

                                  llpDays: int.parse(llpController.text),

                                  grossSalary: result!['grossSalary'],

                                  perDaySalary: result!['salaryPerDay'],

                                  lopAmount: result!['absentDeduction'],

                                  llpAmount: result!['llpDeduction'],

                                  pfAmount: result!['pf'],

                                  esiAmount: result!['esi'],

                                  rdAmount: result!['rd'],

                                  tdsAmount: result!['tds'],

                                  totalDeduction: result!['totalDeduction'],

                                  finalSalary: result!['finalSalary'],

                                  createdAt: DateTime.now(),
                                );

                                await salaryHistoryService.saveSalaryHistory(
                                  history,
                                );

                                await staffService.updateLeaveBalance(

                                  documentId: selectedStaff!.id,

                                  clBalance: selectedStaff!.clBalance -
                                      int.parse(clController.text),

                                  odDays: selectedStaff!.odDays -
                                      int.parse(odController.text),
                                );

                                setState(() {

                                  selectedStaff = selectedStaff!.copyWith(

                                    clBalance:
                                    selectedStaff!.clBalance -
                                        int.parse(clController.text),

                                    odDays:
                                    selectedStaff!.odDays -
                                        int.parse(odController.text),
                                  );

                                });

                                if (mounted) {

                                  ScaffoldMessenger.of(context).showSnackBar(

                                    const SnackBar(

                                      content: Text(
                                        'Salary History Saved Successfully',
                                      ),

                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  staffIdController.clear();

                                  clController.text = '0';

                                  odController.text = '0';

                                  lodController.text = '0';

                                  lclController.text = '0';

                                  llpController.text = '0';

                                  workingDaysController.text = '';

                                  presentDaysController.text = '';

                                  setState(() {

                                    result = null;

                                    selectedStaff = null;

                                    totalWorkingDays = DateUtils.getDaysInMonth(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                    );

                                    presentDays = totalWorkingDays;

                                    workingDaysController.text =
                                        totalWorkingDays.toString();

                                    presentDaysController.text =
                                        presentDays.toString();

                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),

                              icon: const Icon(Icons.save),

                              label: const Text(
                                'Save History',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [

                          summaryCard(
                            'Working',
                            '${result?['workingDays'] ?? '-'}',

                          ),

                          summaryCard(
                            'Present',
                            '${result?['presentDays'] ?? '-'}',

                          ),

                          summaryCard(
                            'Absent',
                            '${result?['absentDays'] ?? '-'}',

                          ),

                          summaryCard(
                            'CL Used',
                            '${result?['clUsed'] ?? '-'}',

                          ),

                          summaryCard(
                            'CL Left',
                            selectedStaff == null
                                ? '-'
                                : (selectedStaff!.clBalance -
                                (result?['clUsed'] ?? 0))
                                .toString(),
                          ),


                          summaryCard(
                            'OD Used',
                            '${result?['odUsed'] ?? '-'}',

                          ),

                          summaryCard(
                            'OD Left',
                            selectedStaff == null
                                ? '-'
                                : (selectedStaff!.odDays -
                                (result?['odUsed'] ?? 0))
                                .toString(),
                          ),

                          summaryCard(
                            'LOD',
                            '${result?['lod'] ?? '-'}',

                          ),

                          summaryCard(
                            'LCL',
                            '${result?['lcl'] ?? '-'}',

                          ),

                          summaryCard(
                            'LLP',
                            '${result?['llp'] ?? '-'}',

                          ),


                        ],
                      ),

                      const SizedBox(height: 25),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [

                            salaryRow(
                              'Gross Salary',
                              result?['grossSalary'],
                            ),

                            salaryRow(
                              'LOP Deduction',
                              result?['lopDeduction'],
                            ),

                            salaryRow(
                              'PF',
                              result?['pf'],
                            ),

                            salaryRow(
                              'ESI (0.75%)',
                              result?['esi'],
                            ),

                            salaryRow(
                              'RD',
                              result?['rd'],
                            ),

                            salaryRow(
                              'TDS',
                              result?['tds'],
                            ),

                            salaryRow(
                              'Total Deductions',
                              result?['totalDeduction'],
                              isBold: true,
                            ),

                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                minHeight: 55,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 20,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFF08152E),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [

                                  const Text(
                                    'FINAL SALARY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    '₹${(result?['finalSalary'] ?? 0).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
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

  Widget summaryCard(
      String title,
      String value,

      ) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget salaryRow(
      String title,
      dynamic value, {
        bool isBold = false,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        children: [

          Text(
            title,
            style: TextStyle(
              fontWeight: isBold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),

          const Spacer(),

          Text(
            '₹${(value ?? 0).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

}