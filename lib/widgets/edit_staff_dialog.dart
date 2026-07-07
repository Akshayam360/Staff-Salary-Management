import 'package:flutter/material.dart';

import '../models/staff_model.dart';
import '../services/staff_service.dart';
import 'package:intl/intl.dart';

class EditStaffDialog extends StatefulWidget {
  final StaffModel staff;

  const EditStaffDialog({
    super.key,
    required this.staff,
  });

  @override
  State<EditStaffDialog> createState() =>
      _EditStaffDialogState();
}

class _EditStaffDialogState
    extends State<EditStaffDialog> {

  final StaffService _staffService =
  StaffService();

  late TextEditingController
  staffIdController;

  late TextEditingController
  nameController;

  late TextEditingController
  bankController;

  late TextEditingController
  salaryController;

  late TextEditingController
  clController;

  late TextEditingController
  rdController;

  late TextEditingController
  licController;

  late TextEditingController
  odController;

  late TextEditingController
  tdsController;

  late bool pfEnabled;
  late bool esiEnabled;

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    staffIdController =
        TextEditingController(
          text: widget.staff.staffId,
        );

    nameController =
        TextEditingController(
          text: widget.staff.name,
        );

    bankController =
        TextEditingController(
          text: widget.staff.bankAccountNumber,
        );

    salaryController =
        TextEditingController(
          text: widget.staff.baseSalary
              .toString(),
        );

    clController =
        TextEditingController(
          text: widget.staff.clBalance
              .toString(),
        );

    rdController =
        TextEditingController(
          text: widget.staff.rdAmount
              .toString(),
        );

    licController =
        TextEditingController(
          text: widget.staff.licAmount
              .toString(),
        );

    odController =
        TextEditingController(
          text: widget.staff.odDays.toString(),
        );

    tdsController =
        TextEditingController(
          text: widget.staff.tdsAmount.toString(),
        );

    pfEnabled =
        widget.staff.pfEnabled;

    esiEnabled =
        widget.staff.esiEnabled;

    selectedDate = widget.staff.dateOfJoining;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Container(
        width: 850,
        padding:
        const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            children: [

              Row(
                children: [

                  const Text(
                    'Edit Staff',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                          context);
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 25),

              Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller:
                      staffIdController,
                      enabled: true,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Staff ID',
                      ),
                    ),
                  ),

                  const SizedBox(
                      width: 20),

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

              const SizedBox(
                  height: 20),

        Row(
          children: [

            Expanded(
              child: TextField(
                controller: bankController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account',
                ),
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: InkWell(
                onTap: () async {

                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(1990),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }

                },

                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Joining',
                  ),

                  child: Text(
                    DateFormat(
                      'dd-MM-yyyy',
                    ).format(selectedDate),
                  ),
                ),
              ),
            ),

          ],
        ),





              const SizedBox(
                  height: 20),

              Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: salaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Base Salary',
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),


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

                  const SizedBox(
                      width: 20),

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

                  const SizedBox(
                      width: 20),

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

              const SizedBox(
                  height: 25),

              Row(
                children: [

                  Expanded(
                    child:
                    SwitchListTile(
                      title:
                      const Text(
                        'PF Enabled',
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
                    child:
                    SwitchListTile(
                      title:
                      const Text(
                        'ESI Enabled',
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

              const SizedBox(
                  height: 30),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                          context);
                    },
                    child: const Text(
                      'Cancel',
                    ),
                  ),

                  const SizedBox(
                      width: 15),

                  ElevatedButton(
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      const Color(
                          0xFF08152E),
                    ),
                    onPressed:
                        () async {

                      final updatedStaff =
                      widget.staff
                          .copyWith(
                        name:
                        nameController
                            .text
                            .trim(),

                        bankAccountNumber:
                        bankController
                            .text
                            .trim(),

                        baseSalary:
                        double.parse(
                          salaryController
                              .text,
                        ),

                        clBalance:
                        double.parse(
                          clController
                              .text,
                        ),

                        rdAmount:
                        double.parse(
                          rdController
                              .text,
                        ),

                        licAmount:
                        double.parse(
                          licController
                              .text,
                        ),

                        odDays:
                        double.parse(
                          odController.text,
                        ),

                        tdsAmount:
                        double.parse(
                          tdsController.text,
                        ),

                        pfEnabled:
                        pfEnabled,

                        esiEnabled:
                        esiEnabled,

                        dateOfJoining: selectedDate,
                      );

                      await _staffService
                          .updateStaff(
                        updatedStaff,
                      );

                      if (context
                          .mounted) {

                        Navigator.pop(
                            context);

                        ScaffoldMessenger.of(
                            context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Staff Updated Successfully ✅',
                            ),
                            backgroundColor:
                            Colors.green,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Update Staff',
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
      ),
    );
  }
}