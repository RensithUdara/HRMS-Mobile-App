import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/performance_model.dart';
import '../services/performance_service.dart';

// Performance Events
abstract class PerformanceEvent extends Equatable {
  const PerformanceEvent();

  @override
  List<Object?> get props => [];
}

class PerformanceLoadAllRequested extends PerformanceEvent {
  final String? employeeId;
  final int? year;
  final String? period;

  const PerformanceLoadAllRequested({this.employeeId, this.year, this.period});

  @override
  List<Object?> get props => [employeeId, year, period];
}

class PerformanceLoadByIdRequested extends PerformanceEvent {
  final String performanceId;

  const PerformanceLoadByIdRequested({required this.performanceId});

  @override
  List<Object> get props => [performanceId];
}

class PerformanceCreateRequested extends PerformanceEvent {
  final PerformanceReviewModel review;

  const PerformanceCreateRequested({required this.review});

  @override
  List<Object> get props => [review];
}

class PerformanceUpdateRequested extends PerformanceEvent {
  final PerformanceReviewModel review;

  const PerformanceUpdateRequested({required this.review});

  @override
  List<Object> get props => [review];
}

class PerformanceDeleteRequested extends PerformanceEvent {
  final String performanceId;

  const PerformanceDeleteRequested({required this.performanceId});

  @override
  List<Object> get props => [performanceId];
}

class GoalCreateRequested extends PerformanceEvent {
  final GoalModel goal;

  const GoalCreateRequested({required this.goal});

  @override
  List<Object> get props => [goal];
}

class GoalUpdateRequested extends PerformanceEvent {
  final GoalModel goal;

  const GoalUpdateRequested({required this.goal});

  @override
  List<Object> get props => [goal];
}

class PerformanceSubmitRequested extends PerformanceEvent {
  final String performanceId;

  const PerformanceSubmitRequested({required this.performanceId});

  @override
  List<Object> get props => [performanceId];
}

class PerformanceApproveRequested extends PerformanceEvent {
  final String performanceId;
  final String approverId;
  final String comments;

  const PerformanceApproveRequested({
    required this.performanceId,
    required this.approverId,
    required this.comments,
  });

  @override
  List<Object> get props => [performanceId, approverId, comments];
}

// Performance States
abstract class PerformanceState extends Equatable {
  const PerformanceState();

  @override
  List<Object?> get props => [];
}

class PerformanceInitial extends PerformanceState {}

class PerformanceLoading extends PerformanceState {}

class PerformanceLoaded extends PerformanceState {
  final List<PerformanceReviewModel> reviews;

  const PerformanceLoaded({required this.reviews});

  @override
  List<Object> get props => [reviews];
}

class PerformanceDetailLoaded extends PerformanceState {
  final PerformanceReviewModel review;

  const PerformanceDetailLoaded({required this.review});

  @override
  List<Object> get props => [review];
}

class PerformanceOperationSuccess extends PerformanceState {
  final String message;

  const PerformanceOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class PerformanceError extends PerformanceState {
  final String message;
  final String? code;

  const PerformanceError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Performance BLoC
class PerformanceBloc extends Bloc<PerformanceEvent, PerformanceState> {
  final PerformanceService _performanceService;

  PerformanceBloc({
    required PerformanceService performanceService,
  })  : _performanceService = performanceService,
        super(PerformanceInitial()) {
    on<PerformanceLoadAllRequested>(_onLoadAllRequested);
    on<PerformanceLoadByIdRequested>(_onLoadByIdRequested);
    on<PerformanceCreateRequested>(_onCreateRequested);
    on<PerformanceUpdateRequested>(_onUpdateRequested);
    on<PerformanceDeleteRequested>(_onDeleteRequested);
    on<GoalCreateRequested>(_onGoalCreateRequested);
    on<GoalUpdateRequested>(_onGoalUpdateRequested);
    on<PerformanceSubmitRequested>(_onSubmitRequested);
    on<PerformanceApproveRequested>(_onApproveRequested);
  }

  Future<void> _onLoadAllRequested(
    PerformanceLoadAllRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoading());
    try {
      final reviews = await _performanceService.getAllPerformanceReviews(
        employeeId: event.employeeId,
        year: event.year,
        period: event.period,
      );
      emit(PerformanceLoaded(reviews: reviews));
    } catch (e) {
      emit(PerformanceError(message: 'Failed to load performance reviews: $e'));
    }
  }

  Future<void> _onLoadByIdRequested(
    PerformanceLoadByIdRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoading());
    try {
      final review = await _performanceService.getPerformanceReviewById(event.performanceId);
      if (review != null) {
        emit(PerformanceDetailLoaded(review: review));
      } else {
        emit(const PerformanceError(message: 'Performance review not found'));
      }
    } catch (e) {
      emit(PerformanceError(message: 'Failed to load performance review: $e'));
    }
  }

  Future<void> _onCreateRequested(
    PerformanceCreateRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoading());
    try {
      await _performanceService.createPerformanceReview(event.review);
      emit(const PerformanceOperationSuccess(message: 'Performance review created successfully'));
      // Reload reviews
      add(PerformanceLoadAllRequested(employeeId: event.review.employeeId));
    } catch (e) {
      emit(PerformanceError(message: 'Failed to create performance review: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    PerformanceUpdateRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoading());
    try {
      await _performanceService.updatePerformanceReview(event.review);
      emit(const PerformanceOperationSuccess(message: 'Performance review updated successfully'));
      // Reload reviews
      add(PerformanceLoadAllRequested(employeeId: event.review.employeeId));
    } catch (e) {
      emit(PerformanceError(message: 'Failed to update performance review: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    PerformanceDeleteRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoading());
    try {
      await _performanceService.deletePerformanceReview(event.performanceId);
      emit(const PerformanceOperationSuccess(message: 'Performance review deleted successfully'));
      // Reload reviews
      add(const PerformanceLoadAllRequested());
    } catch (e) {
      emit(PerformanceError(message: 'Failed to delete performance review: $e'));
    }
  }

  Future<void> _onGoalCreateRequested(
    GoalCreateRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoading());
    try {
      await _performanceService.createGoal(event.goal);
      emit(const PerformanceOperationSuccess(message: 'Goal created successfully'));
      // Reload reviews
      add(PerformanceLoadAllRequested(employeeId: event.goal.employeeId));
    } catch (e) {
      emit(PerformanceError(message: 'Failed to create goal: $e'));
    }
  }

  Future<void> _onGoalUpdateRequested(
    GoalUpdateRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoading());
    try {
      await _performanceService.updateGoal(event.goal);
      emit(const PerformanceOperationSuccess(message: 'Goal updated successfully'));
      // Reload reviews
      add(PerformanceLoadAllRequested(employeeId: event.goal.employeeId));
    } catch (e) {
      emit(PerformanceError(message: 'Failed to update goal: $e'));
    }
  }

  Future<void> _onSubmitRequested(
    PerformanceSubmitRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoading());
    try {
      await _performanceService.submitPerformanceReview(event.performanceId);
      emit(const PerformanceOperationSuccess(message: 'Performance review submitted successfully'));
      // Reload reviews
      add(const PerformanceLoadAllRequested());
    } catch (e) {
      emit(PerformanceError(message: 'Failed to submit performance review: $e'));
    }
  }

  Future<void> _onApproveRequested(
    PerformanceApproveRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(PerformanceLoading());
    try {
      await _performanceService.approvePerformanceReview(
        performanceId: event.performanceId,
        approverId: event.approverId,
        comments: event.comments,
      );
      emit(const PerformanceOperationSuccess(message: 'Performance review approved successfully'));
      // Reload reviews
      add(const PerformanceLoadAllRequested());
    } catch (e) {
      emit(PerformanceError(message: 'Failed to approve performance review: $e'));
    }
  }
}
