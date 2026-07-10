import 'package:flutter/material.dart';

import '../../services/staff_service.dart';
import '../../models/staff_model.dart';
import '../../widgets/add_staff_dialog.dart';
import '../../widgets/edit_staff_dialog.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});



  @override
  State<StaffScreen> createState() =>
      _StaffScreenState();
}
final ScrollController _horizontalController = ScrollController();
final ScrollController _verticalController = ScrollController();

class _StaffScreenState
    extends State<StaffScreen> {

  final StaffService staffService =
  StaffService();

  final TextEditingController
  searchController =
  TextEditingController();

  String searchText = '';
  Widget tableHeader(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.blueGrey,
        letterSpacing: 1,
      ),
    );
  }

  Widget detailRow(
      String title,
      String value,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [

          SizedBox(
            width: 150,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String getExperience(DateTime joiningDate) {
    final now = DateTime.now();

    int years = now.year - joiningDate.year;
    int months = now.month - joiningDate.month;

    if (now.day < joiningDate.day) {
      months--;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return '$years Yrs $months Months';
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Text(
                          'Staff Management',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Add, edit and review every staff member payroll-impacting record.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 80),

                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                        const AddStaffDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF08152E),
                      foregroundColor:
                      Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Staff'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 420,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    hintText: 'Search by name or ID...',
                    prefixIcon:
                    const Icon(Icons.search),
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
              ),
            ],
          ),

          const SizedBox(height: 25),

          Expanded(
            child: Container(


              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: StreamBuilder<List<StaffModel>>(
                stream: staffService.getStaffs(),
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
                        'No Staff Records Found',
                      ),
                    );
                  }

                  final staffs = snapshot.data!
                      .where(
                        (staff) =>
                    staff.name
                        .toLowerCase()
                        .contains(
                        searchText) ||
                        staff.staffId
                            .toLowerCase()
                            .contains(
                            searchText),
                  )
                      .toList();

                  if (staffs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No Data Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Scrollbar(
                    controller: _horizontalController,
                    thumbVisibility: true,
                    interactive: true,
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      controller: _verticalController,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 1700, // adjust if needed
                        ),
                      child: DataTable(
                        columnSpacing: 45,
                        horizontalMargin: 15,
                        headingRowHeight: 50,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF7F8FA),
                        ),
                      columns: [
                        DataColumn(
                          label: tableHeader('Staff ID'),
                        ),
                        DataColumn(
                          label: tableHeader('Name'),
                        ),
                        DataColumn(
                          label: tableHeader('Bank Account'),
                        ),
                        DataColumn(
                          label: tableHeader('EXP.'),
                        ),
                        DataColumn(
                          label: tableHeader('BASE SALARY'),
                        ),
                        DataColumn(
                          label: tableHeader('PF'),
                        ),
                        DataColumn(
                          label: tableHeader('ESI'),
                        ),
                        DataColumn(
                          label: tableHeader('RD'),
                        ),

                        DataColumn(
                          label: tableHeader('LIC'),
                        ),

                        DataColumn(
                          label: tableHeader('TDS'),
                        ),

                        DataColumn(
                          label: tableHeader('OD'),
                        ),

                        DataColumn(
                          label: tableHeader('CL'),
                        ),

                        DataColumn(
                          label: tableHeader('ACTIONS'),
                        ),
                      ],
                      rows: staffs.map((staff) {
                        return DataRow(
                          cells: [

                            DataCell(
                              Text(staff.staffId),
                            ),

                            DataCell(
                              Text(staff.name),
                            ),

                            DataCell(
                              Text(
                                staff.bankAccountNumber,
                              ),
                            ),

                            DataCell(
                              Text(
                                getExperience(staff.dateOfJoining),
                              ),
                            ),

                            DataCell(
                              Text(
                                '₹${staff.baseSalary.toStringAsFixed(0)}',
                              ),
                            ),

                            DataCell(
                              Text(
                                staff.pfEnabled
                                    ? 'Yes'
                                    : '--',
                              ),
                            ),
                            DataCell(
                              Text(
                                staff.esiEnabled
                                    ? 'Yes'
                                    : '--',
                              ),
                            ),
                            DataCell(
                              Text(
                                staff.rdAmount > 0
                                    ? '₹${staff.rdAmount}'
                                    : '--',
                              ),
                            ),

                            DataCell(
                              Text(
                                staff.licAmount > 0
                                    ? '₹${staff.licAmount}'
                                    : '--',
                              ),
                            ),



                            DataCell(
                              Text(
                                staff.tdsAmount > 0
                                    ? '₹${staff.tdsAmount}'
                                    : '--',
                              ),
                            ),

                            DataCell(
                              Text(
                                '${staff.odDays}',
                              ),
                            ),

                            DataCell(
                              Text(
                                '${staff.clBalance}',
                              ),
                            ),

                            DataCell(
                              Row(
                                children: [

                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility,

                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Container(
                                              width: 550,
                                              padding: const EdgeInsets.all(25),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [

                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Staff Details',
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),

                                                      const Spacer(),

                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        icon: const Icon(Icons.close),
                                                      ),
                                                    ],
                                                  ),

                                                  const Divider(),

                                                  const SizedBox(height: 15),

                                                  detailRow(
                                                    'Staff ID',
                                                    staff.staffId,
                                                  ),

                                                  detailRow(
                                                    'Name',
                                                    staff.name,
                                                  ),

                                                  detailRow(
                                                    'Bank Account',
                                                    staff.bankAccountNumber,
                                                  ),

                                                  detailRow(
                                                    'Experience',
                                                    getExperience(staff.dateOfJoining),
                                                  ),

                                                  detailRow(
                                                    'Base Salary',
                                                    '₹${staff.baseSalary.toStringAsFixed(0)}',
                                                  ),

                                                  detailRow(
                                                    'CL Balance',
                                                    '${staff.clBalance}',
                                                  ),

                                                  detailRow(
                                                    'PF',
                                                    staff.pfEnabled
                                                        ? 'Enabled'
                                                        : '--',
                                                  ),

                                                  detailRow(
                                                    'ESI',
                                                    staff.esiEnabled
                                                        ? 'Enabled'
                                                        : '--',
                                                  ),

                                                  detailRow(
                                                    'RD Amount',
                                                    staff.rdAmount > 0
                                                        ? '₹${staff.rdAmount}'
                                                        : '--',
                                                  ),

                                                  detailRow(
                                                    'LIC Amount',
                                                    staff.licAmount > 0
                                                        ? '₹${staff.licAmount}'
                                                        : '--',
                                                  ),

                                                  detailRow(
                                                    'TDS Amount',
                                                    staff.tdsAmount > 0
                                                        ? '₹${staff.tdsAmount}'
                                                        : '--',
                                                  ),

                                                  detailRow(
                                                    'OD Days',
                                                    '${staff.odDays}',
                                                  ),

                                                  detailRow(
                                                    'Joining Date',
                                                    '${staff.dateOfJoining.day}/${staff.dateOfJoining.month}/${staff.dateOfJoining.year}',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,

                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => EditStaffDialog(
                                          staff: staff,
                                        ),
                                      );
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {

                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            AlertDialog(
                                              title: const Text(
                                                'Delete Staff',
                                              ),
                                              content:
                                              const Text(
                                                'Are you sure you want to delete this staff?',
                                              ),
                                              actions: [

                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context);
                                                  },
                                                  child:
                                                  const Text(
                                                    'Cancel',
                                                  ),
                                                ),

                                                ElevatedButton(
                                                  onPressed:
                                                      () async {

                                                    await staffService
                                                        .deleteStaff(
                                                      staff.id,
                                                    );

                                                    if (context
                                                        .mounted) {
                                                      Navigator.pop(
                                                          context);
                                                    }
                                                  },
                                                  child:
                                                  const Text(
                                                    'Delete',
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                      ),
                      ),
                      ),
                  );
                },
              ),
            ),
      ),

        ],
      ),
    );
  }
}