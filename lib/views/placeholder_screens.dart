import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';

// Create placeholder screens for all the missing ones
class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Employees', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
    ),
    body: const Center(child: Text('Employee List Screen')),
  );
}

class EmployeeDetailScreen extends StatelessWidget {
  final String employeeId;
  const EmployeeDetailScreen({super.key, required this.employeeId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Employee Details', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: Center(child: Text('Employee Detail: $employeeId')),
  );
}

class EmployeeFormScreen extends StatelessWidget {
  final String? employeeId;
  const EmployeeFormScreen({super.key, this.employeeId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        employeeId == null ? 'Add Employee' : 'Edit Employee',
        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Employee Form Screen')),
  );
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Attendance', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
    ),
    body: const Center(child: Text('Attendance Screen')),
  );
}

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Check In', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Check In Screen')),
  );
}

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Attendance History', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Attendance History Screen')),
  );
}

class AttendanceReportScreen extends StatelessWidget {
  const AttendanceReportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Attendance Report', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Attendance Report Screen')),
  );
}

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Leave Management', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
    ),
    body: const Center(child: Text('Leave Screen')),
  );
}

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Leave Request', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Leave Request Screen')),
  );
}

class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Leave History', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Leave History Screen')),
  );
}

class LeaveApprovalScreen extends StatelessWidget {
  const LeaveApprovalScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Leave Approval', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Leave Approval Screen')),
  );
}

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Payroll', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
    ),
    body: const Center(child: Text('Payroll Screen')),
  );
}

class PayrollDetailScreen extends StatelessWidget {
  final String payrollId;
  const PayrollDetailScreen({super.key, required this.payrollId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Payroll Details', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: Center(child: Text('Payroll Detail: $payrollId')),
  );
}

class PayslipScreen extends StatelessWidget {
  final String payslipId;
  const PayslipScreen({super.key, required this.payslipId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Payslip', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: Center(child: Text('Payslip: $payslipId')),
  );
}

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Performance', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
    ),
    body: const Center(child: Text('Performance Screen')),
  );
}

class PerformanceReviewScreen extends StatelessWidget {
  final String reviewId;
  const PerformanceReviewScreen({super.key, required this.reviewId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Performance Review', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: Center(child: Text('Performance Review: $reviewId')),
  );
}

class GoalSettingScreen extends StatelessWidget {
  const GoalSettingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Goal Setting', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Goal Setting Screen')),
  );
}

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Training', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
    ),
    body: const Center(child: Text('Training Screen')),
  );
}

class TrainingDetailScreen extends StatelessWidget {
  final String trainingId;
  const TrainingDetailScreen({super.key, required this.trainingId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Training Details', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: Center(child: Text('Training Detail: $trainingId')),
  );
}

class TrainingEnrollmentScreen extends StatelessWidget {
  final String trainingId;
  const TrainingEnrollmentScreen({super.key, required this.trainingId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Training Enrollment', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: Center(child: Text('Training Enrollment: $trainingId')),
  );
}

class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Communication', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
    ),
    body: const Center(child: Text('Communication Screen')),
  );
}

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Announcements', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Announcement Screen')),
  );
}

class ChatScreen extends StatelessWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Chat', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: Center(child: Text('Chat: $chatId')),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Settings', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
    ),
    body: const Center(child: Text('Settings Screen')),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Profile', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Profile Screen')),
  );
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notification Settings', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Notification Settings Screen')),
  );
}

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Security Settings', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Security Settings Screen')),
  );
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Admin Dashboard', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryColor),
    ),
    body: const Center(child: Text('Admin Dashboard Screen')),
  );
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('User Management', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('User Management Screen')),
  );
}

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Company Settings', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Company Settings Screen')),
  );
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Reports', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.pop(),
      ),
    ),
    body: const Center(child: Text('Reports Screen')),
  );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Page Not Found', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.go('/dashboard'),
      ),
    ),
    body: const Center(child: Text('Page Not Found')),
  );
}

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Unauthorized Access', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => context.go('/dashboard'),
      ),
    ),
    body: const Center(child: Text('Unauthorized Access')),
  );
}
