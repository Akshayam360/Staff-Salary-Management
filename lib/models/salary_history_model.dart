import 'package:cloud_firestore/cloud_firestore.dart';

class SalaryHistoryModel {
  final String id;
  final String staffId;
  final String staffName;
  final String department;
  final String bankAccountNumber;
  final String month;

  final int workingDays;
  final double presentDays;
  final double absentDays;

  final double clUsed;
  final double odUsed;
  final double lodDays;
  final double lclDays;
  final double llpDays;
  final double alDays;

  final double grossSalary;
  final double perDaySalary;

  final double lopAmount;
  final double llpAmount;

  final double pfAmount;
  final double esiAmount;
  final double rdAmount;
  final double licAmount;
  final double tdsAmount;
  final double busFee;

  final double totalDeduction;
  final double finalSalary;

  final DateTime createdAt;



  SalaryHistoryModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.department,
    required this.bankAccountNumber,
    required this.month,
    required this.workingDays,
    required this.presentDays,
    required this.absentDays,
    required this.clUsed,
    required this.odUsed,
    required this.lodDays,
    required this.lclDays,
    required this.llpDays,
    this.alDays = 0,
    required this.grossSalary,
    required this.perDaySalary,
    required this.lopAmount,
    required this.llpAmount,
    required this.pfAmount,
    required this.esiAmount,
    required this.rdAmount,
    required this.licAmount,
    required this.tdsAmount,
    this.busFee = 0,
    required this.totalDeduction,
    required this.finalSalary,
    required this.createdAt,

  });

  factory SalaryHistoryModel.fromMap(
      Map<String, dynamic> map,
      String documentId,
      ) {
    return SalaryHistoryModel(
      id: documentId,
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      department: map['department'] ?? '',
      bankAccountNumber:
      map['bankAccountNumber'] ?? '',
      month: map['month'] ?? '',
      workingDays: map['workingDays'] ?? 0,
      presentDays:
      (map['presentDays'] ?? 0).toDouble(),

      absentDays:
      (map['absentDays'] ?? 0).toDouble(),
      clUsed: (map['clUsed'] ?? 0).toDouble(),
      odUsed: (map['odUsed'] ?? 0).toDouble(),
      lodDays: (map['lodDays'] ?? 0).toDouble(),
      lclDays: (map['lclDays'] ?? 0).toDouble(),
      llpDays: (map['llpDays'] ?? 0).toDouble(),
      alDays: (map['alDays'] ?? 0).toDouble(),
      grossSalary: (map['grossSalary'] ?? 0).toDouble(),
      perDaySalary: (map['perDaySalary'] ?? 0).toDouble(),
      lopAmount: (map['lopAmount'] ?? 0).toDouble(),
      llpAmount: (map['llpAmount'] ?? 0).toDouble(),
      pfAmount: (map['pfAmount'] ?? 0).toDouble(),
      esiAmount: (map['esiAmount'] ?? 0).toDouble(),
      rdAmount: (map['rdAmount'] ?? 0).toDouble(),
      licAmount:
      (map['licAmount'] ?? 0).toDouble(),
      tdsAmount: (map['tdsAmount'] ?? 0).toDouble(),
      busFee: (map['busFee'] ?? 0).toDouble(),
      totalDeduction:
      (map['totalDeduction'] ?? 0).toDouble(),
      finalSalary:
      (map['finalSalary'] ?? 0).toDouble(),
      createdAt:
      (map['createdAt'] as Timestamp).toDate(),

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'department': department,
      'bankAccountNumber': bankAccountNumber,
      'month': month,
      'workingDays': workingDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'clUsed': clUsed,
      'odUsed': odUsed,
      'lodDays': lodDays,
      'lclDays': lclDays,
      'llpDays': llpDays,
      'alDays': alDays,
      'grossSalary': grossSalary,
      'perDaySalary': perDaySalary,
      'lopAmount': lopAmount,
      'llpAmount': llpAmount,
      'pfAmount': pfAmount,
      'esiAmount': esiAmount,
      'rdAmount': rdAmount,
      'licAmount': licAmount,
      'tdsAmount': tdsAmount,
      'busFee': busFee,
      'totalDeduction': totalDeduction,
      'finalSalary': finalSalary,
      'createdAt': Timestamp.fromDate(
        createdAt,

      ),
    };
  }

  SalaryHistoryModel copyWith({
    String? id,
    String? staffId,
    String? staffName,
    String? department,
    String? bankAccountNumber,
    String? month,
    int? workingDays,
    double? presentDays,
    double? absentDays,
    double? clUsed,
    double? odUsed,
    double? lodDays,
    double? lclDays,
    double? llpDays,
    double? alDays,
    double? grossSalary,
    double? perDaySalary,
    double? lopAmount,
    double? llpAmount,
    double? pfAmount,
    double? esiAmount,
    double? rdAmount,
    double? licAmount,
    double? tdsAmount,
    double? busFee,
    double? totalDeduction,
    double? finalSalary,
    DateTime? createdAt,
  }) {
    return SalaryHistoryModel(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      department: department ?? this.department,
      bankAccountNumber:
      bankAccountNumber ?? this.bankAccountNumber,
      month: month ?? this.month,
      workingDays:
      workingDays ?? this.workingDays,
      presentDays:
      presentDays ?? this.presentDays,
      absentDays:
      absentDays ?? this.absentDays,
      clUsed: clUsed ?? this.clUsed,
      odUsed: odUsed ?? this.odUsed,
      lodDays: lodDays ?? this.lodDays,
      lclDays: lclDays ?? this.lclDays,
      llpDays: llpDays ?? this.llpDays,
      alDays: alDays ?? this.alDays,
      grossSalary:
      grossSalary ?? this.grossSalary,
      perDaySalary:
      perDaySalary ?? this.perDaySalary,
      lopAmount:
      lopAmount ?? this.lopAmount,
      llpAmount:
      llpAmount ?? this.llpAmount,
      pfAmount:
      pfAmount ?? this.pfAmount,
      esiAmount:
      esiAmount ?? this.esiAmount,
      rdAmount:
      rdAmount ?? this.rdAmount,
      licAmount:
      licAmount ?? this.licAmount,
      tdsAmount:
      tdsAmount ?? this.tdsAmount,
      busFee: busFee ?? this.busFee,
      totalDeduction:
      totalDeduction ??
          this.totalDeduction,
      finalSalary:
      finalSalary ?? this.finalSalary,
      createdAt:
      createdAt ?? this.createdAt,

    );
  }
}