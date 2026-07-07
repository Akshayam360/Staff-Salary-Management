import 'package:flutter/material.dart';
import '../../../models/staff_model.dart';
import '../../../services/staff_service.dart';

class AddStaffDialog extends StatefulWidget {
  const AddStaffDialog({super.key});

  @override
  State<AddStaffDialog> createState() =>
      _AddStaffDialogState();
}

class _AddStaffDialogState
    extends State<AddStaffDialog> {

  final StaffService _staffService = StaffService();

  final staffIdController =
  TextEditingController();

  final nameController =
  TextEditingController();

  final bankAccountController =
  TextEditingController();

  final salaryController =
  TextEditingController();

  final clController =
  TextEditingController(text: '12');

  final rdController =
  TextEditingController(text: '0');

  final licController =
  TextEditingController();

  final odController =
  TextEditingController(text: '15');

  final tdsController =
  TextEditingController(text: '0');

  DateTime? joiningDate;

  int experience = 0;

  bool pfEnabled = false;
  bool esiEnabled = false;

  Future<void> selectJoiningDate() async {
    final pickedDate =
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1984),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        joiningDate = pickedDate;

        final now = DateTime.now();

        experience = now.year - pickedDate.year;

        if (now.month < pickedDate.month ||
            (now.month == pickedDate.month &&
                now.day < pickedDate.day)) {
          experience--;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Container(
        width: 850,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              children: [
                const Text(
                  'Add Staff',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                    staffIdController,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Staff ID',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller:
                    nameController,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Name',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                    bankAccountController,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Bank Account Number',
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: InkWell(
                    onTap:
                    selectJoiningDate,
                    child: InputDecorator(
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Date of Joining',
                      ),
                      child: Text(
                        joiningDate == null
                            ? 'Select Date'
                            : '${joiningDate!.day}/${joiningDate!.month}/${joiningDate!.year}',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    decoration:
                    InputDecoration(
                      labelText:
                      'Experience',
                      hintText:
                      '$experience Years',
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: TextField(
                    controller:
                    salaryController,
                    keyboardType:
                    TextInputType
                        .number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Base Salary',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                    clController,
                    keyboardType:
                    TextInputType
                        .number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'CL Balance',
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: TextField(
                    controller: odController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'OD Days',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                    rdController,
                    keyboardType:
                    TextInputType
                        .number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'RD Amount',
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: TextField(
                    controller:
                    licController,
                    keyboardType:
                    TextInputType
                        .number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'LIC Amount',
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: TextField(
                    controller: tdsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'TDS Amount',
                    ),
                  ),
                ),
              ],
            ),


            const SizedBox(height: 30),

            Row(
              children: [

                Expanded(
                  child: SwitchListTile(
                    title:
                    const Text(
                      'PF ₹780',
                    ),
                    value:
                    pfEnabled,
                    onChanged:
                        (value) {
                      setState(() {
                        pfEnabled =
                            value;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: SwitchListTile(
                    title:
                    const Text(
                      'ESI 0.75%',
                    ),
                    value:
                    esiEnabled,
                    onChanged:
                        (value) {
                      setState(() {
                        esiEnabled =
                            value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [

                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                        context);
                  },
                  child:
                  const Text(
                    'Cancel',
                  ),
                ),

                const SizedBox(width: 15),

                ElevatedButton(
                  onPressed: () async {
                    if (staffIdController.text.isEmpty ||
                        nameController.text.isEmpty ||
                        bankAccountController.text.isEmpty ||
                        salaryController.text.isEmpty ||
                        joiningDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fill all required fields"),
                        ),
                      );
                      return;
                    }
                    final staff = StaffModel(
                      id: '',
                      staffId: staffIdController.text.trim().toUpperCase(),
                      name: nameController.text.trim(),
                      bankAccountNumber:
                      bankAccountController.text.trim(),
                      dateOfJoining: joiningDate!,
                      experience: experience,
                      baseSalary:
                      double.parse(salaryController.text),
                      clBalance:
                      double.parse(clController.text),
                      pfEnabled: pfEnabled,
                      esiEnabled: esiEnabled,
                      rdAmount:
                      double.tryParse(rdController.text) ?? 0,
                      licAmount:
                      double.tryParse(licController.text) ?? 0,
                      odDays:
                      double.parse(odController.text),
                      tdsAmount:
                      double.tryParse(tdsController.text) ?? 0,
                      createdAt: DateTime.now(),
                    );

                    try {

                      bool alreadyExists =
                      await _staffService.isStaffIdExists(
                        staffIdController.text.trim().toUpperCase(),
                      );

                      if (alreadyExists) {

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'This Staff ID already exists. Please enter a unique Staff ID.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );

                        return;
                      }

                      await _staffService.addStaff(staff);

                      if (!mounted) return;

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Staff Added Successfully ✅",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                    } catch (e) {

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    },

                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    const Color(
                        0xFF08152E),
                  ),
                  child:
                  const Text(
                    'Add Staff',
                    style: TextStyle(
                      color:
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}