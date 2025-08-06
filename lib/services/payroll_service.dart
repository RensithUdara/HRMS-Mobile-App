import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payroll_model.dart';
import '../models/employee_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_model.dart';

class PayrollService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _payrollCollection = 'payrolls';
  static const String _employeeCollection = 'employees';
  static const String _attendanceCollection = 'attendance';
  static const String _leaveCollection = 'leaves';

  // Get all payrolls with optional filters
  Future<List<PayrollModel>> getAllPayrolls({
    String? employeeId,
    DateTime? month,
    int? year,
  }) async {
    try {
      Query query = _firestore.collection(_payrollCollection);

      // Apply filters
      if (employeeId != null) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      if (month != null) {
        // Filter by specific month
        final startOfMonth = DateTime(month.year, month.month, 1);
        final endOfMonth = DateTime(month.year, month.month + 1, 0);
        query = query
            .where('payPeriodStart', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
            .where('payPeriodStart', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));
      } else if (year != null) {
        // Filter by year
        final startOfYear = DateTime(year, 1, 1);
        final endOfYear = DateTime(year + 1, 1, 1);
        query = query
            .where('payPeriodStart', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
            .where('payPeriodStart', isLessThan: Timestamp.fromDate(endOfYear));
      }

      query = query.orderBy('payPeriodStart', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PayrollModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch payrolls: $e');
    }
  }

  // Get payroll by ID
  Future<PayrollModel?> getPayrollById(String payrollId) async {
    try {
      final doc = await _firestore
          .collection(_payrollCollection)
          .doc(payrollId)
          .get();

      if (doc.exists) {
        return PayrollModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch payroll: $e');
    }
  }

  // Calculate payroll for an employee for a specific month
  Future<PayrollModel> calculatePayroll({
    required String employeeId,
    required DateTime month,
  }) async {
    try {
      // Get employee details
      final employeeDoc = await _firestore
          .collection(_employeeCollection)
          .doc(employeeId)
          .get();

      if (!employeeDoc.exists) {
        throw Exception('Employee not found');
      }

      final employee = EmployeeModel.fromJson(employeeDoc.data()!);

      // Calculate pay period
      final payPeriodStart = DateTime(month.year, month.month, 1);
      final payPeriodEnd = DateTime(month.year, month.month + 1, 0);

      // Get attendance records for the month
      final attendanceQuery = await _firestore
          .collection(_attendanceCollection)
          .where('employeeId', isEqualTo: employeeId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(payPeriodStart))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(payPeriodEnd))
          .get();

      final attendanceRecords = attendanceQuery.docs
          .map((doc) => AttendanceModel.fromJson(doc.data()))
          .toList();

      // Get leave records for the month
      final leaveQuery = await _firestore
          .collection(_leaveCollection)
          .where('employeeId', isEqualTo: employeeId)
          .where('status', isEqualTo: 'approved')
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(payPeriodEnd))
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(payPeriodStart))
          .get();

      final leaveRecords = leaveQuery.docs
          .map((doc) => LeaveModel.fromJson(doc.data()))
          .toList();

      // Calculate working hours and overtime
      double totalWorkingHours = 0;
      double totalOvertimeHours = 0;
      int totalWorkingDays = 0;

      for (final attendance in attendanceRecords) {
        if (attendance.checkOutTime != null) {
          final workingHours = attendance.checkOutTime!.difference(attendance.checkInTime!).inMinutes / 60.0;
          totalWorkingHours += workingHours;
          totalWorkingDays++;

          // Calculate overtime (assuming 8 hours standard workday)
          if (workingHours > 8) {
            totalOvertimeHours += (workingHours - 8);
          }
        }
      }

      // Calculate leave days
      double totalLeaveDays = 0;
      for (final leave in leaveRecords) {
        final leaveDays = leave.endDate.difference(leave.startDate).inDays + 1;
        totalLeaveDays += leaveDays.toDouble();
      }

      // Calculate basic salary based on employee type
      double basicSalary = 0;
      if (employee.employmentType == 'Full-time') {
        basicSalary = employee.basicSalary;
      } else {
        // For part-time or hourly employees
        final hourlyRate = employee.basicSalary / (22 * 8); // Assuming 22 working days, 8 hours/day
        basicSalary = totalWorkingHours * hourlyRate;
      }

      // Calculate allowances
      double allowances = 0;
      // Add your allowance calculation logic here
      // For example: transport allowance, meal allowance, etc.

      // Calculate deductions
      double deductions = 0;
      
      // EPF (Employee Provident Fund) - 8% of basic salary
      final epf = basicSalary * 0.08;
      deductions += epf;

      // ETF (Employee Trust Fund) - 3% of basic salary
      final etf = basicSalary * 0.03;
      deductions += etf;

      // Tax calculation (simplified)
      double tax = 0;
      if (basicSalary > 100000) { // Monthly threshold for tax in LKR
        tax = (basicSalary - 100000) * 0.06; // 6% tax rate
      }
      deductions += tax;

      // Calculate overtime pay (1.5x hourly rate)
      final hourlyRate = basicSalary / (totalWorkingDays * 8);
      final overtimePay = totalOvertimeHours * hourlyRate * 1.5;

      // Calculate gross salary
      final grossSalary = basicSalary + allowances + overtimePay;

      // Calculate net salary
      final netSalary = grossSalary - deductions;

      // Create payroll record
      final payroll = PayrollModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeeId: employeeId,
        employeeName: employee.fullName,
        employeeNumber: employee.employeeId,
        department: employee.department.name,
        designation: employee.designation,
        year: month.year,
        month: month.month,
        payPeriod: '${_getMonthName(month.month)} ${month.year}',
        basicSalary: basicSalary,
        allowances: allowances,
        overtimePay: overtimePay,
        grossSalary: grossSalary,
        epfEmployeeContribution: epf,
        epfEmployerContribution: basicSalary * 0.12,
        etfContribution: etf,
        payeTax: tax,
        totalDeductions: deductions,
        netSalary: netSalary,
        takeHomePay: netSalary,
        workingDays: 22, // Standard working days per month
        actualWorkingDays: totalWorkingDays,
        totalWorkingHours: totalWorkingHours,
        overtimeHours: totalOvertimeHours,
        leaveDays: totalLeaveDays.toInt(),
        status: PayrollStatus.calculated,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return payroll;
    } catch (e) {
      throw Exception('Failed to calculate payroll: $e');
    }
  }

  // Generate/save payroll
  Future<void> generatePayroll(PayrollModel payroll) async {
    try {
      await _firestore
          .collection(_payrollCollection)
          .doc(payroll.id)
          .set(payroll.toJson());
    } catch (e) {
      throw Exception('Failed to generate payroll: $e');
    }
  }

  // Approve payroll
  Future<void> approvePayroll({
    required String payrollId,
    required String approverId,
  }) async {
    try {
      await _firestore
          .collection(_payrollCollection)
          .doc(payrollId)
          .update({
        'status': 'approved',
        'approvedBy': approverId,
        'approvedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to approve payroll: $e');
    }
  }

  // Process payroll (mark as paid)
  Future<void> processPayroll(String payrollId) async {
    try {
      await _firestore
          .collection(_payrollCollection)
          .doc(payrollId)
          .update({
        'status': 'processed',
        'processedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to process payroll: $e');
    }
  }

  // Get payroll summary for a period
  Future<Map<String, dynamic>> getPayrollSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_payrollCollection);

      if (startDate != null && endDate != null) {
        query = query
            .where('payPeriodStart', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('payPeriodEnd', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final payrolls = snapshot.docs
          .map((doc) => PayrollModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      double totalGrossSalary = 0;
      double totalNetSalary = 0;
      double totalDeductions = 0;
      double totalEPF = 0;
      double totalETF = 0;
      double totalTax = 0;

      for (final payroll in payrolls) {
        totalGrossSalary += payroll.grossSalary;
        totalNetSalary += payroll.netSalary;
        totalDeductions += payroll.totalDeductions;
        totalEPF += payroll.epfEmployeeContribution;
        totalETF += payroll.etfContribution;
        totalTax += payroll.payeTax;
      }

      return {
        'totalEmployees': payrolls.length,
        'totalGrossSalary': totalGrossSalary,
        'totalNetSalary': totalNetSalary,
        'totalDeductions': totalDeductions,
        'totalEPF': totalEPF,
        'totalETF': totalETF,
        'totalTax': totalTax,
        'payrolls': payrolls,
      };
    } catch (e) {
      throw Exception('Failed to get payroll summary: $e');
    }
  }

  // Get employee payroll history
  Future<List<PayrollModel>> getEmployeePayrollHistory(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(_payrollCollection)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('year', descending: true)
          .orderBy('month', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PayrollModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get employee payroll history: $e');
    }
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
