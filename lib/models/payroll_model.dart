import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payroll_model.g.dart';

/// Payroll status
enum PayrollStatus { draft, calculated, approved, processed, paid }

/// Tax calculation methods
enum TaxBracket {
  noTax, // Up to LKR 1,200,000
  sixPercent, // LKR 1,200,001 - 1,700,000
  twelvePercent, // LKR 1,700,001 - 2,200,000
  eighteenPercent, // LKR 2,200,001 - 2,700,000
  twentyFourPercent, // LKR 2,700,001 - 3,200,000
  thirtyPercent, // Above LKR 3,200,000
}

/// Payroll processing model for Sri Lankan context
@JsonSerializable()
class PayrollModel extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeNumber;
  final String department;
  final String designation;
  final int year;
  final int month;
  final String payPeriod; // e.g., "January 2024"

  // Basic Salary Components
  final double basicSalary;
  final double? overtimePay;
  final double? bonusAmount;
  final double? incentives;
  final double? allowances;
  final double? otherEarnings;
  final double grossSalary;

  // Deductions
  final double epfEmployeeContribution; // 8%
  final double epfEmployerContribution; // 12%
  final double etfContribution; // 3% (employer only)
  final double payeTax;
  final double? loanDeductions;
  final double? advanceDeductions;
  final double? otherDeductions;
  final double totalDeductions;

  // Net Calculations
  final double netSalary;
  final double takeHomePay;

  // Working Days & Hours
  final int workingDays;
  final int actualWorkingDays;
  final double totalWorkingHours;
  final double overtimeHours;
  final int leaveDays;
  final int absentDays;

  // Bank Details
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankBranch;

  // Status & Approval
  final PayrollStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? processedBy;
  final DateTime? processedAt;
  final DateTime? paidAt;

  // Document URLs
  final String? payslipUrl;
  final String? taxCertificateUrl;

  // Meta Information
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  const PayrollModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeNumber,
    required this.department,
    required this.designation,
    required this.year,
    required this.month,
    required this.payPeriod,
    required this.basicSalary,
    this.overtimePay,
    this.bonusAmount,
    this.incentives,
    this.allowances,
    this.otherEarnings,
    required this.grossSalary,
    required this.epfEmployeeContribution,
    required this.epfEmployerContribution,
    required this.etfContribution,
    required this.payeTax,
    this.loanDeductions,
    this.advanceDeductions,
    this.otherDeductions,
    required this.totalDeductions,
    required this.netSalary,
    required this.takeHomePay,
    required this.workingDays,
    required this.actualWorkingDays,
    required this.totalWorkingHours,
    this.overtimeHours = 0,
    this.leaveDays = 0,
    this.absentDays = 0,
    this.bankName,
    this.bankAccountNumber,
    this.bankBranch,
    this.status = PayrollStatus.draft,
    this.approvedBy,
    this.approvedAt,
    this.processedBy,
    this.processedAt,
    this.paidAt,
    this.payslipUrl,
    this.taxCertificateUrl,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) =>
      _$PayrollModelFromJson(json);
  Map<String, dynamic> toJson() => _$PayrollModelToJson(this);

  /// Calculate PAYE tax based on Sri Lankan tax brackets (2024)
  static double calculatePayeTax(double annualSalary) {
    if (annualSalary <= 1200000) return 0; // No tax up to LKR 1.2M

    double tax = 0;
    double remainingSalary = annualSalary;

    // Tax brackets for 2024
    const List<Map<String, dynamic>> brackets = [
      {'min': 0, 'max': 1200000, 'rate': 0.00},
      {'min': 1200001, 'max': 1700000, 'rate': 0.06},
      {'min': 1700001, 'max': 2200000, 'rate': 0.12},
      {'min': 2200001, 'max': 2700000, 'rate': 0.18},
      {'min': 2700001, 'max': 3200000, 'rate': 0.24},
      {'min': 3200001, 'max': double.infinity, 'rate': 0.30},
    ];

    for (final bracket in brackets) {
      final min = bracket['min'] as double;
      final max = bracket['max'] as double;
      final rate = bracket['rate'] as double;

      if (remainingSalary <= min) break;

      final taxableAmount =
          remainingSalary > max ? max - min : remainingSalary - min;
      tax += taxableAmount * rate;

      if (remainingSalary <= max) break;
    }

    return tax;
  }

  /// Calculate monthly PAYE tax
  double get monthlyPayeTax => payeTax / 12;

  /// Calculate EPF contributions
  static Map<String, double> calculateEpfContributions(double basicSalary) {
    return {
      'employee': basicSalary * 0.08, // 8%
      'employer': basicSalary * 0.12, // 12%
      'total': basicSalary * 0.20, // 20%
    };
  }

  /// Calculate ETF contribution (employer only)
  static double calculateEtfContribution(double basicSalary) {
    return basicSalary * 0.03; // 3%
  }

  /// Get total employer contributions
  double get totalEmployerContributions =>
      epfEmployerContribution + etfContribution;

  /// Get cost to company (CTC)
  double get costToCompany => grossSalary + totalEmployerContributions;

  /// Get attendance percentage
  double get attendancePercentage {
    if (workingDays == 0) return 0;
    return (actualWorkingDays / workingDays) * 100;
  }

  /// Get salary per day
  double get salaryPerDay {
    if (workingDays == 0) return 0;
    return basicSalary / workingDays;
  }

  /// Get salary per hour (assuming 8 hours per day)
  double get salaryPerHour {
    if (workingDays == 0) return 0;
    return salaryPerDay / 8;
  }

  /// Calculate overtime rate (1.5x for regular overtime)
  double get overtimeRate => salaryPerHour * 1.5;

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case PayrollStatus.draft:
        return 'Draft';
      case PayrollStatus.calculated:
        return 'Calculated';
      case PayrollStatus.approved:
        return 'Approved';
      case PayrollStatus.processed:
        return 'Processed';
      case PayrollStatus.paid:
        return 'Paid';
    }
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case PayrollStatus.draft:
        return '#9E9E9E'; // Grey
      case PayrollStatus.calculated:
        return '#FF9800'; // Orange
      case PayrollStatus.approved:
        return '#2196F3'; // Blue
      case PayrollStatus.processed:
        return '#4CAF50'; // Green
      case PayrollStatus.paid:
        return '#8BC34A'; // Light Green
    }
  }

  /// Format currency in LKR
  static String formatCurrency(double amount) {
    return 'LKR ${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  /// Get formatted gross salary
  String get formattedGrossSalary => formatCurrency(grossSalary);

  /// Get formatted net salary
  String get formattedNetSalary => formatCurrency(netSalary);

  /// Get formatted take home pay
  String get formattedTakeHomePay => formatCurrency(takeHomePay);

  /// Check if payroll can be edited
  bool get canBeEdited =>
      status == PayrollStatus.draft || status == PayrollStatus.calculated;

  /// Check if payroll can be approved
  bool get canBeApproved => status == PayrollStatus.calculated;

  /// Check if payroll can be processed
  bool get canBeProcessed => status == PayrollStatus.approved;

  PayrollModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? employeeNumber,
    String? department,
    String? designation,
    int? year,
    int? month,
    String? payPeriod,
    double? basicSalary,
    double? overtimePay,
    double? bonusAmount,
    double? incentives,
    double? allowances,
    double? otherEarnings,
    double? grossSalary,
    double? epfEmployeeContribution,
    double? epfEmployerContribution,
    double? etfContribution,
    double? payeTax,
    double? loanDeductions,
    double? advanceDeductions,
    double? otherDeductions,
    double? totalDeductions,
    double? netSalary,
    double? takeHomePay,
    int? workingDays,
    int? actualWorkingDays,
    double? totalWorkingHours,
    double? overtimeHours,
    int? leaveDays,
    int? absentDays,
    String? bankName,
    String? bankAccountNumber,
    String? bankBranch,
    PayrollStatus? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? processedBy,
    DateTime? processedAt,
    DateTime? paidAt,
    String? payslipUrl,
    String? taxCertificateUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return PayrollModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      year: year ?? this.year,
      month: month ?? this.month,
      payPeriod: payPeriod ?? this.payPeriod,
      basicSalary: basicSalary ?? this.basicSalary,
      overtimePay: overtimePay ?? this.overtimePay,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      incentives: incentives ?? this.incentives,
      allowances: allowances ?? this.allowances,
      otherEarnings: otherEarnings ?? this.otherEarnings,
      grossSalary: grossSalary ?? this.grossSalary,
      epfEmployeeContribution:
          epfEmployeeContribution ?? this.epfEmployeeContribution,
      epfEmployerContribution:
          epfEmployerContribution ?? this.epfEmployerContribution,
      etfContribution: etfContribution ?? this.etfContribution,
      payeTax: payeTax ?? this.payeTax,
      loanDeductions: loanDeductions ?? this.loanDeductions,
      advanceDeductions: advanceDeductions ?? this.advanceDeductions,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      netSalary: netSalary ?? this.netSalary,
      takeHomePay: takeHomePay ?? this.takeHomePay,
      workingDays: workingDays ?? this.workingDays,
      actualWorkingDays: actualWorkingDays ?? this.actualWorkingDays,
      totalWorkingHours: totalWorkingHours ?? this.totalWorkingHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      leaveDays: leaveDays ?? this.leaveDays,
      absentDays: absentDays ?? this.absentDays,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankBranch: bankBranch ?? this.bankBranch,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      processedBy: processedBy ?? this.processedBy,
      processedAt: processedAt ?? this.processedAt,
      paidAt: paidAt ?? this.paidAt,
      payslipUrl: payslipUrl ?? this.payslipUrl,
      taxCertificateUrl: taxCertificateUrl ?? this.taxCertificateUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        employeeNumber,
        department,
        designation,
        year,
        month,
        payPeriod,
        basicSalary,
        overtimePay,
        bonusAmount,
        incentives,
        allowances,
        otherEarnings,
        grossSalary,
        epfEmployeeContribution,
        epfEmployerContribution,
        etfContribution,
        payeTax,
        loanDeductions,
        advanceDeductions,
        otherDeductions,
        totalDeductions,
        netSalary,
        takeHomePay,
        workingDays,
        actualWorkingDays,
        totalWorkingHours,
        overtimeHours,
        leaveDays,
        absentDays,
        bankName,
        bankAccountNumber,
        bankBranch,
        status,
        approvedBy,
        approvedAt,
        processedBy,
        processedAt,
        paidAt,
        payslipUrl,
        taxCertificateUrl,
        createdAt,
        updatedAt,
        notes,
      ];
}

/// Salary component model for detailed breakdown
@JsonSerializable()
class SalaryComponent extends Equatable {
  final String id;
  final String name;
  final String type; // earning, deduction
  final double amount;
  final bool isPercentage;
  final double? percentageValue;
  final bool isRequired;
  final bool isTaxable;
  final String? description;

  const SalaryComponent({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.isPercentage = false,
    this.percentageValue,
    this.isRequired = false,
    this.isTaxable = true,
    this.description,
  });

  factory SalaryComponent.fromJson(Map<String, dynamic> json) =>
      _$SalaryComponentFromJson(json);
  Map<String, dynamic> toJson() => _$SalaryComponentToJson(this);

  bool get isEarning => type == 'earning';
  bool get isDeduction => type == 'deduction';

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        amount,
        isPercentage,
        percentageValue,
        isRequired,
        isTaxable,
        description,
      ];
}
