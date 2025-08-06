import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/communication_model.dart';
import '../services/communication_service.dart';

// Communication Events
abstract class CommunicationEvent extends Equatable {
  const CommunicationEvent();

  @override
  List<Object?> get props => [];
}

class CommunicationLoadAllRequested extends CommunicationEvent {
  final String? employeeId;
  final String? type;
  final String? status;

  const CommunicationLoadAllRequested({this.employeeId, this.type, this.status});

  @override
  List<Object?> get props => [employeeId, type, status];
}

class CommunicationLoadByIdRequested extends CommunicationEvent {
  final String communicationId;

  const CommunicationLoadByIdRequested({required this.communicationId});

  @override
  List<Object> get props => [communicationId];
}

class CommunicationCreateRequested extends CommunicationEvent {
  final CommunicationModel communication;

  const CommunicationCreateRequested({required this.communication});

  @override
  List<Object> get props => [communication];
}

class CommunicationUpdateRequested extends CommunicationEvent {
  final CommunicationModel communication;

  const CommunicationUpdateRequested({required this.communication});

  @override
  List<Object> get props => [communication];
}

class CommunicationDeleteRequested extends CommunicationEvent {
  final String communicationId;

  const CommunicationDeleteRequested({required this.communicationId});

  @override
  List<Object> get props => [communicationId];
}

class CommunicationMarkAsReadRequested extends CommunicationEvent {
  final String communicationId;
  final String employeeId;

  const CommunicationMarkAsReadRequested({
    required this.communicationId,
    required this.employeeId,
  });

  @override
  List<Object> get props => [communicationId, employeeId];
}

class AnnouncementCreateRequested extends CommunicationEvent {
  final AnnouncementModel announcement;

  const AnnouncementCreateRequested({required this.announcement});

  @override
  List<Object> get props => [announcement];
}

class NotificationSendRequested extends CommunicationEvent {
  final NotificationModel notification;

  const NotificationSendRequested({required this.notification});

  @override
  List<Object> get props => [notification];
}

// Communication States
abstract class CommunicationState extends Equatable {
  const CommunicationState();

  @override
  List<Object?> get props => [];
}

class CommunicationInitial extends CommunicationState {}

class CommunicationLoading extends CommunicationState {}

class CommunicationLoaded extends CommunicationState {
  final List<CommunicationModel> communications;

  const CommunicationLoaded({required this.communications});

  @override
  List<Object> get props => [communications];
}

class CommunicationDetailLoaded extends CommunicationState {
  final CommunicationModel communication;

  const CommunicationDetailLoaded({required this.communication});

  @override
  List<Object> get props => [communication];
}

class CommunicationOperationSuccess extends CommunicationState {
  final String message;

  const CommunicationOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class CommunicationError extends CommunicationState {
  final String message;
  final String? code;

  const CommunicationError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Communication BLoC
class CommunicationBloc extends Bloc<CommunicationEvent, CommunicationState> {
  final CommunicationService _communicationService;

  CommunicationBloc({
    required CommunicationService communicationService,
  })  : _communicationService = communicationService,
        super(CommunicationInitial()) {
    on<CommunicationLoadAllRequested>(_onLoadAllRequested);
    on<CommunicationLoadByIdRequested>(_onLoadByIdRequested);
    on<CommunicationCreateRequested>(_onCreateRequested);
    on<CommunicationUpdateRequested>(_onUpdateRequested);
    on<CommunicationDeleteRequested>(_onDeleteRequested);
    on<CommunicationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<AnnouncementCreateRequested>(_onAnnouncementCreateRequested);
    on<NotificationSendRequested>(_onNotificationSendRequested);
  }

  Future<void> _onLoadAllRequested(
    CommunicationLoadAllRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    emit(CommunicationLoading());
    try {
      final communications = await _communicationService.getAllCommunications(
        employeeId: event.employeeId,
        type: event.type,
        status: event.status,
      );
      emit(CommunicationLoaded(communications: communications));
    } catch (e) {
      emit(CommunicationError(message: 'Failed to load communications: $e'));
    }
  }

  Future<void> _onLoadByIdRequested(
    CommunicationLoadByIdRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    emit(CommunicationLoading());
    try {
      final communication = await _communicationService.getCommunicationById(event.communicationId);
      if (communication != null) {
        emit(CommunicationDetailLoaded(communication: communication));
      } else {
        emit(const CommunicationError(message: 'Communication not found'));
      }
    } catch (e) {
      emit(CommunicationError(message: 'Failed to load communication: $e'));
    }
  }

  Future<void> _onCreateRequested(
    CommunicationCreateRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    emit(CommunicationLoading());
    try {
      await _communicationService.createCommunication(event.communication);
      emit(const CommunicationOperationSuccess(message: 'Communication created successfully'));
      // Reload communications
      add(const CommunicationLoadAllRequested());
    } catch (e) {
      emit(CommunicationError(message: 'Failed to create communication: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    CommunicationUpdateRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    emit(CommunicationLoading());
    try {
      await _communicationService.updateCommunication(event.communication);
      emit(const CommunicationOperationSuccess(message: 'Communication updated successfully'));
      // Reload communications
      add(const CommunicationLoadAllRequested());
    } catch (e) {
      emit(CommunicationError(message: 'Failed to update communication: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    CommunicationDeleteRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    emit(CommunicationLoading());
    try {
      await _communicationService.deleteCommunication(event.communicationId);
      emit(const CommunicationOperationSuccess(message: 'Communication deleted successfully'));
      // Reload communications
      add(const CommunicationLoadAllRequested());
    } catch (e) {
      emit(CommunicationError(message: 'Failed to delete communication: $e'));
    }
  }

  Future<void> _onMarkAsReadRequested(
    CommunicationMarkAsReadRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    try {
      await _communicationService.markAsRead(
        communicationId: event.communicationId,
        employeeId: event.employeeId,
      );
      emit(const CommunicationOperationSuccess(message: 'Marked as read'));
      // Reload communications
      add(CommunicationLoadAllRequested(employeeId: event.employeeId));
    } catch (e) {
      emit(CommunicationError(message: 'Failed to mark as read: $e'));
    }
  }

  Future<void> _onAnnouncementCreateRequested(
    AnnouncementCreateRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    emit(CommunicationLoading());
    try {
      await _communicationService.createAnnouncement(event.announcement);
      emit(const CommunicationOperationSuccess(message: 'Announcement created successfully'));
      // Reload communications
      add(const CommunicationLoadAllRequested());
    } catch (e) {
      emit(CommunicationError(message: 'Failed to create announcement: $e'));
    }
  }

  Future<void> _onNotificationSendRequested(
    NotificationSendRequested event,
    Emitter<CommunicationState> emit,
  ) async {
    emit(CommunicationLoading());
    try {
      await _communicationService.sendNotification(event.notification);
      emit(const CommunicationOperationSuccess(message: 'Notification sent successfully'));
      // Reload communications
      add(const CommunicationLoadAllRequested());
    } catch (e) {
      emit(CommunicationError(message: 'Failed to send notification: $e'));
    }
  }
}
