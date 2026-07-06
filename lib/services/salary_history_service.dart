import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/salary_history_model.dart';

class SalaryHistoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> saveSalaryHistory(
      SalaryHistoryModel salary,
      ) async {
    try {
      await _firestore
          .collection('salary_history')
          .add(
        salary.toMap(),
      );
    } catch (e) {
      throw Exception(
        'Failed to save salary history: $e',
      );
    }
  }

  Stream<List<SalaryHistoryModel>>
  getSalaryHistory() {
    return _firestore
        .collection('salary_history')
        .orderBy(
      'createdAt',
      descending: false,
    )
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          return SalaryHistoryModel.fromMap(
            doc.data(),
            doc.id,
          );
        }).toList();
      },
    );
  }

  Stream<List<SalaryHistoryModel>>
  getStaffSalaryHistory(
      String staffId,
      ) {
    return _firestore
        .collection('salary_history')
        .where(
      'staffId',
      isEqualTo: staffId,
    )
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          return SalaryHistoryModel.fromMap(
            doc.data(),
            doc.id,
          );
        }).toList();
      },
    );
  }

  Future<bool> salaryAlreadyGenerated({
    required String staffId,
    required String month,
  }) async {

    final snapshot = await _firestore
        .collection('salary_history')
        .where(
      'staffId',
      isEqualTo: staffId,
    )
        .where(
      'month',
      isEqualTo: month,
    )
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> deleteSalaryHistory(
      String id,
      ) async {
    try {
      await _firestore
          .collection('salary_history')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception(
        'Failed to delete salary history: $e',
      );
    }
  }

  Stream<int> getSalaryRunCount() {
    return _firestore
        .collection('salary_history')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}