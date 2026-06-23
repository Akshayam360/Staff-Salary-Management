import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;

  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 30),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'P.K.R Arts College For Women',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Payroll',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                Divider(thickness: 1),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _menuTile(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: () => onMenuSelected(0),
          ),

          _menuTile(
            icon: Icons.people_outline,
            title: 'Staff',
            selected: selectedIndex == 1,
            onTap: () => onMenuSelected(1),
          ),

          _menuTile(
            icon: Icons.calculate_outlined,
            title: 'Salary Calculator',
            selected: selectedIndex == 2,
            onTap: () => onMenuSelected(2),
          ),

          _menuTile(
            icon: Icons.history,
            title: 'Salary History',
            selected: selectedIndex == 3,
            onTap: () => onMenuSelected(3),
          ),

          const Spacer(),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Signed in as',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  FirebaseAuth.instance.currentUser?.email ??
                      'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                          (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF08152E)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: selected ? Colors.white : Colors.black,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}