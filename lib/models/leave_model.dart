import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leave_model.g.dart';

/// Leave types as per Sri Lankan labor laws
enum LeaveType {
  annual,      // Annual leave (14 days per year)
  casual,      // Casual leave (7 days per year)
  sick,        // Sick leave (up to 21 days per year)
  maternity,   // Maternity leave (84 days)
  paternity,   // Paternity leave (3-7 days)
  noPay,       // No-pay leave
  halfDay,     // Half day leave
  compensatory, // Compensatory leave for overtime
  study,       // Study leave
  bereavement, // Bereavement leave
  emergency,   // Emergency leave
  medical,     // Medical leave with certificate
}

/// Leave status workflow
enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled,
  withdrawn
}

/// Leave approval levels
enum ApprovalLevel {
  manager,
  hr,
  admin
}

/// Leave request model
@JsonSerializable()
class LeaveModel extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeDepartment;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final bool isHalfDay;
  final String? halfDayPeriod; // morning, afternoon
  final String reason;
  final String? medicalCertificateUrl;
  final String? supportingDocumentUrl;
  final LeaveStatus status;
  final String? rejectionReason;
  final List<LeaveApproval> approvals;
  final String? coveringEmployeeId;
  final String? coveringEmployeeName;
  final String? handoverNotes;
  final bool isEmergency;
  final DateTime appliedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LeaveModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeDepartment,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.isHalfDay = false,
    this.halfDayPeriod,
    required this.reason,
    this.medicalCertificateUrl,
    this.supportingDocumentUrl,
    this.status = LeaveStatus.pending,
    this.rejectionReason,
    this.approvals = const [],
    this.coveringEmployeeId,
    this.coveringEmployeeName,
    this.handoverNotes,
    this.isEmergency = false,
    required this.appliedAt,
    this.approvedAt,
    this.rejectedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) => _$LeaveModelFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveModelToJson(this);

  /// Get leave type display name
  String get leaveTypeDisplayName {
    switch (leaveType) {
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.casual:
        return 'Casual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.maternity:
        return 'Maternity Leave';
      case LeaveType.paternity:
        return 'Paternity Leave';
      case LeaveType.noPay:
        return 'No Pay Leave';
      case LeaveType.halfDay:
        return 'Half Day Leave';
      case LeaveType.compensatory:
        return 'Compensatory Leave';
      case LeaveType.study:
        return 'Study Leave';
      case LeaveType.bereavement:
        return 'Bereavement Leave';
      case LeaveType.emergency:
        return 'Emergency Leave';
      case LeaveType.medical:
        return 'Medical Leave';
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
      case LeaveStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case LeaveStatus.pending:
        return '#FF9800'; // Orange
      case LeaveStatus.approved:
        return '#4CAF50'; // Green
      case LeaveStatus.rejected:
        return '#F44336'; // Red
      case LeaveStatus.cancelled:
        return '#9E9E9E'; // Grey
      case LeaveStatus.withdrawn:
        return '#9E9E9E'; // Grey
    }
  }

  /// Format date range
  String get formattedDateRange {
    if (startDate.day == endDate.day && startDate.month == endDate.month && startDate.year == endDate.year) {
      return '${startDate.day}/${startDate.month}/${startDate.year}';
    }
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }

  /// Check if leave is current (ongoing)
  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Check if leave is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return startDate.isAfter(now);
  }

  /// Check if leave is past
  bool get isPast {
    final now = DateTime.now();
    return endDate.isBefore(now);
  }

  /// Check if leave can be edited
  bool get canBeEdited {
    return status == LeaveStatus.pending && isUpcoming;
  }

  /// Check if leave can be cancelled
  bool get canBeCancelled {
    return (status == LeaveStatus.pending || status == LeaveStatus.approved) && isUpcoming;
  }

  /// Get next required approval level
  ApprovalLevel? get nextApprovalLevel {
    if (status != LeaveStatus.pending) return null;
    
    final approvedBy = approvals.where((a) => a.isApproved).map((a) => a.level).toList();
    
    if (!approvedBy.contains(ApprovalLevel.manager)) {
      return ApprovalLevel.manager;
    }
    
    // For certain leave types, HR approval is required
    if ([LeaveType.maternity, LeaveType.paternity, LeaveType.medical, LeaveType.study].contains(leaveType)) {
      if (!approvedBy.contains(ApprovalLevel.hr)) {
        return ApprovalLevel.hr;
      }
    }
    
    // For long leaves (more than 5 days), admin approval might be required
    if (totalDays > 5 && !approvedBy.contains(ApprovalLevel.admin)) {
      return ApprovalLevel.admin;
    }
    
    return null;
  }

  /// Check if all required approvals are received
  bool get hasAllRequiredApprovals {
    return nextApprovalLevel == null;
  }

  /// Get days until leave starts
  int get daysUntilStart {
    if (!isUpcoming) return 0;
    return startDate.difference(DateTime.now()).inDays;
  }

  LeaveModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? employeeDepartment,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    bool? isHalfDay,
    String? halfDayPeriod,
    String? reason,
    String? medicalCertificateUrl,
    String? supportingDocumentUrl,
    LeaveStatus? status,
    String? rejectionReason,
    List<LeaveApproval>? approvals,
    String? coveringEmployeeId,
    String? coveringEmployeeName,
    String? handoverNotes,
    bool? isEmergency,
    DateTime? appliedAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeDepartment: employeeDepartment ?? this.employeeDepartment,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      isHalfDay: isHalfDay ?? this.isHalfDay,
      halfDayPeriod: halfDayPeriod ?? this.halfDayPeriod,
      reason: reason ?? this.reason,
      medicalCertificateUrl: medicalCertificateUrl ?? this.medicalCertificateUrl,
      supportingDocumentUrl: supportingDocumentUrl ?? this.supportingDocumentUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvals: approvals ?? this.approvals,
      coveringEmployeeId: coveringEmployeeId ?? this.coveringEmployeeId,
      coveringEmployeeName: coveringEmployeeName ?? this.coveringEmployeeName,
      handoverNotes: handoverNotes ?? this.handoverNotes,
      isEmergency: isEmergency ?? this.isEmergency,
      appliedAt: appliedAt ?? this.appliedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        employeeDepartment,
        leaveType,
        startDate,
        endDate,
        totalDays,
        isHalfDay,
        halfDayPeriod,
        reason,
        medicalCertificateUrl,
        supportingDocumentUrl,
        status,
        rejectionReason,
        approvals,
        coveringEmployeeId,
        coveringEmployeeName,
        handoverNotes,
        isEmergency,
        appliedAt,
        approvedAt,
        rejectedAt,
        createdAt,
        updatedAt,
      ];
}

/// Leave approval model
@JsonSerializable()
class LeaveApproval extends Equatable {
  final String id;
  final String approverUserId;
  final String approverName;
  final ApprovalLevel level;
  final bool isApproved;
  final String? comments;
  final DateTime approvedAt;

  const LeaveApproval({
    required this.id,
    required this.approverUserId,
    required this.approverName,
    required this.level,
    required this.isApproved,
    this.comments,
    required this.approvedAt,
  });

  factory LeaveApproval.fromJson(Map<String, dynamic> json) => _$LeaveApprovalFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveApprovalToJson(this);

  String get levelDisplayName {
    switch (level) {
      case ApprovalLevel.manager:
        return 'Manager';
      case ApprovalLevel.hr:
        return 'HR';
      case ApprovalLevel.admin:
        return 'Admin';
    }
  }

  @override
  List<Object?> get props => [
        id,
        approverUserId,
        approverName,
        level,
        isApproved,
        comments,
        approvedAt,
      ];
}

/// Leave balance model for tracking employee leave entitlements
@JsonSerializable()
class LeaveBalanceModel extends Equatable {
  final String id;
  final String employeeId;
  final int year;
  final Map<LeaveType, LeaveBalance> balances;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LeaveBalanceModel({
    required this.id,
    required this.employeeId,
    required this.year,
    required this.balances,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) => _$LeaveBalanceModelFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveBalanceModelToJson(this);

  /// Get balance for a specific leave type
  LeaveBalance? getBalance(LeaveType leaveType) {
    return balances[leaveType];
  }

  /// Get available days for a leave type
  int getAvailableDays(LeaveType leaveType) {
    final balance = getBalance(leaveType);
    return balance?.available ?? 0;
  }

  /// Check if employee can take leave of specific type and days
  bool canTakeLeave(LeaveType leaveType, int days) {
    return getAvailableDays(leaveType) >= days;
  }

  @override
  List<Object?> get props => [id, employeeId, year, balances, createdAt, updatedAt];
}

/// Individual leave balance for a specific type
@JsonSerializable()
class LeaveBalance extends Equatable {
  final LeaveType type;
  final int entitled;   // Total entitled days for the year
  final int used;       // Days already used
  final int pending;    // Days in pending requests
  final int available;  // Available days (entitled - used - pending)
  final double? encashable; // Days that can be encashed
  final DateTime? lastUpdated;

  const LeaveBalance({
    required this.type,
    required this.entitled,
    required this.used,
    required this.pending,
    required this.available,
    this.encashable,
    this.lastUpdated,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) => _$LeaveBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveBalanceToJson(this);

  /// Calculate percentage used
  double get usagePercentage {
    if (entitled == 0) return 0.0;
    return (used / entitled) * 100;
  }

  /// Check if balance is low (less than 20% remaining)
  bool get isLowBalance {
    return usagePercentage > 80;
  }

  @override
  List<Object?> get props => [
        type,
        entitled,
        used,
        pending,
        available,
        encashable,
        lastUpdated,
      ];
}
