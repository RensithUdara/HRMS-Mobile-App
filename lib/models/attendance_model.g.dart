// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      date: DateTime.parse(json['date'] as String),
      checkInTime: json['checkInTime'] == null
          ? null
          : DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] == null
          ? null
          : DateTime.parse(json['checkOutTime'] as String),
      breaks: (json['breaks'] as List<dynamic>?)
              ?.map((e) => BreakRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: $enumDecodeNullable(_$AttendanceStatusEnumMap, json['status']) ??
          AttendanceStatus.absent,
      checkInMethod:
          $enumDecodeNullable(_$AttendanceMethodEnumMap, json['checkInMethod']),
      checkOutMethod: $enumDecodeNullable(
          _$AttendanceMethodEnumMap, json['checkOutMethod']),
      checkInLocation: json['checkInLocation'] as String?,
      checkOutLocation: json['checkOutLocation'] as String?,
      checkInLatitude: (json['checkInLatitude'] as num?)?.toDouble(),
      checkInLongitude: (json['checkInLongitude'] as num?)?.toDouble(),
      checkOutLatitude: (json['checkOutLatitude'] as num?)?.toDouble(),
      checkOutLongitude: (json['checkOutLongitude'] as num?)?.toDouble(),
      workingMinutes: (json['workingMinutes'] as num?)?.toInt(),
      breakMinutes: (json['breakMinutes'] as num?)?.toInt(),
      overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt(),
      isWorkFromHome: json['isWorkFromHome'] as bool? ?? false,
      notes: json['notes'] as String?,
      managerApproval: json['managerApproval'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'date': instance.date.toIso8601String(),
      'checkInTime': instance.checkInTime?.toIso8601String(),
      'checkOutTime': instance.checkOutTime?.toIso8601String(),
      'breaks': instance.breaks,
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'checkInMethod': _$AttendanceMethodEnumMap[instance.checkInMethod],
      'checkOutMethod': _$AttendanceMethodEnumMap[instance.checkOutMethod],
      'checkInLocation': instance.checkInLocation,
      'checkOutLocation': instance.checkOutLocation,
      'checkInLatitude': instance.checkInLatitude,
      'checkInLongitude': instance.checkInLongitude,
      'checkOutLatitude': instance.checkOutLatitude,
      'checkOutLongitude': instance.checkOutLongitude,
      'workingMinutes': instance.workingMinutes,
      'breakMinutes': instance.breakMinutes,
      'overtimeMinutes': instance.overtimeMinutes,
      'isWorkFromHome': instance.isWorkFromHome,
      'notes': instance.notes,
      'managerApproval': instance.managerApproval,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'present',
  AttendanceStatus.absent: 'absent',
  AttendanceStatus.halfDay: 'halfDay',
  AttendanceStatus.late: 'late',
  AttendanceStatus.earlyLeave: 'earlyLeave',
  AttendanceStatus.workFromHome: 'workFromHome',
};

const _$AttendanceMethodEnumMap = {
  AttendanceMethod.gps: 'gps',
  AttendanceMethod.qrCode: 'qrCode',
  AttendanceMethod.manual: 'manual',
  AttendanceMethod.biometric: 'biometric',
};

BreakRecord _$BreakRecordFromJson(Map<String, dynamic> json) => BreakRecord(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      reason: json['reason'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BreakRecordToJson(BreakRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'reason': instance.reason,
      'durationMinutes': instance.durationMinutes,
    };
