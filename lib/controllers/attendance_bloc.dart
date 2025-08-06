import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

// Attendance Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceCheckInRequested extends AttendanceEvent {
  final String employeeId;
  final double? latitude;
  final double? longitude;
  final String? notes;

  const AttendanceCheckInRequested({
    required this.employeeId,
    this.latitude,
    this.longitude,
    this.notes,
  });

  @override
  List<Object?> get props => [employeeId, latitude, longitude, notes];
}

class AttendanceCheckOutRequested extends AttendanceEvent {
  final String attendanceId;
  final String? notes;

  const AttendanceCheckOutRequested({
    required this.attendanceId,
    this.notes,
  });

  @override
  List<Object?> get props => [attendanceId, notes];
}

class AttendanceLoadTodayRequested extends AttendanceEvent {
  final String employeeId;

  const AttendanceLoadTodayRequested({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

class AttendanceLoadHistoryRequested extends AttendanceEvent {
  final String employeeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const AttendanceLoadHistoryRequested({
    required this.employeeId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [employeeId, startDate, endDate];
}

class AttendanceLoadAllRequested extends AttendanceEvent {
  final DateTime? date;

  const AttendanceLoadAllRequested({this.date});

  @override
  List<Object?> get props => [date];
}

class AttendanceBreakStartRequested extends AttendanceEvent {
  final String attendanceId;
  final String breakType;

  const AttendanceBreakStartRequested({
    required this.attendanceId,
    required this.breakType,
  });

  @override
  List<Object> get props => [attendanceId, breakType];
}

class AttendanceBreakEndRequested extends AttendanceEvent {
  final String attendanceId;
  final String breakId;

  const AttendanceBreakEndRequested({
    required this.attendanceId,
    required this.breakId,
  });

  @override
  List<Object> get props => [attendanceId, breakId];
}

// Attendance States
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceCheckInSuccess extends AttendanceState {
  final AttendanceModel attendance;

  const AttendanceCheckInSuccess({required this.attendance});

  @override
  List<Object> get props => [attendance];
}

class AttendanceCheckOutSuccess extends AttendanceState {
  final AttendanceModel attendance;

  const AttendanceCheckOutSuccess({required this.attendance});

  @override
  List<Object> get props => [attendance];
}

class AttendanceTodayLoaded extends AttendanceState {
  final AttendanceModel? attendance;

  const AttendanceTodayLoaded({this.attendance});

  @override
  List<Object?> get props => [attendance];
}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<AttendanceModel> attendanceList;

  const AttendanceHistoryLoaded({required this.attendanceList});

  @override
  List<Object> get props => [attendanceList];
}

class AttendanceAllLoaded extends AttendanceState {
  final List<AttendanceModel> attendanceList;

  const AttendanceAllLoaded({required this.attendanceList});

  @override
  List<Object> get props => [attendanceList];
}

class AttendanceBreakStarted extends AttendanceState {
  final AttendanceModel attendance;

  const AttendanceBreakStarted({required this.attendance});

  @override
  List<Object> get props => [attendance];
}

class AttendanceBreakEnded extends AttendanceState {
  final AttendanceModel attendance;

  const AttendanceBreakEnded({required this.attendance});

  @override
  List<Object> get props => [attendance];
}

class AttendanceError extends AttendanceState {
  final String message;
  final String? code;

  const AttendanceError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Attendance BLoC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceService _attendanceService;

  AttendanceBloc({
    required AttendanceService attendanceService,
  })  : _attendanceService = attendanceService,
        super(AttendanceInitial()) {
    on<AttendanceCheckInRequested>(_onCheckInRequested);
    on<AttendanceCheckOutRequested>(_onCheckOutRequested);
    on<AttendanceLoadTodayRequested>(_onLoadTodayRequested);
    on<AttendanceLoadHistoryRequested>(_onLoadHistoryRequested);
    on<AttendanceLoadAllRequested>(_onLoadAllRequested);
    on<AttendanceBreakStartRequested>(_onBreakStartRequested);
    on<AttendanceBreakEndRequested>(_onBreakEndRequested);
  }

  Future<void> _onCheckInRequested(
    AttendanceCheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendance = await _attendanceService.checkIn(
        employeeId: event.employeeId,
        employeeName: '', // Will be retrieved from user context
        method: event.latitude != null ? AttendanceMethod.gps : AttendanceMethod.manual,
      );
      emit(AttendanceCheckInSuccess(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to check in: $e'));
    }
  }

  Future<void> _onCheckOutRequested(
    AttendanceCheckOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendance = await _attendanceService.checkOut(
        employeeId: event.attendanceId, // This should be employeeId, not attendanceId
      );
      emit(AttendanceCheckOutSuccess(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to check out: $e'));
    }
  }

  Future<void> _onLoadTodayRequested(
    AttendanceLoadTodayRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendance = await _attendanceService.getTodayAttendance(event.employeeId);
      emit(AttendanceTodayLoaded(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to load today\'s attendance: $e'));
    }
  }

  Future<void> _onLoadHistoryRequested(
    AttendanceLoadHistoryRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final startDate = event.startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final endDate = event.endDate ?? DateTime.now();
      
      final attendanceStream = _attendanceService.getEmployeeAttendance(
        employeeId: event.employeeId,
        startDate: startDate,
        endDate: endDate,
      );
      final attendanceList = await attendanceStream.first;
      emit(AttendanceHistoryLoaded(attendanceList: attendanceList));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to load attendance history: $e'));
    }
  }

  Future<void> _onLoadAllRequested(
    AttendanceLoadAllRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final today = event.date ?? DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day);
      final endDate = startDate.add(const Duration(days: 1));
      
      // For all attendance, we'll get all employees for today
      final attendanceStream = _attendanceService.getEmployeeAttendance(
        employeeId: '', // This might need to be handled differently
        startDate: startDate,
        endDate: endDate,
      );
      final attendanceList = await attendanceStream.first;
      emit(AttendanceAllLoaded(attendanceList: attendanceList));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to load all attendance: $e'));
    }
  }

  Future<void> _onBreakStartRequested(
    AttendanceBreakStartRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendance = await _attendanceService.startBreak(
        employeeId: event.attendanceId, // This should be employeeId
        reason: event.breakType,
      );
      emit(AttendanceBreakStarted(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to start break: $e'));
    }
  }

  Future<void> _onBreakEndRequested(
    AttendanceBreakEndRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendance = await _attendanceService.endBreak(
        employeeId: event.attendanceId, // This should be employeeId
      );
      emit(AttendanceBreakEnded(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(message: 'Failed to end break: $e'));
    }
  }
}
