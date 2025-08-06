import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/employee_model.dart';
import '../services/employee_service.dart';

// Employee Events
abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class EmployeeLoadAllRequested extends EmployeeEvent {}

class EmployeeLoadByIdRequested extends EmployeeEvent {
  final String employeeId;

  const EmployeeLoadByIdRequested({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

class EmployeeCreateRequested extends EmployeeEvent {
  final EmployeeModel employee;

  const EmployeeCreateRequested({required this.employee});

  @override
  List<Object> get props => [employee];
}

class EmployeeUpdateRequested extends EmployeeEvent {
  final EmployeeModel employee;

  const EmployeeUpdateRequested({required this.employee});

  @override
  List<Object> get props => [employee];
}

class EmployeeDeleteRequested extends EmployeeEvent {
  final String employeeId;

  const EmployeeDeleteRequested({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

class EmployeeSearchRequested extends EmployeeEvent {
  final String query;

  const EmployeeSearchRequested({required this.query});

  @override
  List<Object> get props => [query];
}

class EmployeeFilterRequested extends EmployeeEvent {
  final String? department;
  final String? position;
  final bool? isActive;

  const EmployeeFilterRequested({
    this.department,
    this.position,
    this.isActive,
  });

  @override
  List<Object?> get props => [department, position, isActive];
}

// Employee States
abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List<EmployeeModel> employees;

  const EmployeeLoaded({required this.employees});

  @override
  List<Object> get props => [employees];
}

class EmployeeDetailLoaded extends EmployeeState {
  final EmployeeModel employee;

  const EmployeeDetailLoaded({required this.employee});

  @override
  List<Object> get props => [employee];
}

class EmployeeOperationSuccess extends EmployeeState {
  final String message;

  const EmployeeOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class EmployeeError extends EmployeeState {
  final String message;
  final String? code;

  const EmployeeError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Employee BLoC
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeService _employeeService;

  EmployeeBloc({
    required EmployeeService employeeService,
  })  : _employeeService = employeeService,
        super(EmployeeInitial()) {
    on<EmployeeLoadAllRequested>(_onLoadAllRequested);
    on<EmployeeLoadByIdRequested>(_onLoadByIdRequested);
    on<EmployeeCreateRequested>(_onCreateRequested);
    on<EmployeeUpdateRequested>(_onUpdateRequested);
    on<EmployeeDeleteRequested>(_onDeleteRequested);
    on<EmployeeSearchRequested>(_onSearchRequested);
    on<EmployeeFilterRequested>(_onFilterRequested);
  }

  Future<void> _onLoadAllRequested(
    EmployeeLoadAllRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      final employees = await _employeeService.getAllEmployees();
      emit(EmployeeLoaded(employees: employees));
    } catch (e) {
      emit(EmployeeError(message: 'Failed to load employees: $e'));
    }
  }

  Future<void> _onLoadByIdRequested(
    EmployeeLoadByIdRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      final employee = await _employeeService.getEmployeeById(event.employeeId);
      if (employee != null) {
        emit(EmployeeDetailLoaded(employee: employee));
      } else {
        emit(const EmployeeError(message: 'Employee not found'));
      }
    } catch (e) {
      emit(EmployeeError(message: 'Failed to load employee: $e'));
    }
  }

  Future<void> _onCreateRequested(
    EmployeeCreateRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      await _employeeService.createEmployee(event.employee);
      emit(const EmployeeOperationSuccess(message: 'Employee created successfully'));
      // Reload all employees
      add(EmployeeLoadAllRequested());
    } catch (e) {
      emit(EmployeeError(message: 'Failed to create employee: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    EmployeeUpdateRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      await _employeeService.updateEmployee(event.employee);
      emit(const EmployeeOperationSuccess(message: 'Employee updated successfully'));
      // Reload all employees
      add(EmployeeLoadAllRequested());
    } on AppException catch (e) {
      emit(EmployeeError(message: e.message, code: e.code));
    } catch (e) {
      emit(EmployeeError(message: 'Failed to update employee: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    EmployeeDeleteRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      await _employeeService.deleteEmployee(event.employeeId);
      emit(const EmployeeOperationSuccess(message: 'Employee deleted successfully'));
      // Reload all employees
      add(EmployeeLoadAllRequested());
    } on AppException catch (e) {
      emit(EmployeeError(message: e.message, code: e.code));
    } catch (e) {
      emit(EmployeeError(message: 'Failed to delete employee: $e'));
    }
  }

  Future<void> _onSearchRequested(
    EmployeeSearchRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      final employees = await _employeeService.searchEmployees(event.query);
      emit(EmployeeLoaded(employees: employees));
    } on AppException catch (e) {
      emit(EmployeeError(message: e.message, code: e.code));
    } catch (e) {
      emit(EmployeeError(message: 'Failed to search employees: $e'));
    }
  }

  Future<void> _onFilterRequested(
    EmployeeFilterRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      final employees = await _employeeService.filterEmployees(
        department: event.department,
        position: event.position,
        isActive: event.isActive,
      );
      emit(EmployeeLoaded(employees: employees));
    } on AppException catch (e) {
      emit(EmployeeError(message: e.message, code: e.code));
    } catch (e) {
      emit(EmployeeError(message: 'Failed to filter employees: $e'));
    }
  }
}
