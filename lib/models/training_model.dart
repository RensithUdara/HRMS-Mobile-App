import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'training_model.g.dart';

/// Training program status
enum TrainingProgramStatus { draft, active, completed, cancelled }

/// Training delivery method
enum TrainingDeliveryMethod { online, inPerson, hybrid, selfPaced }

/// Training status for enrollments
enum TrainingStatus { enrolled, inProgress, completed, cancelled, failed }

/// Training category
enum TrainingCategory {
  technical,
  leadership,
  softSkills,
  compliance,
  safety,
  orientation,
  professional,
  certification
}

/// Training program model
@JsonSerializable()
class TrainingProgramModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final TrainingCategory category;
  final TrainingDeliveryMethod deliveryMethod;
  final TrainingProgramStatus status;
  final String instructor;
  final String? instructorBio;
  final String? instructorImageUrl;
  final int duration; // in hours
  final int capacity;
  final int enrolledCount;
  final double? cost;
  final String? location;
  final String? onlineUrl;
  final List<String>? prerequisites;
  final List<String>? learningObjectives;
  final List<String>? materials;
  final List<String>? attachments;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? registrationDeadline;
  final String? certificationType;
  final bool isApprovalRequired;
  final bool isMandatory;
  final List<String>? targetRoles;
  final List<String>? targetDepartments;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrainingProgramModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.deliveryMethod,
    this.status = TrainingProgramStatus.draft,
    required this.instructor,
    this.instructorBio,
    this.instructorImageUrl,
    required this.duration,
    required this.capacity,
    this.enrolledCount = 0,
    this.cost,
    this.location,
    this.onlineUrl,
    this.prerequisites,
    this.learningObjectives,
    this.materials,
    this.attachments,
    required this.startDate,
    required this.endDate,
    this.registrationDeadline,
    this.certificationType,
    this.isApprovalRequired = false,
    this.isMandatory = false,
    this.targetRoles,
    this.targetDepartments,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingProgramModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingProgramModelFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingProgramModelToJson(this);

  /// Check if training is available for enrollment
  bool get isAvailableForEnrollment {
    if (status != TrainingProgramStatus.active) return false;
    if (enrolledCount >= capacity) return false;
    if (registrationDeadline != null && DateTime.now().isAfter(registrationDeadline!)) return false;
    return true;
  }

  /// Check if training is full
  bool get isFull => enrolledCount >= capacity;

  /// Get available spots
  int get availableSpots => capacity - enrolledCount;

  /// Check if training has started
  bool get hasStarted => DateTime.now().isAfter(startDate);

  /// Check if training has ended
  bool get hasEnded => DateTime.now().isAfter(endDate);

  /// Check if training is ongoing
  bool get isOngoing => hasStarted && !hasEnded;

  /// Get enrollment percentage
  double get enrollmentPercentage => (enrolledCount / capacity) * 100;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        deliveryMethod,
        status,
        instructor,
        instructorBio,
        instructorImageUrl,
        duration,
        capacity,
        enrolledCount,
        cost,
        location,
        onlineUrl,
        prerequisites,
        learningObjectives,
        materials,
        attachments,
        startDate,
        endDate,
        registrationDeadline,
        certificationType,
        isApprovalRequired,
        isMandatory,
        targetRoles,
        targetDepartments,
        createdBy,
        createdAt,
        updatedAt,
      ];

  TrainingProgramModel copyWith({
    String? id,
    String? title,
    String? description,
    TrainingCategory? category,
    TrainingDeliveryMethod? deliveryMethod,
    TrainingProgramStatus? status,
    String? instructor,
    String? instructorBio,
    String? instructorImageUrl,
    int? duration,
    int? capacity,
    int? enrolledCount,
    double? cost,
    String? location,
    String? onlineUrl,
    List<String>? prerequisites,
    List<String>? learningObjectives,
    List<String>? materials,
    List<String>? attachments,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationDeadline,
    String? certificationType,
    bool? isApprovalRequired,
    bool? isMandatory,
    List<String>? targetRoles,
    List<String>? targetDepartments,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingProgramModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      status: status ?? this.status,
      instructor: instructor ?? this.instructor,
      instructorBio: instructorBio ?? this.instructorBio,
      instructorImageUrl: instructorImageUrl ?? this.instructorImageUrl,
      duration: duration ?? this.duration,
      capacity: capacity ?? this.capacity,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      cost: cost ?? this.cost,
      location: location ?? this.location,
      onlineUrl: onlineUrl ?? this.onlineUrl,
      prerequisites: prerequisites ?? this.prerequisites,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      materials: materials ?? this.materials,
      attachments: attachments ?? this.attachments,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      certificationType: certificationType ?? this.certificationType,
      isApprovalRequired: isApprovalRequired ?? this.isApprovalRequired,
      isMandatory: isMandatory ?? this.isMandatory,
      targetRoles: targetRoles ?? this.targetRoles,
      targetDepartments: targetDepartments ?? this.targetDepartments,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Training enrollment model
@JsonSerializable()
class TrainingEnrollmentModel extends Equatable {
  final String id;
  final String trainingId;
  final String employeeId;
  final String employeeName;
  final TrainingStatus status;
  final double progress; // 0-100
  final double? score;
  final String? feedback;
  final String? certificateUrl;
  final DateTime? certificateUploadedAt;
  final DateTime enrolledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime updatedAt;

  const TrainingEnrollmentModel({
    required this.id,
    required this.trainingId,
    required this.employeeId,
    required this.employeeName,
    this.status = TrainingStatus.enrolled,
    this.progress = 0.0,
    this.score,
    this.feedback,
    this.certificateUrl,
    this.certificateUploadedAt,
    required this.enrolledAt,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.approvedBy,
    this.approvedAt,
    required this.updatedAt,
  });

  factory TrainingEnrollmentModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingEnrollmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingEnrollmentModelToJson(this);

  /// Check if training is completed
  bool get isCompleted => status == TrainingStatus.completed;

  /// Check if training is in progress
  bool get isInProgress => status == TrainingStatus.inProgress;

  /// Check if certificate is available
  bool get hasCertificate => certificateUrl != null && certificateUrl!.isNotEmpty;

  /// Get completion percentage as string
  String get progressPercentage => '${progress.toStringAsFixed(0)}%';

  @override
  List<Object?> get props => [
        id,
        trainingId,
        employeeId,
        employeeName,
        status,
        progress,
        score,
        feedback,
        certificateUrl,
        certificateUploadedAt,
        enrolledAt,
        startedAt,
        completedAt,
        notes,
        approvedBy,
        approvedAt,
        updatedAt,
      ];

  TrainingEnrollmentModel copyWith({
    String? id,
    String? trainingId,
    String? employeeId,
    String? employeeName,
    TrainingStatus? status,
    double? progress,
    double? score,
    String? feedback,
    String? certificateUrl,
    DateTime? certificateUploadedAt,
    DateTime? enrolledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? updatedAt,
  }) {
    return TrainingEnrollmentModel(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      certificateUploadedAt: certificateUploadedAt ?? this.certificateUploadedAt,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
