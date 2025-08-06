import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/training_model.dart';
import '../services/training_service.dart';

// Training Events
abstract class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object?> get props => [];
}

class TrainingLoadAllRequested extends TrainingEvent {
  final String? employeeId;
  final String? status;
  final String? category;

  const TrainingLoadAllRequested({this.employeeId, this.status, this.category});

  @override
  List<Object?> get props => [employeeId, status, category];
}

class TrainingLoadByIdRequested extends TrainingEvent {
  final String trainingId;

  const TrainingLoadByIdRequested({required this.trainingId});

  @override
  List<Object> get props => [trainingId];
}

class TrainingCreateRequested extends TrainingEvent {
  final TrainingProgramModel training;

  const TrainingCreateRequested({required this.training});

  @override
  List<Object> get props => [training];
}

class TrainingUpdateRequested extends TrainingEvent {
  final TrainingProgramModel training;

  const TrainingUpdateRequested({required this.training});

  @override
  List<Object> get props => [training];
}

class TrainingDeleteRequested extends TrainingEvent {
  final String trainingId;

  const TrainingDeleteRequested({required this.trainingId});

  @override
  List<Object> get props => [trainingId];
}

class TrainingEnrollRequested extends TrainingEvent {
  final String trainingId;
  final String employeeId;

  const TrainingEnrollRequested({
    required this.trainingId,
    required this.employeeId,
  });

  @override
  List<Object> get props => [trainingId, employeeId];
}

class TrainingCompleteRequested extends TrainingEvent {
  final String enrollmentId;
  final double score;
  final String feedback;

  const TrainingCompleteRequested({
    required this.enrollmentId,
    required this.score,
    required this.feedback,
  });

  @override
  List<Object> get props => [enrollmentId, score, feedback];
}

class TrainingCertificateUploadRequested extends TrainingEvent {
  final String enrollmentId;
  final String certificateUrl;

  const TrainingCertificateUploadRequested({
    required this.enrollmentId,
    required this.certificateUrl,
  });

  @override
  List<Object> get props => [enrollmentId, certificateUrl];
}

// Training States
abstract class TrainingState extends Equatable {
  const TrainingState();

  @override
  List<Object?> get props => [];
}

class TrainingInitial extends TrainingState {}

class TrainingLoading extends TrainingState {}

class TrainingLoaded extends TrainingState {
  final List<TrainingProgramModel> trainings;

  const TrainingLoaded({required this.trainings});

  @override
  List<Object> get props => [trainings];
}

class TrainingDetailLoaded extends TrainingState {
  final TrainingProgramModel training;

  const TrainingDetailLoaded({required this.training});

  @override
  List<Object> get props => [training];
}

class TrainingOperationSuccess extends TrainingState {
  final String message;

  const TrainingOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class TrainingError extends TrainingState {
  final String message;
  final String? code;

  const TrainingError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Training BLoC
class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  final TrainingService _trainingService;

  TrainingBloc({
    required TrainingService trainingService,
  })  : _trainingService = trainingService,
        super(TrainingInitial()) {
    on<TrainingLoadAllRequested>(_onLoadAllRequested);
    on<TrainingLoadByIdRequested>(_onLoadByIdRequested);
    on<TrainingCreateRequested>(_onCreateRequested);
    on<TrainingUpdateRequested>(_onUpdateRequested);
    on<TrainingDeleteRequested>(_onDeleteRequested);
    on<TrainingEnrollRequested>(_onEnrollRequested);
    on<TrainingCompleteRequested>(_onCompleteRequested);
    on<TrainingCertificateUploadRequested>(_onCertificateUploadRequested);
  }

  Future<void> _onLoadAllRequested(
    TrainingLoadAllRequested event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoading());
    try {
      final trainings = await _trainingService.getAllTrainingPrograms(
        employeeId: event.employeeId,
        status: event.status,
        category: event.category,
      );
      emit(TrainingLoaded(trainings: trainings));
    } catch (e) {
      emit(TrainingError(message: 'Failed to load training programs: $e'));
    }
  }

  Future<void> _onLoadByIdRequested(
    TrainingLoadByIdRequested event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoading());
    try {
      final training = await _trainingService.getTrainingProgramById(event.trainingId);
      if (training != null) {
        emit(TrainingDetailLoaded(training: training));
      } else {
        emit(const TrainingError(message: 'Training program not found'));
      }
    } catch (e) {
      emit(TrainingError(message: 'Failed to load training program: $e'));
    }
  }

  Future<void> _onCreateRequested(
    TrainingCreateRequested event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoading());
    try {
      await _trainingService.createTrainingProgram(event.training);
      emit(const TrainingOperationSuccess(message: 'Training program created successfully'));
      // Reload trainings
      add(const TrainingLoadAllRequested());
    } catch (e) {
      emit(TrainingError(message: 'Failed to create training program: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    TrainingUpdateRequested event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoading());
    try {
      await _trainingService.updateTrainingProgram(event.training);
      emit(const TrainingOperationSuccess(message: 'Training program updated successfully'));
      // Reload trainings
      add(const TrainingLoadAllRequested());
    } catch (e) {
      emit(TrainingError(message: 'Failed to update training program: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    TrainingDeleteRequested event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoading());
    try {
      await _trainingService.deleteTrainingProgram(event.trainingId);
      emit(const TrainingOperationSuccess(message: 'Training program deleted successfully'));
      // Reload trainings
      add(const TrainingLoadAllRequested());
    } catch (e) {
      emit(TrainingError(message: 'Failed to delete training program: $e'));
    }
  }

  Future<void> _onEnrollRequested(
    TrainingEnrollRequested event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoading());
    try {
      await _trainingService.enrollInTraining(
        trainingId: event.trainingId,
        employeeId: event.employeeId,
      );
      emit(const TrainingOperationSuccess(message: 'Successfully enrolled in training program'));
      // Reload trainings
      add(const TrainingLoadAllRequested());
    } catch (e) {
      emit(TrainingError(message: 'Failed to enroll in training: $e'));
    }
  }

  Future<void> _onCompleteRequested(
    TrainingCompleteRequested event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoading());
    try {
      await _trainingService.completeTraining(
        enrollmentId: event.enrollmentId,
        score: event.score,
        feedback: event.feedback,
      );
      emit(const TrainingOperationSuccess(message: 'Training completed successfully'));
      // Reload trainings
      add(const TrainingLoadAllRequested());
    } catch (e) {
      emit(TrainingError(message: 'Failed to complete training: $e'));
    }
  }

  Future<void> _onCertificateUploadRequested(
    TrainingCertificateUploadRequested event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoading());
    try {
      await _trainingService.uploadCertificate(
        enrollmentId: event.enrollmentId,
        certificateUrl: event.certificateUrl,
      );
      emit(const TrainingOperationSuccess(message: 'Certificate uploaded successfully'));
      // Reload trainings
      add(const TrainingLoadAllRequested());
    } catch (e) {
      emit(TrainingError(message: 'Failed to upload certificate: $e'));
    }
  }
}
