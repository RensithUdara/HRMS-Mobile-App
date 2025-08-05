// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayrollModel _$PayrollModelFromJson(Map<String, dynamic> json) => PayrollModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      employeeNumber: json['employeeNumber'] as String,
      department: json['department'] as String,
      designation: json['designation'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      payPeriod: json['payPeriod'] as String,
      basicSalary: (json['basicSalary'] as num).toDouble(),
      overtimePay: (json['overtimePay'] as num?)?.toDouble(),
      bonusAmount: (json['bonusAmount'] as num?)?.toDouble(),
      incentives: (json['incentives'] as num?)?.toDouble(),
      allowances: (json['allowances'] as num?)?.toDouble(),
      otherEarnings: (json['otherEarnings'] as num?)?.toDouble(),
      grossSalary: (json['grossSalary'] as num).toDouble(),
      epfEmployeeContribution:
          (json['epfEmployeeContribution'] as num).toDouble(),
      epfEmployerContribution:
          (json['epfEmployerContribution'] as num).toDouble(),
      etfContribution: (json['etfContribution'] as num).toDouble(),
      payeTax: (json['payeTax'] as num).toDouble(),
      loanDeductions: (json['loanDeductions'] as num?)?.toDouble(),
      advanceDeductions: (json['advanceDeductions'] as num?)?.toDouble(),
      otherDeductions: (json['otherDeductions'] as num?)?.toDouble(),
      totalDeductions: (json['totalDeductions'] as num).toDouble(),
      netSalary: (json['netSalary'] as num).toDouble(),
      takeHomePay: (json['takeHomePay'] as num).toDouble(),
      workingDays: (json['workingDays'] as num).toInt(),
      actualWorkingDays: (json['actualWorkingDays'] as num).toInt(),
      totalWorkingHours: (json['totalWorkingHours'] as num).toDouble(),
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0,
      leaveDays: (json['leaveDays'] as num?)?.toInt() ?? 0,
      absentDays: (json['absentDays'] as num?)?.toInt() ?? 0,
      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankBranch: json['bankBranch'] as String?,
      status: $enumDecodeNullable(_$PayrollStatusEnumMap, json['status']) ??
          PayrollStatus.draft,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      processedBy: json['processedBy'] as String?,
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      payslipUrl: json['payslipUrl'] as String?,
      taxCertificateUrl: json['taxCertificateUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PayrollModelToJson(PayrollModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'employeeNumber': instance.employeeNumber,
      'department': instance.department,
      'designation': instance.designation,
      'year': instance.year,
      'month': instance.month,
      'payPeriod': instance.payPeriod,
      'basicSalary': instance.basicSalary,
      'overtimePay': instance.overtimePay,
      'bonusAmount': instance.bonusAmount,
      'incentives': instance.incentives,
      'allowances': instance.allowances,
      'otherEarnings': instance.otherEarnings,
      'grossSalary': instance.grossSalary,
      'epfEmployeeContribution': instance.epfEmployeeContribution,
      'epfEmployerContribution': instance.epfEmployerContribution,
      'etfContribution': instance.etfContribution,
      'payeTax': instance.payeTax,
      'loanDeductions': instance.loanDeductions,
      'advanceDeductions': instance.advanceDeductions,
      'otherDeductions': instance.otherDeductions,
      'totalDeductions': instance.totalDeductions,
      'netSalary': instance.netSalary,
      'takeHomePay': instance.takeHomePay,
      'workingDays': instance.workingDays,
      'actualWorkingDays': instance.actualWorkingDays,
      'totalWorkingHours': instance.totalWorkingHours,
      'overtimeHours': instance.overtimeHours,
      'leaveDays': instance.leaveDays,
      'absentDays': instance.absentDays,
      'bankName': instance.bankName,
      'bankAccountNumber': instance.bankAccountNumber,
      'bankBranch': instance.bankBranch,
      'status': _$PayrollStatusEnumMap[instance.status]!,
      'approvedBy': instance.approvedBy,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'processedBy': instance.processedBy,
      'processedAt': instance.processedAt?.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'payslipUrl': instance.payslipUrl,
      'taxCertificateUrl': instance.taxCertificateUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'notes': instance.notes,
    };

const _$PayrollStatusEnumMap = {
  PayrollStatus.draft: 'draft',
  PayrollStatus.calculated: 'calculated',
  PayrollStatus.approved: 'approved',
  PayrollStatus.processed: 'processed',
  PayrollStatus.paid: 'paid',
};

SalaryComponent _$SalaryComponentFromJson(Map<String, dynamic> json) =>
    SalaryComponent(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      isPercentage: json['isPercentage'] as bool? ?? false,
      percentageValue: (json['percentageValue'] as num?)?.toDouble(),
      isRequired: json['isRequired'] as bool? ?? false,
      isTaxable: json['isTaxable'] as bool? ?? true,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SalaryComponentToJson(SalaryComponent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'amount': instance.amount,
      'isPercentage': instance.isPercentage,
      'percentageValue': instance.percentageValue,
      'isRequired': instance.isRequired,
      'isTaxable': instance.isTaxable,
      'description': instance.description,
    };
