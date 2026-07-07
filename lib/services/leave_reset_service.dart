import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveResetService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> checkAndResetLeaves() async {
    final now = DateTime.now();

    final settingsDoc = _firestore
        .collection('system_settings')
        .doc('leave_reset');

    final settingsSnapshot =
    await settingsDoc.get();

    int lastClResetYear = 0;
    int lastOdResetYear = 0;

    if (settingsSnapshot.exists) {
      final data = settingsSnapshot.data()!;

      lastClResetYear =
          data['lastClResetYear'] ?? 0;

      lastOdResetYear =
          data['lastOdResetYear'] ?? 0;
    }

    // CL Reset (January)

    if (now.month == 1 &&
        lastClResetYear != now.year) {
      await _resetCl();

      await settingsDoc.set({
        'lastClResetYear': now.year,
        'lastOdResetYear': lastOdResetYear,
      });
    }

    // OD Reset (June)

    if (now.month == 6 &&
        lastOdResetYear != now.year) {
      await _resetOd();

      await settingsDoc.set({
        'lastClResetYear': lastClResetYear,
        'lastOdResetYear': now.year,
      });
    }
  }

  Future<void> _resetCl() async {
    final staffs =
    await _firestore.collection('staff').get();

    for (final doc in staffs.docs) {
      await doc.reference.update({
        'clBalance': 12.0,
      });
    }
  }

  Future<void> _resetOd() async {
    final staffs =
    await _firestore.collection('staff').get();

    for (final doc in staffs.docs) {
      await doc.reference.update({
        'odDays': 15.0,
      });
    }
  }
}