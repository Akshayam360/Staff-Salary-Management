import 'package:flutter/material.dart';
import 'widgets/sidebar.dart';
import 'widgets/stat_card.dart';
import '../staff/staff_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../calculator/salary_calculator_screen.dart';
import '../history/salary_history_screen.dart';
import '../../services/leave_reset_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {


  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Row(
        children: [
          DashboardSidebar(
            selectedIndex: selectedIndex,
            onMenuSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: _buildScreen(),
          ),
        ],
      ),
    );

  }
  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONSOLE',
            style: TextStyle(
              color: Colors.grey,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Payroll Dashboard',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Snapshot of staff strength and salary runs for P.K.R Arts College for Women.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),

          const SizedBox(height: 35),


          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('staff')
                .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final staffCount =
                  snapshot.data!.docs.length;

              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Staff',
                      value: staffCount.toString(),
                      icon: Icons.people_outline,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('salary_history')
                          .snapshots(),
                      builder: (context, snapshot) {

                        if (!snapshot.hasData) {
                          return const StatCard(
                            title: 'Salary Runs',
                            value: '0',
                            icon: Icons.receipt_long,
                          );
                        }

                        final salaryRuns = snapshot.data!.docs.length;

                        return StatCard(
                          title: 'Salary Runs',
                          value: salaryRuns.toString(),
                          icon: Icons.receipt_long,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('salary_history')
                          .snapshots(),
                      builder: (context, snapshot) {

                        if (!snapshot.hasData) {
                          return const StatCard(
                            title: 'Total Paid',
                            value: '₹0',
                            icon: Icons.account_balance_wallet,
                          );
                        }

                        double totalPaid = 0;

                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;

                          totalPaid +=
                              (data['finalSalary'] ?? 0).toDouble();
                        }

                        return StatCard(
                          title: 'Total Paid',
                          value: '₹${totalPaid.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('salary_history')
                          .snapshots(),
                      builder: (context, snapshot) {

                        if (!snapshot.hasData) {
                          return const StatCard(
                            title: 'Avg / Run',
                            value: '₹0',
                            icon: Icons.trending_up,
                          );
                        }

                        double totalPaid = 0;

                        final docs = snapshot.data!.docs;

                        for (var doc in docs) {
                          final data = doc.data() as Map<String, dynamic>;

                          totalPaid +=
                              (data['finalSalary'] ?? 0).toDouble();
                        }

                        double average =
                        docs.isEmpty ? 0 : totalPaid / docs.length;

                        return StatCard(
                          title: 'Avg / Run',
                          value: '₹${average.toStringAsFixed(0)}',
                          icon: Icons.trending_up,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 35),
          Expanded(
            child: Row(
              children: [

                Expanded(
                  child: _buildRecentStaffRecords(),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: _buildRecentSalaryRuns(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRecentStaffRecords() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const Text(
                'Recent Staff Records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                child: const Text(
                  'View All',
                ),
              ),
            ],
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder<
                QuerySnapshot>(
              stream: FirebaseFirestore
                  .instance
                  .collection('staff')
                  .orderBy(
                'createdAt',
                descending: true,
              )
                  .limit(5)
                  .snapshots(),
              builder:
                  (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Staff Records',
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 100,
                    horizontalMargin: 20,
                    dataRowHeight: 60,
                    headingRowHeight: 55,

                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF8F9FB),
                    ),
                    columns: const [

                      DataColumn(
                        label:
                        Text('STAFF ID'),
                      ),

                      DataColumn(
                        label:
                        Text('NAME'),
                      ),

                      DataColumn(
                        label:
                        Text('EXP.'),
                      ),

                      DataColumn(
                        label: Text(
                            'BASE SALARY'),
                      ),
                    ],
                    rows: docs.map((doc) {

                      final data =
                      doc.data()
                      as Map<String,
                          dynamic>;

                      return DataRow(
                        cells: [

                          DataCell(
                            Text(
                              data['staffId']
                                  ?.toString() ??
                                  '',
                            ),
                          ),

                          DataCell(
                            Text(
                              data['name']
                                  ?.toString() ??
                                  '',
                            ),
                          ),

                          DataCell(
                            Text(
                              '${data['experience'] ?? 0} yrs',
                            ),
                          ),

                          DataCell(
                            Text(
                              '₹${data['baseSalary'] ?? 0}',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSalaryRuns() {
    return Container(
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

              const Text(
                'Recent Salary Runs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () {

                  setState(() {
                    selectedIndex = 3;
                  });

                },
                child: const Text(
                  'View History',
                ),
              ),
            ],
          ),

          const Divider(),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('salary_history')
                  .orderBy(
                'createdAt',
                descending: true,
              )
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Salary Runs Yet',
                    ),
                  );
                }

                return ListView.separated(

                  itemCount: docs.length,

                  separatorBuilder: (_, __) =>
                  const Divider(),

                  itemBuilder: (context, index) {

                    final data = docs[index].data()
                    as Map<String, dynamic>;

                    return ListTile(

                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF08152E),
                        child: Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        data['staffName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        '${data['staffId']} • ${data['month']}',
                      ),

                      trailing: Text(
                        '₹${(data['finalSalary'] ?? 0).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen() {

    switch (selectedIndex) {

      case 0:
        return _buildDashboardContent();

      case 1:
        return const StaffScreen();

      case 2:
        return const SalaryCalculatorScreen();

      case 3:
        return const SalaryHistoryScreen();

      default:
        return _buildDashboardContent();
    }
  }
}