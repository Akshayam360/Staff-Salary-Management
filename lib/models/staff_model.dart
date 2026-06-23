import 'package:cloud_firestore/cloud_firestore.dart';

class StaffModel {
  final String id;
  final String staffId;
  final String name;
  final String bankAccountNumber;
  final DateTime dateOfJoining;
  final int experience;
  final double baseSalary;
  final int clBalance;
  final bool pfEnabled;
  final bool esiEnabled;
  final double rdAmount;
  final DateTime createdAt;

  StaffModel({
    required this.id,
    required this.staffId,
    required this.name,
    required this.bankAccountNumber,
    required this.dateOfJoining,
    required this.experience,
    required this.baseSalary,
    required this.clBalance,
    required this.pfEnabled,
    required this.esiEnabled,
    required this.rdAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'name': name,
      'bankAccountNumber': bankAccountNumber,
      'dateOfJoining': Timestamp.fromDate(dateOfJoining),
      'experience': experience,
      'baseSalary': baseSalary,
      'clBalance': clBalance,
      'pfEnabled': pfEnabled,
      'esiEnabled': esiEnabled,
      'rdAmount': rdAmount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StaffModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return StaffModel(
      id: id,
      staffId: map['staffId'] ?? '',
      name: map['name'] ?? '',
      bankAccountNumber: map['bankAccountNumber'] ?? '',

      dateOfJoining:
      (map['dateOfJoining'] as Timestamp?)
          ?.toDate() ??
          DateTime.now(),

      experience: map['experience'] ?? 0,

      baseSalary:
      (map['baseSalary'] ?? 0)
          .toDouble(),

      clBalance: map['clBalance'] ?? 12,

      pfEnabled:
      map['pfEnabled'] ?? false,

      esiEnabled:
      map['esiEnabled'] ?? false,

      rdAmount:
      (map['rdAmount'] ?? 0)
          .toDouble(),

      createdAt:
      (map['createdAt'] as Timestamp?)
          ?.toDate() ??
          DateTime.now(),
    );
  }

  StaffModel copyWith({
    String? id,
    String? staffId,
    String? name,
    String? bankAccountNumber,
    DateTime? dateOfJoining,
    int? experience,
    double? baseSalary,
    int? clBalance,
    bool? pfEnabled,
    bool? esiEnabled,
    double? rdAmount,
    DateTime? createdAt,
  }) {
    return StaffModel(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      name: name ?? this.name,
      bankAccountNumber:
      bankAccountNumber ??
          this.bankAccountNumber,
      dateOfJoining:
      dateOfJoining ??
          this.dateOfJoining,
      experience:
      experience ?? this.experience,
      baseSalary:
      baseSalary ?? this.baseSalary,
      clBalance:
      clBalance ?? this.clBalance,
      pfEnabled:
      pfEnabled ?? this.pfEnabled,
      esiEnabled:
      esiEnabled ?? this.esiEnabled,
      rdAmount:
      rdAmount ?? this.rdAmount,
      createdAt:
      createdAt ?? this.createdAt,
    );
  }
}