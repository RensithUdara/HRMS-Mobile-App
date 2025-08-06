import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/leave_model.dart';
import '../services/leave_service.dart';

// Leave Events
abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class LeaveLoadAllRequested extends LeaveEvent {
  final String? employeeId;
  final LeaveStatus? status;

  const LeaveLoadAllRequested({this.employeeId, this.status});

  @override
  List<Object?> get props => [employeeId, status];
}

class LeaveLoadByIdRequested extends LeaveEvent {
  final String leaveId;

  const LeaveLoadByIdRequested({required this.leaveId});

  @override
  List<Object> get props => [leaveId];
}

class LeaveCreateRequested extends LeaveEvent {
  final LeaveModel leave;

  const LeaveCreateRequested({required this.leave});

  @override
  List<Object> get props => [leave];
}

class LeaveUpdateRequested extends LeaveEvent {
  final LeaveModel leave;

  const LeaveUpdateRequested({required this.leave});

  @override
  List<Object> get props => [leave];
}

class LeaveDeleteRequested extends LeaveEvent {
  final String leaveId;

  const LeaveDeleteRequested({required this.leaveId});

  @override
  List<Object> get props => [leaveId];
}

class LeaveApproveRequested extends LeaveEvent {
  final String leaveId;
  final String approverId;
  final String? comments;

  const LeaveApproveRequested({
    required this.leaveId,
    required this.approverId,
    this.comments,
  });

  @override
  List<Object?> get props => [leaveId, approverId, comments];
}

class LeaveRejectRequested extends LeaveEvent {
  final String leaveId;
  final String approverId;
  final String reason;

  const LeaveRejectRequested({
    required this.leaveId,
    required this.approverId,
    required this.reason,
  });

  @override
  List<Object> get props => [leaveId, approverId, reason];
}

class LeaveBalanceLoadRequested extends LeaveEvent {
  final String employeeId;

  const LeaveBalanceLoadRequested({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

// Leave States
abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object?> get props => [];
}

class LeaveInitial extends LeaveState {}

class LeaveLoading extends LeaveState {}

class LeaveLoaded extends LeaveState {
  final List<LeaveModel> leaves;

  const LeaveLoaded({required this.leaves});

  @override
  List<Object> get props => [leaves];
}

class LeaveDetailLoaded extends LeaveState {
  final LeaveModel leave;

  const LeaveDetailLoaded({required this.leave});

  @override
  List<Object> get props => [leave];
}

class LeaveBalanceLoaded extends LeaveState {
  final Map<LeaveType, int> leaveBalance;

  const LeaveBalanceLoaded({required this.leaveBalance});

  @override
  List<Object> get props => [leaveBalance];
}

class LeaveOperationSuccess extends LeaveState {
  final String message;

  const LeaveOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class LeaveError extends LeaveState {
  final String message;
  final String? code;

  const LeaveError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Leave BLoC
class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveService _leaveService;

  LeaveBloc({
    required LeaveService leaveService,
  })  : _leaveService = leaveService,
        super(LeaveInitial()) {
    on<LeaveLoadAllRequested>(_onLoadAllRequested);
    on<LeaveLoadByIdRequested>(_onLoadByIdRequested);
    on<LeaveCreateRequested>(_onCreateRequested);
    on<LeaveUpdateRequested>(_onUpdateRequested);
    on<LeaveDeleteRequested>(_onDeleteRequested);
    on<LeaveApproveRequested>(_onApproveRequested);
    on<LeaveRejectRequested>(_onRejectRequested);
    on<LeaveBalanceLoadRequested>(_onBalanceLoadRequested);
  }

  Future<void> _onLoadAllRequested(
    LeaveLoadAllRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leaves = await _leaveService.getAllLeaves(
        employeeId: event.employeeId,
        status: event.status,
      );
      emit(LeaveLoaded(leaves: leaves));
    } catch (e) {
      emit(LeaveError(message: 'Failed to load leaves: $e'));
    }
  }

  Future<void> _onLoadByIdRequested(
    LeaveLoadByIdRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final leave = await _leaveService.getLeaveById(event.leaveId);
      if (leave != null) {
        emit(LeaveDetailLoaded(leave: leave));
      } else {
        emit(const LeaveError(message: 'Leave not found'));
      }
    } catch (e) {
      emit(LeaveError(message: 'Failed to load leave: $e'));
    }
  }

  Future<void> _onCreateRequested(
    LeaveCreateRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      await _leaveService.createLeave(event.leave);
      emit(const LeaveOperationSuccess(message: 'Leave request submitted successfully'));
      // Reload leaves
      add(LeaveLoadAllRequested(employeeId: event.leave.employeeId));
    } catch (e) {
      emit(LeaveError(message: 'Failed to create leave: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    LeaveUpdateRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      await _leaveService.updateLeave(event.leave);
      emit(const LeaveOperationSuccess(message: 'Leave updated successfully'));
      // Reload leaves
      add(LeaveLoadAllRequested(employeeId: event.leave.employeeId));
    } catch (e) {
      emit(LeaveError(message: 'Failed to update leave: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    LeaveDeleteRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      await _leaveService.deleteLeave(event.leaveId);
      emit(const LeaveOperationSuccess(message: 'Leave deleted successfully'));
      // Reload leaves
      add(const LeaveLoadAllRequested());
    } catch (e) {
      emit(LeaveError(message: 'Failed to delete leave: $e'));
    }
  }

  Future<void> _onApproveRequested(
    LeaveApproveRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      await _leaveService.approveLeave(
        leaveId: event.leaveId,
        approverId: event.approverId,
        comments: event.comments,
      );
      emit(const LeaveOperationSuccess(message: 'Leave approved successfully'));
      // Reload leaves
      add(const LeaveLoadAllRequested());
    } catch (e) {
      emit(LeaveError(message: 'Failed to approve leave: $e'));
    }
  }

  Future<void> _onRejectRequested(
    LeaveRejectRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      await _leaveService.rejectLeave(
        leaveId: event.leaveId,
        approverId: event.approverId,
        reason: event.reason,
      );
      emit(const LeaveOperationSuccess(message: 'Leave rejected'));
      // Reload leaves
      add(const LeaveLoadAllRequested());
    } catch (e) {
      emit(LeaveError(message: 'Failed to reject leave: $e'));
    }
  }

  Future<void> _onBalanceLoadRequested(
    LeaveBalanceLoadRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(LeaveLoading());
    try {
      final balance = await _leaveService.getLeaveBalance(event.employeeId);
      emit(LeaveBalanceLoaded(leaveBalance: balance));
    } catch (e) {
      emit(LeaveError(message: 'Failed to load leave balance: $e'));
    }
  }
}
