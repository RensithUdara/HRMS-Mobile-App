import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

/// Attendance entry types
enum AttendanceType { checkIn, checkOut, breakStart, breakEnd }

/// Attendance verification methods
enum AttendanceMethod { gps, qrCode, manual, biometric }

/// Attendance status
enum AttendanceStatus {
  present,
  absent,
  halfDay,
  late,
  earlyLeave,
  workFromHome
}

/// Daily attendance model
@JsonSerializable()
class AttendanceModel extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final List<BreakRecord> breaks;
  final AttendanceStatus status;
  final AttendanceMethod? checkInMethod;
  final AttendanceMethod? checkOutMethod;
  final String? checkInLocation;
  final String? checkOutLocation;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final int? workingMinutes;
  final int? breakMinutes;
  final int? overtimeMinutes;
  final bool isWorkFromHome;
  final String? notes;
  final String? managerApproval;
  final DateTime? approvedAt;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.breaks = const [],
    this.status = AttendanceStatus.absent,
    this.checkInMethod,
    this.checkOutMethod,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.workingMinutes,
    this.breakMinutes,
    this.overtimeMinutes,
    this.isWorkFromHome = false,
    this.notes,
    this.managerApproval,
    this.approvedAt,
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  /// Calculate total working hours
  double get totalWorkingHours {
    if (workingMinutes == null) return 0.0;
    return workingMinutes! / 60.0;
  }

  /// Calculate total break hours
  double get totalBreakHours {
    if (breakMinutes == null) return 0.0;
    return breakMinutes! / 60.0;
  }

  /// Calculate overtime hours
  double get overtimeHours {
    if (overtimeMinutes == null) return 0.0;
    return overtimeMinutes! / 60.0;
  }

  /// Check if employee is late (assuming 9:00 AM standard time)
  bool get isLate {
    if (checkInTime == null) return false;
    final standardCheckIn =
        DateTime(date.year, date.month, date.day, 9, 0); // 9:00 AM
    return checkInTime!.isAfter(standardCheckIn);
  }

  /// Calculate late minutes
  int get lateMinutes {
    if (!isLate) return 0;
    final standardCheckIn = DateTime(date.year, date.month, date.day, 9, 0);
    return checkInTime!.difference(standardCheckIn).inMinutes;
  }

  /// Check if employee left early (assuming 6:00 PM standard time)
  bool get isEarlyLeave {
    if (checkOutTime == null) return false;
    final standardCheckOut =
        DateTime(date.year, date.month, date.day, 18, 0); // 6:00 PM
    return checkOutTime!.isBefore(standardCheckOut);
  }

  /// Calculate early leave minutes
  int get earlyLeaveMinutes {
    if (!isEarlyLeave) return 0;
    final standardCheckOut = DateTime(date.year, date.month, date.day, 18, 0);
    return standardCheckOut.difference(checkOutTime!).inMinutes;
  }

  /// Check if attendance is complete (both check-in and check-out)
  bool get isComplete => checkInTime != null && checkOutTime != null;

  /// Get formatted date string
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Get formatted check-in time
  String get formattedCheckInTime {
    if (checkInTime == null) return '--:--';
    return '${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted check-out time
  String get formattedCheckOutTime {
    if (checkOutTime == null) return '--:--';
    return '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}';
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case AttendanceStatus.present:
        return '#4CAF50'; // Green
      case AttendanceStatus.absent:
        return '#F44336'; // Red
      case AttendanceStatus.halfDay:
        return '#FF9800'; // Orange
      case AttendanceStatus.late:
        return '#FF5722'; // Deep Orange
      case AttendanceStatus.earlyLeave:
        return '#FFC107'; // Amber
      case AttendanceStatus.workFromHome:
        return '#2196F3'; // Blue
    }
  }

  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    List<BreakRecord>? breaks,
    AttendanceStatus? status,
    AttendanceMethod? checkInMethod,
    AttendanceMethod? checkOutMethod,
    String? checkInLocation,
    String? checkOutLocation,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkOutLatitude,
    double? checkOutLongitude,
    int? workingMinutes,
    int? breakMinutes,
    int? overtimeMinutes,
    bool? isWorkFromHome,
    String? notes,
    String? managerApproval,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      breaks: breaks ?? this.breaks,
      status: status ?? this.status,
      checkInMethod: checkInMethod ?? this.checkInMethod,
      checkOutMethod: checkOutMethod ?? this.checkOutMethod,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      workingMinutes: workingMinutes ?? this.workingMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      isWorkFromHome: isWorkFromHome ?? this.isWorkFromHome,
      notes: notes ?? this.notes,
      managerApproval: managerApproval ?? this.managerApproval,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        date,
        checkInTime,
        checkOutTime,
        breaks,
        status,
        checkInMethod,
        checkOutMethod,
        checkInLocation,
        checkOutLocation,
        checkInLatitude,
        checkInLongitude,
        checkOutLatitude,
        checkOutLongitude,
        workingMinutes,
        breakMinutes,
        overtimeMinutes,
        isWorkFromHome,
        notes,
        managerApproval,
        approvedAt,
        approvedBy,
        createdAt,
        updatedAt,
      ];
}

/// Break record model
@JsonSerializable()
class BreakRecord extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String? reason;
  final int? durationMinutes;

  const BreakRecord({
    required this.id,
    required this.startTime,
    this.endTime,
    this.reason,
    this.durationMinutes,
  });

  factory BreakRecord.fromJson(Map<String, dynamic> json) =>
      _$BreakRecordFromJson(json);
  Map<String, dynamic> toJson() => _$BreakRecordToJson(this);

  /// Check if break is ongoing
  bool get isOngoing => endTime == null;

  /// Get break duration in minutes
  int get actualDurationMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }

  /// Get formatted start time
  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted end time
  String get formattedEndTime {
    if (endTime == null) return 'Ongoing';
    return '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [id, startTime, endTime, reason, durationMinutes];
}
