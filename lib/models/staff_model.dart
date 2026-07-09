import 'package:cloud_firestore/cloud_firestore.dart';

class StaffModel {
  final String id;
  final String staffId;
  final String name;
  final String bankAccountNumber;
  final DateTime dateOfJoining;
  final int experience;
  final double baseSalary;
  final double clBalance;
  final bool pfEnabled;
  final bool esiEnabled;
  final double rdAmount;
  final double licAmount;
  final DateTime createdAt;
  final double odDays;
  final double tdsAmount;

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
    required this.licAmount,
    required this.createdAt,
    required this.odDays,
    required this.tdsAmount,
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
      'licAmount': licAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'odDays': odDays,
      'tdsAmount': tdsAmount,
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

      experience:
      (map['experience'] ?? 0) as int,

      baseSalary:
      (map['baseSalary'] ?? 0).toDouble(),

      clBalance:
      (map['clBalance'] ?? 12).toDouble(),

      pfEnabled:
      map['pfEnabled'] ?? false,

      esiEnabled:
      map['esiEnabled'] ?? false,

      rdAmount:
      (map['rdAmount'] ?? 0).toDouble(),

      licAmount:
      (map['licAmount'] ?? 0).toDouble(),


      createdAt:
      (map['createdAt'] as Timestamp?)
          ?.toDate() ??
          DateTime.now(),

      odDays:
      (map['odDays'] ?? 15).toDouble(),

      tdsAmount:
      (map['tdsAmount'] ?? 0).toDouble(),
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
    double? clBalance,
    bool? pfEnabled,
    bool? esiEnabled,
    double? rdAmount,
    double? licAmount,
    DateTime? createdAt,
    double? odDays,
    double? tdsAmount,
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
      licAmount:
      licAmount ?? this.licAmount,
      createdAt:
      createdAt ?? this.createdAt,
      odDays: odDays ?? this.odDays,

      tdsAmount:
      tdsAmount ?? this.tdsAmount,
    );
  }
}