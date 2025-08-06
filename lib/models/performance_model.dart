import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'performance_model.g.dart';

/// Performance review status
enum PerformanceStatus { draft, submitted, underReview, approved, completed }

/// Goal status
enum GoalStatus { notStarted, inProgress, completed, cancelled }

/// Goal priority levels
enum GoalPriority { low, medium, high, critical }

/// Performance review periods
enum ReviewPeriod { quarterly, halfYearly, yearly }

/// Performance rating scale
enum PerformanceRating {
  outstanding, // 5
  exceeds, // 4
  meets, // 3
  belowExpectations, // 2
  unsatisfactory // 1
}

/// Goal model for individual objectives
@JsonSerializable()
class GoalModel extends Equatable {
  final String id;
  final String employeeId;
  final String title;
  final String description;
  final GoalPriority priority;
  final GoalStatus status;
  final double progress; // 0-100
  final DateTime targetDate;
  final DateTime? completedDate;
  final String? category;
  final List<String>? milestones;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GoalModel({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.description,
    this.priority = GoalPriority.medium,
    this.status = GoalStatus.notStarted,
    this.progress = 0.0,
    required this.targetDate,
    this.completedDate,
    this.category,
    this.milestones,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);
  Map<String, dynamic> toJson() => _$GoalModelToJson(this);

  /// Check if goal is overdue
  bool get isOverdue {
    if (status == GoalStatus.completed) return false;
    return DateTime.now().isAfter(targetDate);
  }

  /// Get days remaining
  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Check if goal is completed
  bool get isCompleted => status == GoalStatus.completed && progress >= 100;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        title,
        description,
        priority,
        status,
        progress,
        targetDate,
        completedDate,
        category,
        milestones,
        notes,
        createdBy,
        createdAt,
        updatedAt,
      ];

  GoalModel copyWith({
    String? id,
    String? employeeId,
    String? title,
    String? description,
    GoalPriority? priority,
    GoalStatus? status,
    double? progress,
    DateTime? targetDate,
    DateTime? completedDate,
    String? category,
    List<String>? milestones,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      targetDate: targetDate ?? this.targetDate,
      completedDate: completedDate ?? this.completedDate,
      category: category ?? this.category,
      milestones: milestones ?? this.milestones,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Performance review model
@JsonSerializable()
class PerformanceReviewModel extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final String reviewerId;
  final String reviewerName;
  final int reviewYear;
  final String reviewPeriod; // Q1, Q2, H1, H2, Annual
  final PerformanceStatus status;
  final List<GoalModel> goals;
  final Map<String, PerformanceRating> competencyRatings;
  final Map<String, String> competencyComments;
  final double overallScore; // 1-5
  final String? strengths;
  final String? areasForImprovement;
  final String? developmentPlan;
  final String? employeeComments;
  final String? managerComments;
  final String? hrComments;
  final List<String>? achievements;
  final List<String>? challenges;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PerformanceReviewModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewYear,
    required this.reviewPeriod,
    this.status = PerformanceStatus.draft,
    this.goals = const [],
    this.competencyRatings = const {},
    this.competencyComments = const {},
    this.overallScore = 0.0,
    this.strengths,
    this.areasForImprovement,
    this.developmentPlan,
    this.employeeComments,
    this.managerComments,
    this.hrComments,
    this.achievements,
    this.challenges,
    this.submittedAt,
    this.reviewedAt,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PerformanceReviewModel.fromJson(Map<String, dynamic> json) =>
      _$PerformanceReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceReviewModelToJson(this);

  /// Calculate average competency rating
  double get averageCompetencyRating {
    if (competencyRatings.isEmpty) return 0.0;
    
    final total = competencyRatings.values
        .map((rating) => _ratingToScore(rating))
        .reduce((a, b) => a + b);
    
    return total / competencyRatings.length;
  }

  /// Convert rating enum to numeric score
  double _ratingToScore(PerformanceRating rating) {
    switch (rating) {
      case PerformanceRating.outstanding:
        return 5.0;
      case PerformanceRating.exceeds:
        return 4.0;
      case PerformanceRating.meets:
        return 3.0;
      case PerformanceRating.belowExpectations:
        return 2.0;
      case PerformanceRating.unsatisfactory:
        return 1.0;
    }
  }

  /// Calculate goal completion percentage
  double get goalCompletionPercentage {
    if (goals.isEmpty) return 0.0;
    
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    return (completedGoals / goals.length) * 100;
  }

  /// Check if review is editable
  bool get isEditable => status == PerformanceStatus.draft;

  /// Check if review can be submitted
  bool get canBeSubmitted => status == PerformanceStatus.draft && overallScore > 0;

  /// Check if review is pending approval
  bool get isPendingApproval => status == PerformanceStatus.submitted || status == PerformanceStatus.underReview;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        reviewerId,
        reviewerName,
        reviewYear,
        reviewPeriod,
        status,
        goals,
        competencyRatings,
        competencyComments,
        overallScore,
        strengths,
        areasForImprovement,
        developmentPlan,
        employeeComments,
        managerComments,
        hrComments,
        achievements,
        challenges,
        submittedAt,
        reviewedAt,
        approvedBy,
        approvedAt,
        createdAt,
        updatedAt,
      ];

  PerformanceReviewModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? reviewerId,
    String? reviewerName,
    int? reviewYear,
    String? reviewPeriod,
    PerformanceStatus? status,
    List<GoalModel>? goals,
    Map<String, PerformanceRating>? competencyRatings,
    Map<String, String>? competencyComments,
    double? overallScore,
    String? strengths,
    String? areasForImprovement,
    String? developmentPlan,
    String? employeeComments,
    String? managerComments,
    String? hrComments,
    List<String>? achievements,
    List<String>? challenges,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PerformanceReviewModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewYear: reviewYear ?? this.reviewYear,
      reviewPeriod: reviewPeriod ?? this.reviewPeriod,
      status: status ?? this.status,
      goals: goals ?? this.goals,
      competencyRatings: competencyRatings ?? this.competencyRatings,
      competencyComments: competencyComments ?? this.competencyComments,
      overallScore: overallScore ?? this.overallScore,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      developmentPlan: developmentPlan ?? this.developmentPlan,
      employeeComments: employeeComments ?? this.employeeComments,
      managerComments: managerComments ?? this.managerComments,
      hrComments: hrComments ?? this.hrComments,
      achievements: achievements ?? this.achievements,
      challenges: challenges ?? this.challenges,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
