// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveModel _$LeaveModelFromJson(Map<String, dynamic> json) => LeaveModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      employeeDepartment: json['employeeDepartment'] as String,
      leaveType: $enumDecode(_$LeaveTypeEnumMap, json['leaveType']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalDays: (json['totalDays'] as num).toInt(),
      isHalfDay: json['isHalfDay'] as bool? ?? false,
      halfDayPeriod: json['halfDayPeriod'] as String?,
      reason: json['reason'] as String,
      medicalCertificateUrl: json['medicalCertificateUrl'] as String?,
      supportingDocumentUrl: json['supportingDocumentUrl'] as String?,
      status: $enumDecodeNullable(_$LeaveStatusEnumMap, json['status']) ??
          LeaveStatus.pending,
      rejectionReason: json['rejectionReason'] as String?,
      approvals: (json['approvals'] as List<dynamic>?)
              ?.map((e) => LeaveApproval.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      coveringEmployeeId: json['coveringEmployeeId'] as String?,
      coveringEmployeeName: json['coveringEmployeeName'] as String?,
      handoverNotes: json['handoverNotes'] as String?,
      isEmergency: json['isEmergency'] as bool? ?? false,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      rejectedAt: json['rejectedAt'] == null
          ? null
          : DateTime.parse(json['rejectedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LeaveModelToJson(LeaveModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'employeeDepartment': instance.employeeDepartment,
      'leaveType': _$LeaveTypeEnumMap[instance.leaveType]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalDays': instance.totalDays,
      'isHalfDay': instance.isHalfDay,
      'halfDayPeriod': instance.halfDayPeriod,
      'reason': instance.reason,
      'medicalCertificateUrl': instance.medicalCertificateUrl,
      'supportingDocumentUrl': instance.supportingDocumentUrl,
      'status': _$LeaveStatusEnumMap[instance.status]!,
      'rejectionReason': instance.rejectionReason,
      'approvals': instance.approvals,
      'coveringEmployeeId': instance.coveringEmployeeId,
      'coveringEmployeeName': instance.coveringEmployeeName,
      'handoverNotes': instance.handoverNotes,
      'isEmergency': instance.isEmergency,
      'appliedAt': instance.appliedAt.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'rejectedAt': instance.rejectedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$LeaveTypeEnumMap = {
  LeaveType.annual: 'annual',
  LeaveType.casual: 'casual',
  LeaveType.sick: 'sick',
  LeaveType.maternity: 'maternity',
  LeaveType.paternity: 'paternity',
  LeaveType.noPay: 'noPay',
  LeaveType.halfDay: 'halfDay',
  LeaveType.compensatory: 'compensatory',
  LeaveType.study: 'study',
  LeaveType.bereavement: 'bereavement',
  LeaveType.emergency: 'emergency',
  LeaveType.medical: 'medical',
};

const _$LeaveStatusEnumMap = {
  LeaveStatus.pending: 'pending',
  LeaveStatus.approved: 'approved',
  LeaveStatus.rejected: 'rejected',
  LeaveStatus.cancelled: 'cancelled',
  LeaveStatus.withdrawn: 'withdrawn',
};

LeaveApproval _$LeaveApprovalFromJson(Map<String, dynamic> json) =>
    LeaveApproval(
      id: json['id'] as String,
      approverUserId: json['approverUserId'] as String,
      approverName: json['approverName'] as String,
      level: $enumDecode(_$ApprovalLevelEnumMap, json['level']),
      isApproved: json['isApproved'] as bool,
      comments: json['comments'] as String?,
      approvedAt: DateTime.parse(json['approvedAt'] as String),
    );

Map<String, dynamic> _$LeaveApprovalToJson(LeaveApproval instance) =>
    <String, dynamic>{
      'id': instance.id,
      'approverUserId': instance.approverUserId,
      'approverName': instance.approverName,
      'level': _$ApprovalLevelEnumMap[instance.level]!,
      'isApproved': instance.isApproved,
      'comments': instance.comments,
      'approvedAt': instance.approvedAt.toIso8601String(),
    };

const _$ApprovalLevelEnumMap = {
  ApprovalLevel.manager: 'manager',
  ApprovalLevel.hr: 'hr',
  ApprovalLevel.admin: 'admin',
};

LeaveBalanceModel _$LeaveBalanceModelFromJson(Map<String, dynamic> json) =>
    LeaveBalanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      year: (json['year'] as num).toInt(),
      balances: (json['balances'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$LeaveTypeEnumMap, k),
            LeaveBalance.fromJson(e as Map<String, dynamic>)),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LeaveBalanceModelToJson(LeaveBalanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'year': instance.year,
      'balances':
          instance.balances.map((k, e) => MapEntry(_$LeaveTypeEnumMap[k]!, e)),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

LeaveBalance _$LeaveBalanceFromJson(Map<String, dynamic> json) => LeaveBalance(
      type: $enumDecode(_$LeaveTypeEnumMap, json['type']),
      entitled: (json['entitled'] as num).toInt(),
      used: (json['used'] as num).toInt(),
      pending: (json['pending'] as num).toInt(),
      available: (json['available'] as num).toInt(),
      encashable: (json['encashable'] as num?)?.toDouble(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$LeaveBalanceToJson(LeaveBalance instance) =>
    <String, dynamic>{
      'type': _$LeaveTypeEnumMap[instance.type]!,
      'entitled': instance.entitled,
      'used': instance.used,
      'pending': instance.pending,
      'available': instance.available,
      'encashable': instance.encashable,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
