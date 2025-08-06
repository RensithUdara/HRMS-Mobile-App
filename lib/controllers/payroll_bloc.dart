import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/payroll_model.dart';
import '../services/payroll_service.dart';

// Payroll Events
abstract class PayrollEvent extends Equatable {
  const PayrollEvent();

  @override
  List<Object?> get props => [];
}

class PayrollLoadAllRequested extends PayrollEvent {
  final String? employeeId;
  final DateTime? month;
  final int? year;

  const PayrollLoadAllRequested({this.employeeId, this.month, this.year});

  @override
  List<Object?> get props => [employeeId, month, year];
}

class PayrollLoadByIdRequested extends PayrollEvent {
  final String payrollId;

  const PayrollLoadByIdRequested({required this.payrollId});

  @override
  List<Object> get props => [payrollId];
}

class PayrollCalculateRequested extends PayrollEvent {
  final String employeeId;
  final DateTime month;

  const PayrollCalculateRequested({
    required this.employeeId,
    required this.month,
  });

  @override
  List<Object> get props => [employeeId, month];
}

class PayrollGenerateRequested extends PayrollEvent {
  final PayrollModel payroll;

  const PayrollGenerateRequested({required this.payroll});

  @override
  List<Object> get props => [payroll];
}

class PayrollApproveRequested extends PayrollEvent {
  final String payrollId;
  final String approverId;

  const PayrollApproveRequested({
    required this.payrollId,
    required this.approverId,
  });

  @override
  List<Object> get props => [payrollId, approverId];
}

class PayrollProcessRequested extends PayrollEvent {
  final String payrollId;

  const PayrollProcessRequested({required this.payrollId});

  @override
  List<Object> get props => [payrollId];
}

// Payroll States
abstract class PayrollState extends Equatable {
  const PayrollState();

  @override
  List<Object?> get props => [];
}

class PayrollInitial extends PayrollState {}

class PayrollLoading extends PayrollState {}

class PayrollLoaded extends PayrollState {
  final List<PayrollModel> payrolls;

  const PayrollLoaded({required this.payrolls});

  @override
  List<Object> get props => [payrolls];
}

class PayrollDetailLoaded extends PayrollState {
  final PayrollModel payroll;

  const PayrollDetailLoaded({required this.payroll});

  @override
  List<Object> get props => [payroll];
}

class PayrollCalculated extends PayrollState {
  final PayrollModel payroll;

  const PayrollCalculated({required this.payroll});

  @override
  List<Object> get props => [payroll];
}

class PayrollOperationSuccess extends PayrollState {
  final String message;

  const PayrollOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class PayrollError extends PayrollState {
  final String message;
  final String? code;

  const PayrollError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Payroll BLoC
class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  final PayrollService _payrollService;

  PayrollBloc({
    required PayrollService payrollService,
  })  : _payrollService = payrollService,
        super(PayrollInitial()) {
    on<PayrollLoadAllRequested>(_onLoadAllRequested);
    on<PayrollLoadByIdRequested>(_onLoadByIdRequested);
    on<PayrollCalculateRequested>(_onCalculateRequested);
    on<PayrollGenerateRequested>(_onGenerateRequested);
    on<PayrollApproveRequested>(_onApproveRequested);
    on<PayrollProcessRequested>(_onProcessRequested);
  }

  Future<void> _onLoadAllRequested(
    PayrollLoadAllRequested event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    try {
      final payrolls = await _payrollService.getAllPayrolls(
        employeeId: event.employeeId,
        month: event.month,
        year: event.year,
      );
      emit(PayrollLoaded(payrolls: payrolls));
    } catch (e) {
      emit(PayrollError(message: 'Failed to load payrolls: $e'));
    }
  }

  Future<void> _onLoadByIdRequested(
    PayrollLoadByIdRequested event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    try {
      final payroll = await _payrollService.getPayrollById(event.payrollId);
      if (payroll != null) {
        emit(PayrollDetailLoaded(payroll: payroll));
      } else {
        emit(const PayrollError(message: 'Payroll not found'));
      }
    } catch (e) {
      emit(PayrollError(message: 'Failed to load payroll: $e'));
    }
  }

  Future<void> _onCalculateRequested(
    PayrollCalculateRequested event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    try {
      final payroll = await _payrollService.calculatePayroll(
        employeeId: event.employeeId,
        month: event.month,
      );
      emit(PayrollCalculated(payroll: payroll));
    } catch (e) {
      emit(PayrollError(message: 'Failed to calculate payroll: $e'));
    }
  }

  Future<void> _onGenerateRequested(
    PayrollGenerateRequested event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    try {
      await _payrollService.generatePayroll(event.payroll);
      emit(const PayrollOperationSuccess(message: 'Payroll generated successfully'));
      // Reload payrolls
      add(PayrollLoadAllRequested(employeeId: event.payroll.employeeId));
    } catch (e) {
      emit(PayrollError(message: 'Failed to generate payroll: $e'));
    }
  }

  Future<void> _onApproveRequested(
    PayrollApproveRequested event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    try {
      await _payrollService.approvePayroll(
        payrollId: event.payrollId,
        approverId: event.approverId,
      );
      emit(const PayrollOperationSuccess(message: 'Payroll approved successfully'));
      // Reload payrolls
      add(const PayrollLoadAllRequested());
    } catch (e) {
      emit(PayrollError(message: 'Failed to approve payroll: $e'));
    }
  }

  Future<void> _onProcessRequested(
    PayrollProcessRequested event,
    Emitter<PayrollState> emit,
  ) async {
    emit(PayrollLoading());
    try {
      await _payrollService.processPayroll(event.payrollId);
      emit(const PayrollOperationSuccess(message: 'Payroll processed successfully'));
      // Reload payrolls
      add(const PayrollLoadAllRequested());
    } catch (e) {
      emit(PayrollError(message: 'Failed to process payroll: $e'));
    }
  }
}
