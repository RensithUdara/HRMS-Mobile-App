import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_model.dart';
import '../models/payroll_model.dart';
import '../utils/exceptions.dart';

/// Firestore service for HR data management
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get employees => _firestore.collection('employees');
  CollectionReference get attendance => _firestore.collection('attendance');
  CollectionReference get leaves => _firestore.collection('leaves');
  CollectionReference get payroll => _firestore.collection('payroll');
  CollectionReference get companies => _firestore.collection('companies');
  CollectionReference get departments => _firestore.collection('departments');

  /// Employee Management

  /// Create employee
  Future<void> createEmployee(EmployeeModel employee) async {
    try {
      await employees.doc(employee.id).set(employee.toJson());
    } catch (e) {
      throw DatabaseException('Failed to create employee: $e');
    }
  }

  /// Get employee by ID
  Future<EmployeeModel?> getEmployee(String employeeId) async {
    try {
      final doc = await employees.doc(employeeId).get();
      if (doc.exists && doc.data() != null) {
        return EmployeeModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to fetch employee: $e');
    }
  }

  /// Update employee
  Future<void> updateEmployee(EmployeeModel employee) async {
    try {
      await employees.doc(employee.id).update(employee.toJson());
    } catch (e) {
      throw DatabaseException('Failed to update employee: $e');
    }
  }

  /// Delete employee
  Future<void> deleteEmployee(String employeeId) async {
    try {
      await employees.doc(employeeId).delete();
    } catch (e) {
      throw DatabaseException('Failed to delete employee: $e');
    }
  }

  /// Get all employees
  Stream<List<EmployeeModel>> getAllEmployees() {
    return employees
        .orderBy('firstName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmployeeModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get employees by department
  Stream<List<EmployeeModel>> getEmployeesByDepartment(Department department) {
    return employees
        .where('department', isEqualTo: department.toString().split('.').last)
        .orderBy('firstName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmployeeModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Search employees
  Stream<List<EmployeeModel>> searchEmployees(String query) {
    return employees
        .orderBy('firstName')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmployeeModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get employee count
  Future<int> getEmployeeCount() async {
    try {
      final snapshot = await employees.get();
      return snapshot.docs.length;
    } catch (e) {
      throw DatabaseException('Failed to get employee count: $e');
    }
  }

  /// Attendance Management

  /// Create attendance record
  Future<void> createAttendanceRecord(AttendanceModel attendanceRecord) async {
    try {
      await attendance.doc(attendanceRecord.id).set(attendanceRecord.toJson());
    } catch (e) {
      throw DatabaseException('Failed to create attendance record: $e');
    }
  }

  /// Get attendance record by ID
  Future<AttendanceModel?> getAttendanceRecord(String recordId) async {
    try {
      final doc = await attendance.doc(recordId).get();
      if (doc.exists && doc.data() != null) {
        return AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to fetch attendance record: $e');
    }
  }

  /// Update attendance record
  Future<void> updateAttendanceRecord(AttendanceModel attendanceRecord) async {
    try {
      await attendance.doc(attendanceRecord.id).update(attendanceRecord.toJson());
    } catch (e) {
      throw DatabaseException('Failed to update attendance record: $e');
    }
  }

  /// Get employee attendance for date range
  Stream<List<AttendanceModel>> getEmployeeAttendance(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return attendance
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get today's attendance for employee
  Future<AttendanceModel?> getTodayAttendance(String employeeId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await attendance
          .where('employeeId', isEqualTo: employeeId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return AttendanceModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to fetch today\'s attendance: $e');
    }
  }

  /// Get attendance summary for month
  Future<Map<String, dynamic>> getMonthlyAttendanceSummary(
    String employeeId,
    int year,
    int month,
  ) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final snapshot = await attendance
          .where('employeeId', isEqualTo: employeeId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      int presentDays = 0;
      int absentDays = 0;
      int lateDays = 0;
      int workFromHomeDays = 0;
      double totalWorkingHours = 0;
      double totalOvertimeHours = 0;

      for (final doc in snapshot.docs) {
        final record = AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
        
        switch (record.status) {
          case AttendanceStatus.present:
            presentDays++;
            break;
          case AttendanceStatus.absent:
            absentDays++;
            break;
          case AttendanceStatus.late:
            lateDays++;
            presentDays++;
            break;
          case AttendanceStatus.workFromHome:
            workFromHomeDays++;
            presentDays++;
            break;
          default:
            break;
        }

        totalWorkingHours += record.totalWorkingHours;
        totalOvertimeHours += record.overtimeHours;
      }

      return {
        'presentDays': presentDays,
        'absentDays': absentDays,
        'lateDays': lateDays,
        'workFromHomeDays': workFromHomeDays,
        'totalWorkingHours': totalWorkingHours,
        'totalOvertimeHours': totalOvertimeHours,
        'attendancePercentage': (presentDays / (presentDays + absentDays)) * 100,
      };
    } catch (e) {
      throw DatabaseException('Failed to get attendance summary: $e');
    }
  }

  /// Leave Management

  /// Create leave request
  Future<void> createLeaveRequest(LeaveModel leave) async {
    try {
      await leaves.doc(leave.id).set(leave.toJson());
    } catch (e) {
      throw DatabaseException('Failed to create leave request: $e');
    }
  }

  /// Get leave request by ID
  Future<LeaveModel?> getLeaveRequest(String leaveId) async {
    try {
      final doc = await leaves.doc(leaveId).get();
      if (doc.exists && doc.data() != null) {
        return LeaveModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to fetch leave request: $e');
    }
  }

  /// Update leave request
  Future<void> updateLeaveRequest(LeaveModel leave) async {
    try {
      await leaves.doc(leave.id).update(leave.toJson());
    } catch (e) {
      throw DatabaseException('Failed to update leave request: $e');
    }
  }

  /// Get employee leave requests
  Stream<List<LeaveModel>> getEmployeeLeaveRequests(String employeeId) {
    return leaves
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaveModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get pending leave requests for manager approval
  Stream<List<LeaveModel>> getPendingLeaveRequests(String managerId) {
    return leaves
        .where('status', isEqualTo: LeaveStatus.pending.toString().split('.').last)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaveModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get leave balance for employee
  Future<LeaveBalanceModel?> getLeaveBalance(String employeeId, int year) async {
    try {
      final doc = await _firestore
          .collection('leave_balances')
          .doc('${employeeId}_$year')
          .get();

      if (doc.exists && doc.data() != null) {
        return LeaveBalanceModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to fetch leave balance: $e');
    }
  }

  /// Update leave balance
  Future<void> updateLeaveBalance(LeaveBalanceModel balance) async {
    try {
      await _firestore
          .collection('leave_balances')
          .doc('${balance.employeeId}_${balance.year}')
          .set(balance.toJson());
    } catch (e) {
      throw DatabaseException('Failed to update leave balance: $e');
    }
  }

  /// Payroll Management

  /// Create payroll record
  Future<void> createPayrollRecord(PayrollModel payrollRecord) async {
    try {
      await payroll.doc(payrollRecord.id).set(payrollRecord.toJson());
    } catch (e) {
      throw DatabaseException('Failed to create payroll record: $e');
    }
  }

  /// Get payroll record by ID
  Future<PayrollModel?> getPayrollRecord(String recordId) async {
    try {
      final doc = await payroll.doc(recordId).get();
      if (doc.exists && doc.data() != null) {
        return PayrollModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to fetch payroll record: $e');
    }
  }

  /// Update payroll record
  Future<void> updatePayrollRecord(PayrollModel payrollRecord) async {
    try {
      await payroll.doc(payrollRecord.id).update(payrollRecord.toJson());
    } catch (e) {
      throw DatabaseException('Failed to update payroll record: $e');
    }
  }

  /// Get employee payroll records
  Stream<List<PayrollModel>> getEmployeePayrollRecords(String employeeId) {
    return payroll
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PayrollModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get payroll records for processing
  Stream<List<PayrollModel>> getPayrollRecordsForProcessing(int year, int month) {
    return payroll
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .orderBy('employeeName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PayrollModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Company & Department Management

  /// Get company settings
  Future<Map<String, dynamic>?> getCompanySettings(String companyId) async {
    try {
      final doc = await companies.doc(companyId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw DatabaseException('Failed to fetch company settings: $e');
    }
  }

  /// Update company settings
  Future<void> updateCompanySettings(String companyId, Map<String, dynamic> settings) async {
    try {
      await companies.doc(companyId).update(settings);
    } catch (e) {
      throw DatabaseException('Failed to update company settings: $e');
    }
  }

  /// Get all departments
  Stream<List<Map<String, dynamic>>> getAllDepartments() {
    return departments
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  /// Batch Operations

  /// Create multiple attendance records
  Future<void> createBatchAttendanceRecords(List<AttendanceModel> records) async {
    try {
      final batch = _firestore.batch();
      
      for (final record in records) {
        final docRef = attendance.doc(record.id);
        batch.set(docRef, record.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Failed to create batch attendance records: $e');
    }
  }

  /// Analytics and Reporting

  /// Get department attendance statistics
  Future<Map<String, dynamic>> getDepartmentAttendanceStats(
    Department department,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // This would require aggregation queries or Cloud Functions
      // For now, returning a placeholder
      return {
        'totalEmployees': 0,
        'avgAttendance': 0.0,
        'totalWorkingHours': 0.0,
        'totalOvertimeHours': 0.0,
      };
    } catch (e) {
      throw DatabaseException('Failed to get department stats: $e');
    }
  }

  /// Get company-wide statistics
  Future<Map<String, dynamic>> getCompanyStats() async {
    try {
      final employeeCount = await getEmployeeCount();
      
      return {
        'totalEmployees': employeeCount,
        'activeEmployees': employeeCount, // TODO: Filter by status
        'departments': Department.values.length,
      };
    } catch (e) {
      throw DatabaseException('Failed to get company stats: $e');
    }
  }

  /// Real-time Listeners

  /// Listen to employee changes
  Stream<EmployeeModel> listenToEmployee(String employeeId) {
    return employees
        .doc(employeeId)
        .snapshots()
        .map((doc) => EmployeeModel.fromJson(doc.data() as Map<String, dynamic>));
  }

  /// Listen to attendance changes for today
  Stream<List<AttendanceModel>> listenToTodayAttendance() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return attendance
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
