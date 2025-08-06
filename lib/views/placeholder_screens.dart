import 'package:flutter/material.dart';

// Create placeholder screens for all the missing ones
class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Employee List Screen')));
}

class EmployeeDetailScreen extends StatelessWidget {
  final String employeeId;
  const EmployeeDetailScreen({super.key, required this.employeeId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Employee Detail: $employeeId')));
}

class EmployeeFormScreen extends StatelessWidget {
  final String? employeeId;
  const EmployeeFormScreen({super.key, this.employeeId});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Employee Form Screen')));
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Attendance Screen')));
}

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Check In Screen')));
}

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Attendance History Screen')));
}

class AttendanceReportScreen extends StatelessWidget {
  const AttendanceReportScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Attendance Report Screen')));
}

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Leave Screen')));
}

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Leave Request Screen')));
}

class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Leave History Screen')));
}

class LeaveApprovalScreen extends StatelessWidget {
  const LeaveApprovalScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Leave Approval Screen')));
}

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Payroll Screen')));
}

class PayrollDetailScreen extends StatelessWidget {
  final String payrollId;
  const PayrollDetailScreen({super.key, required this.payrollId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Payroll Detail: $payrollId')));
}

class PayslipScreen extends StatelessWidget {
  final String payslipId;
  const PayslipScreen({super.key, required this.payslipId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Payslip: $payslipId')));
}

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Performance Screen')));
}

class PerformanceReviewScreen extends StatelessWidget {
  final String reviewId;
  const PerformanceReviewScreen({super.key, required this.reviewId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Performance Review: $reviewId')));
}

class GoalSettingScreen extends StatelessWidget {
  const GoalSettingScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Goal Setting Screen')));
}

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Training Screen')));
}

class TrainingDetailScreen extends StatelessWidget {
  final String trainingId;
  const TrainingDetailScreen({super.key, required this.trainingId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Training Detail: $trainingId')));
}

class TrainingEnrollmentScreen extends StatelessWidget {
  final String trainingId;
  const TrainingEnrollmentScreen({super.key, required this.trainingId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Training Enrollment: $trainingId')));
}

class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Communication Screen')));
}

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Announcement Screen')));
}

class ChatScreen extends StatelessWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Chat: $chatId')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings Screen')));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Profile Screen')));
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Notification Settings Screen')));
}

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Security Settings Screen')));
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Admin Dashboard Screen')));
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('User Management Screen')));
}

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Company Settings Screen')));
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Reports Screen')));
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Page Not Found')));
}

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Unauthorized Access')));
}
