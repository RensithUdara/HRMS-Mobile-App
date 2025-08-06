// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingProgramModel _$TrainingProgramModelFromJson(
        Map<String, dynamic> json) =>
    TrainingProgramModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$TrainingCategoryEnumMap, json['category']),
      deliveryMethod:
          $enumDecode(_$TrainingDeliveryMethodEnumMap, json['deliveryMethod']),
      status:
          $enumDecodeNullable(_$TrainingProgramStatusEnumMap, json['status']) ??
              TrainingProgramStatus.draft,
      instructor: json['instructor'] as String,
      instructorBio: json['instructorBio'] as String?,
      instructorImageUrl: json['instructorImageUrl'] as String?,
      duration: (json['duration'] as num).toInt(),
      capacity: (json['capacity'] as num).toInt(),
      enrolledCount: (json['enrolledCount'] as num?)?.toInt() ?? 0,
      cost: (json['cost'] as num?)?.toDouble(),
      location: json['location'] as String?,
      onlineUrl: json['onlineUrl'] as String?,
      prerequisites: (json['prerequisites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      learningObjectives: (json['learningObjectives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      materials: (json['materials'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      registrationDeadline: json['registrationDeadline'] == null
          ? null
          : DateTime.parse(json['registrationDeadline'] as String),
      certificationType: json['certificationType'] as String?,
      isApprovalRequired: json['isApprovalRequired'] as bool? ?? false,
      isMandatory: json['isMandatory'] as bool? ?? false,
      targetRoles: (json['targetRoles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      targetDepartments: (json['targetDepartments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrainingProgramModelToJson(
        TrainingProgramModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': _$TrainingCategoryEnumMap[instance.category]!,
      'deliveryMethod':
          _$TrainingDeliveryMethodEnumMap[instance.deliveryMethod]!,
      'status': _$TrainingProgramStatusEnumMap[instance.status]!,
      'instructor': instance.instructor,
      'instructorBio': instance.instructorBio,
      'instructorImageUrl': instance.instructorImageUrl,
      'duration': instance.duration,
      'capacity': instance.capacity,
      'enrolledCount': instance.enrolledCount,
      'cost': instance.cost,
      'location': instance.location,
      'onlineUrl': instance.onlineUrl,
      'prerequisites': instance.prerequisites,
      'learningObjectives': instance.learningObjectives,
      'materials': instance.materials,
      'attachments': instance.attachments,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'registrationDeadline': instance.registrationDeadline?.toIso8601String(),
      'certificationType': instance.certificationType,
      'isApprovalRequired': instance.isApprovalRequired,
      'isMandatory': instance.isMandatory,
      'targetRoles': instance.targetRoles,
      'targetDepartments': instance.targetDepartments,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TrainingCategoryEnumMap = {
  TrainingCategory.technical: 'technical',
  TrainingCategory.leadership: 'leadership',
  TrainingCategory.softSkills: 'softSkills',
  TrainingCategory.compliance: 'compliance',
  TrainingCategory.safety: 'safety',
  TrainingCategory.orientation: 'orientation',
  TrainingCategory.professional: 'professional',
  TrainingCategory.certification: 'certification',
};

const _$TrainingDeliveryMethodEnumMap = {
  TrainingDeliveryMethod.online: 'online',
  TrainingDeliveryMethod.inPerson: 'inPerson',
  TrainingDeliveryMethod.hybrid: 'hybrid',
  TrainingDeliveryMethod.selfPaced: 'selfPaced',
};

const _$TrainingProgramStatusEnumMap = {
  TrainingProgramStatus.draft: 'draft',
  TrainingProgramStatus.active: 'active',
  TrainingProgramStatus.completed: 'completed',
  TrainingProgramStatus.cancelled: 'cancelled',
};

TrainingEnrollmentModel _$TrainingEnrollmentModelFromJson(
        Map<String, dynamic> json) =>
    TrainingEnrollmentModel(
      id: json['id'] as String,
      trainingId: json['trainingId'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      status: $enumDecodeNullable(_$TrainingStatusEnumMap, json['status']) ??
          TrainingStatus.enrolled,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      score: (json['score'] as num?)?.toDouble(),
      feedback: json['feedback'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      certificateUploadedAt: json['certificateUploadedAt'] == null
          ? null
          : DateTime.parse(json['certificateUploadedAt'] as String),
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrainingEnrollmentModelToJson(
        TrainingEnrollmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainingId': instance.trainingId,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'status': _$TrainingStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'score': instance.score,
      'feedback': instance.feedback,
      'certificateUrl': instance.certificateUrl,
      'certificateUploadedAt':
          instance.certificateUploadedAt?.toIso8601String(),
      'enrolledAt': instance.enrolledAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'notes': instance.notes,
      'approvedBy': instance.approvedBy,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TrainingStatusEnumMap = {
  TrainingStatus.enrolled: 'enrolled',
  TrainingStatus.inProgress: 'inProgress',
  TrainingStatus.completed: 'completed',
  TrainingStatus.cancelled: 'cancelled',
  TrainingStatus.failed: 'failed',
};
