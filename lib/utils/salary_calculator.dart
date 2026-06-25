class SalaryCalculator {

  static Map<String, dynamic> calculate({

    required double baseSalary,
    required int totalWorkingDays,
    required int presentDays,

    required double availableCL,
    required double availableOD,

    required double clUsed,
    required double odUsed,

    required int lodDays,
    required int lclDays,
    required int llpDays,

    required bool pfEnabled,
    required bool esiEnabled,

    required double rdAmount,
    required double tdsAmount,
  }) {

    final absentDays =
        totalWorkingDays - presentDays;

    final perDaySalary =
        baseSalary / totalWorkingDays;

    // LCL Logic

    double lclClDeduction = 0;

    if (lclDays >= 3) {

      final eligibleDays =
          lclDays - 2;

      lclClDeduction =
          (eligibleDays ~/ 3) * 0.5;
    }

    // LLP Logic

    double llpSalaryDays = 0;

    if (llpDays >= 3) {

      final eligibleDays =
          llpDays - 2;

      llpSalaryDays =
          (eligibleDays ~/ 3) * 0.5;
    }

    // LOP

    final coveredDays =
        clUsed +
            odUsed +
            lodDays;

    double lopDays =
        absentDays - coveredDays;

    if (lopDays < 0) {
      lopDays = 0;
    }

    final lopAmount =
        lopDays * perDaySalary;

    final llpAmount =
        llpSalaryDays * perDaySalary;

    // PF

    double pfAmount = 0;

    if (pfEnabled) {
      pfAmount = 780;
    }

    // ESI

    double esiAmount = 0;

    if (esiEnabled) {
      esiAmount =
          baseSalary * 0.0075;
    }

    final totalDeduction =
        pfAmount +
            esiAmount +
            rdAmount +
            tdsAmount +
            lopAmount +
            llpAmount;

    final finalSalary =
        baseSalary -
            totalDeduction;

    return {

      'perDaySalary':
      perDaySalary,

      'absentDays':
      absentDays,

      'lopDays':
      lopDays,

      'lopAmount':
      lopAmount,

      'llpAmount':
      llpAmount,

      'lclClDeduction':
      lclClDeduction,

      'pfAmount':
      pfAmount,

      'esiAmount':
      esiAmount,

      'rdAmount':
      rdAmount,

      'tdsAmount':
      tdsAmount,

      'totalDeduction':
      totalDeduction,

      'finalSalary':
      finalSalary,
    };
  }
}