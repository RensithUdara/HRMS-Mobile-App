// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => GoalModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: $enumDecodeNullable(_$GoalPriorityEnumMap, json['priority']) ??
          GoalPriority.medium,
      status: $enumDecodeNullable(_$GoalStatusEnumMap, json['status']) ??
          GoalStatus.notStarted,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(json['targetDate'] as String),
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      category: json['category'] as String?,
      milestones: (json['milestones'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GoalModelToJson(GoalModel instance) => <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'title': instance.title,
      'description': instance.description,
      'priority': _$GoalPriorityEnumMap[instance.priority]!,
      'status': _$GoalStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'targetDate': instance.targetDate.toIso8601String(),
      'completedDate': instance.completedDate?.toIso8601String(),
      'category': instance.category,
      'milestones': instance.milestones,
      'notes': instance.notes,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$GoalPriorityEnumMap = {
  GoalPriority.low: 'low',
  GoalPriority.medium: 'medium',
  GoalPriority.high: 'high',
  GoalPriority.critical: 'critical',
};

const _$GoalStatusEnumMap = {
  GoalStatus.notStarted: 'notStarted',
  GoalStatus.inProgress: 'inProgress',
  GoalStatus.completed: 'completed',
  GoalStatus.cancelled: 'cancelled',
};

PerformanceReviewModel _$PerformanceReviewModelFromJson(
        Map<String, dynamic> json) =>
    PerformanceReviewModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      reviewerId: json['reviewerId'] as String,
      reviewerName: json['reviewerName'] as String,
      reviewYear: (json['reviewYear'] as num).toInt(),
      reviewPeriod: json['reviewPeriod'] as String,
      status: $enumDecodeNullable(_$PerformanceStatusEnumMap, json['status']) ??
          PerformanceStatus.draft,
      goals: (json['goals'] as List<dynamic>?)
              ?.map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      competencyRatings:
          (json['competencyRatings'] as Map<String, dynamic>?)?.map(
                (k, e) =>
                    MapEntry(k, $enumDecode(_$PerformanceRatingEnumMap, e)),
              ) ??
              const {},
      competencyComments:
          (json['competencyComments'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {},
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
      strengths: json['strengths'] as String?,
      areasForImprovement: json['areasForImprovement'] as String?,
      developmentPlan: json['developmentPlan'] as String?,
      employeeComments: json['employeeComments'] as String?,
      managerComments: json['managerComments'] as String?,
      hrComments: json['hrComments'] as String?,
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      challenges: (json['challenges'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PerformanceReviewModelToJson(
        PerformanceReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'reviewerId': instance.reviewerId,
      'reviewerName': instance.reviewerName,
      'reviewYear': instance.reviewYear,
      'reviewPeriod': instance.reviewPeriod,
      'status': _$PerformanceStatusEnumMap[instance.status]!,
      'goals': instance.goals,
      'competencyRatings': instance.competencyRatings
          .map((k, e) => MapEntry(k, _$PerformanceRatingEnumMap[e]!)),
      'competencyComments': instance.competencyComments,
      'overallScore': instance.overallScore,
      'strengths': instance.strengths,
      'areasForImprovement': instance.areasForImprovement,
      'developmentPlan': instance.developmentPlan,
      'employeeComments': instance.employeeComments,
      'managerComments': instance.managerComments,
      'hrComments': instance.hrComments,
      'achievements': instance.achievements,
      'challenges': instance.challenges,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PerformanceStatusEnumMap = {
  PerformanceStatus.draft: 'draft',
  PerformanceStatus.submitted: 'submitted',
  PerformanceStatus.underReview: 'underReview',
  PerformanceStatus.approved: 'approved',
  PerformanceStatus.completed: 'completed',
};

const _$PerformanceRatingEnumMap = {
  PerformanceRating.outstanding: 'outstanding',
  PerformanceRating.exceeds: 'exceeds',
  PerformanceRating.meets: 'meets',
  PerformanceRating.belowExpectations: 'belowExpectations',
  PerformanceRating.unsatisfactory: 'unsatisfactory',
};
