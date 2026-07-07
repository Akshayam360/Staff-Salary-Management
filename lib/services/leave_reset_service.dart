import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveResetService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> checkAndResetLeaves() async {
    final now = DateTime.now();

    final settingsDoc = _firestore
        .collection('system_settings')
        .doc('leave_reset');

    final snapshot = await settingsDoc.get();

    int lastClResetYear;
    int lastOdResetYear;

    // Current OD Cycle
    // June 2026 - May 2027 => 2026
    // June 2027 - May 2028 => 2027

    final currentOdCycle =
    now.month >= 6
        ? now.year
        : now.year - 1;

    if (!snapshot.exists) {
      // First time setup

      lastClResetYear = now.year - 1;
      lastOdResetYear = currentOdCycle - 1;

      await settingsDoc.set({
        'lastClResetYear': lastClResetYear,
        'lastOdResetYear': lastOdResetYear,
      });

      print("System settings document created");
    } else {
      final data = snapshot.data()!;

      lastClResetYear =
          data['lastClResetYear'] ?? 0;

      lastOdResetYear =
          data['lastOdResetYear'] ?? 0;
    }

    // -----------------------------
    // CL RESET
    // -----------------------------

    if (lastClResetYear < now.year) {

      await _resetCl();

      lastClResetYear = now.year;

      await settingsDoc.update({
        'lastClResetYear':
        lastClResetYear,
      });
    }

    // -----------------------------
    // OD RESET
    // -----------------------------

    if (lastOdResetYear <
        currentOdCycle) {

      await _resetOd();

      lastOdResetYear =
          currentOdCycle;

      await settingsDoc.update({
        'lastOdResetYear':
        lastOdResetYear,
      });
    }
  }

  Future<void> _resetCl() async {

    final snapshot =
    await _firestore
        .collection('staff')
        .get();

    final batch =
    _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          'clBalance': 12.0,
        },
      );
    }

    await batch.commit();
  }

  Future<void> _resetOd() async {

    final snapshot =
    await _firestore
        .collection('staff')
        .get();

    final batch =
    _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          'odDays': 15.0,
        },
      );
    }

    await batch.commit();
  }
}