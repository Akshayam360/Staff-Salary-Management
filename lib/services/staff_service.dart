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
      descending: true,
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
}