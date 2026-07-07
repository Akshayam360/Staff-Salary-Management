import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/staff_model.dart';

class StaffService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Add Staff
  Future<void> addStaff(
      StaffModel staff,
      ) async {
    try {
      await _firestore
          .collection('staff')
          .add(staff.toMap());
    } catch (e) {
      throw Exception(
        'Failed to add staff: $e',
      );
    }
  }

  // Get All Staff (Realtime)
  Stream<List<StaffModel>> getStaffs() {
    return _firestore
        .collection('staff')
        .orderBy(
      'createdAt',
      descending: false,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => StaffModel.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  // Delete Staff
  Future<void> deleteStaff(
      String docId,
      ) async {
    try {
      await _firestore
          .collection('staff')
          .doc(docId)
          .delete();
    } catch (e) {
      throw Exception(
        'Failed to delete staff: $e',
      );
    }
  }

  // Update Staff
  Future<void> updateStaff(
      StaffModel staff,
      ) async {
    try {
      await _firestore
          .collection('staff')
          .doc(staff.id)
          .update(
        staff.toMap(),
      );
    } catch (e) {
      throw Exception(
        'Failed to update staff: $e',
      );
    }
  }
  Future<void> updateLeaveBalance({
    required String documentId,
    required double clBalance,
    required double odDays,
  }) async {

    await _firestore
        .collection('staff')
        .doc(documentId)
        .update({

      'clBalance': clBalance,

      'odDays': odDays,
    });
  }

  Future<void> restoreLeaveBalance({
    required String documentId,
    required double clToRestore,
    required double odToRestore,
  }) async {

    final doc = await _firestore
        .collection('staff')
        .doc(documentId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    final currentCL =
    (data['clBalance'] ?? 0).toDouble();

    final currentOD =
    (data['odDays'] ?? 0);

    await _firestore
        .collection('staff')
        .doc(documentId)
        .update({

      'clBalance': currentCL + clToRestore,

      'odDays': currentOD + odToRestore,

    });
  }

  Future<bool> isStaffIdExists(
      String staffId,
      ) async {

    final snapshot = await _firestore
        .collection('staff')
        .where(
      'staffId',
      isEqualTo: staffId,
    )
        .get();

    return snapshot.docs.isNotEmpty;
  }


}