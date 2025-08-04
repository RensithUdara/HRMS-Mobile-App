import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Controllers
import '../controllers/auth_bloc.dart';

// Views
import '../views/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/phone_verification_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/auth/profile_setup_screen.dart';

// Main App Views
import '../views/main/main_screen.dart';
import '../views/dashboard/dashboard_screen.dart';

// Employee Views
import '../views/employee/employee_list_screen.dart';
import '../views/employee/employee_detail_screen.dart';
import '../views/employee/employee_form_screen.dart';

// Attendance Views
import '../views/attendance/attendance_screen.dart';
import '../views/attendance/check_in_screen.dart';
import '../views/attendance/attendance_history_screen.dart';
import '../views/attendance/attendance_report_screen.dart';

// Leave Views
import '../views/leave/leave_screen.dart';
import '../views/leave/leave_request_screen.dart';
import '../views/leave/leave_history_screen.dart';
import '../views/leave/leave_approval_screen.dart';

// Payroll Views
import '../views/payroll/payroll_screen.dart';
import '../views/payroll/payroll_detail_screen.dart';
import '../views/payroll/payslip_screen.dart';

// Performance Views
import '../views/performance/performance_screen.dart';
import '../views/performance/performance_review_screen.dart';
import '../views/performance/goal_setting_screen.dart';

// Training Views
import '../views/training/training_screen.dart';
import '../views/training/training_detail_screen.dart';
import '../views/training/training_enrollment_screen.dart';

// Communication Views
import '../views/communication/communication_screen.dart';
import '../views/communication/announcement_screen.dart';
import '../views/communication/chat_screen.dart';

// Settings Views
import '../views/settings/settings_screen.dart';
import '../views/settings/profile_screen.dart';
import '../views/settings/notification_settings_screen.dart';
import '../views/settings/security_settings_screen.dart';

// Admin Views
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/user_management_screen.dart';
import '../views/admin/company_settings_screen.dart';
import '../views/admin/reports_screen.dart';

// Error Views
import '../views/error/not_found_screen.dart';
import '../views/error/unauthorized_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: _redirect,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/phone-verification',
        name: 'phone-verification',
        builder: (context, state) {
          final phone = state.extra as String?;
          return PhoneVerificationScreen(phoneNumber: phone ?? '');
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main App Routes
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Employee Management
          GoRoute(
            path: '/employees',
            name: 'employees',
            builder: (context, state) => const EmployeeListScreen(),
            routes: [
              GoRoute(
                path: '/detail/:id',
                name: 'employee-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return EmployeeDetailScreen(employeeId: id);
                },
              ),
              GoRoute(
                path: '/add',
                name: 'employee-add',
                builder: (context, state) => const EmployeeFormScreen(),
              ),
              GoRoute(
                path: '/edit/:id',
                name: 'employee-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return EmployeeFormScreen(employeeId: id);
                },
              ),
            ],
          ),

          // Attendance
          GoRoute(
            path: '/attendance',
            name: 'attendance',
            builder: (context, state) => const AttendanceScreen(),
            routes: [
              GoRoute(
                path: '/check-in',
                name: 'check-in',
                builder: (context, state) => const CheckInScreen(),
              ),
              GoRoute(
                path: '/history',
                name: 'attendance-history',
                builder: (context, state) => const AttendanceHistoryScreen(),
              ),
              GoRoute(
                path: '/report',
                name: 'attendance-report',
                builder: (context, state) => const AttendanceReportScreen(),
              ),
            ],
          ),

          // Leave Management
          GoRoute(
            path: '/leave',
            name: 'leave',
            builder: (context, state) => const LeaveScreen(),
            routes: [
              GoRoute(
                path: '/request',
                name: 'leave-request',
                builder: (context, state) => const LeaveRequestScreen(),
              ),
              GoRoute(
                path: '/history',
                name: 'leave-history',
                builder: (context, state) => const LeaveHistoryScreen(),
              ),
              GoRoute(
                path: '/approval',
                name: 'leave-approval',
                builder: (context, state) => const LeaveApprovalScreen(),
              ),
            ],
          ),

          // Payroll
          GoRoute(
            path: '/payroll',
            name: 'payroll',
            builder: (context, state) => const PayrollScreen(),
            routes: [
              GoRoute(
                path: '/detail/:id',
                name: 'payroll-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PayrollDetailScreen(payrollId: id);
                },
              ),
              GoRoute(
                path: '/payslip/:id',
                name: 'payslip',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PayslipScreen(payslipId: id);
                },
              ),
            ],
          ),

          // Performance
          GoRoute(
            path: '/performance',
            name: 'performance',
            builder: (context, state) => const PerformanceScreen(),
            routes: [
              GoRoute(
                path: '/review/:id',
                name: 'performance-review',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PerformanceReviewScreen(reviewId: id);
                },
              ),
              GoRoute(
                path: '/goals',
                name: 'goal-setting',
                builder: (context, state) => const GoalSettingScreen(),
              ),
            ],
          ),

          // Training
          GoRoute(
            path: '/training',
            name: 'training',
            builder: (context, state) => const TrainingScreen(),
            routes: [
              GoRoute(
                path: '/detail/:id',
                name: 'training-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TrainingDetailScreen(trainingId: id);
                },
              ),
              GoRoute(
                path: '/enroll/:id',
                name: 'training-enrollment',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TrainingEnrollmentScreen(trainingId: id);
                },
              ),
            ],
          ),

          // Communication
          GoRoute(
            path: '/communication',
            name: 'communication',
            builder: (context, state) => const CommunicationScreen(),
            routes: [
              GoRoute(
                path: '/announcements',
                name: 'announcements',
                builder: (context, state) => const AnnouncementScreen(),
              ),
              GoRoute(
                path: '/chat/:id',
                name: 'chat',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ChatScreen(chatId: id);
                },
              ),
            ],
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/notifications',
                name: 'notification-settings',
                builder: (context, state) => const NotificationSettingsScreen(),
              ),
              GoRoute(
                path: '/security',
                name: 'security-settings',
                builder: (context, state) => const SecuritySettingsScreen(),
              ),
            ],
          ),

          // Admin Routes (role-based access)
          GoRoute(
            path: '/admin',
            name: 'admin',
            builder: (context, state) => const AdminDashboardScreen(),
            redirect: (context, state) => _adminRedirect(context, state),
            routes: [
              GoRoute(
                path: '/users',
                name: 'user-management',
                builder: (context, state) => const UserManagementScreen(),
              ),
              GoRoute(
                path: '/company',
                name: 'company-settings',
                builder: (context, state) => const CompanySettingsScreen(),
              ),
              GoRoute(
                path: '/reports',
                name: 'reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Error Routes
      GoRoute(
        path: '/unauthorized',
        name: 'unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      GoRoute(
        path: '/not-found',
        name: 'not-found',
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );

  // Global redirect logic
  static String? _redirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    final currentLocation = state.location;

    // Define public routes that don't require authentication
    final publicRoutes = [
      '/splash',
      '/login',
      '/register',
      '/phone-verification',
      '/forgot-password',
      '/unauthorized',
      '/not-found',
    ];

    // Check if current route is public
    final isPublicRoute = publicRoutes.any((route) => currentLocation.startsWith(route));

    // Handle authentication states
    if (authState is AuthUnauthenticated) {
      // If user is not authenticated and not on a public route, redirect to login
      if (!isPublicRoute) {
        return '/login';
      }
    } else if (authState is AuthAuthenticated) {
      // If user is authenticated but on auth routes, redirect to dashboard
      if (currentLocation.startsWith('/login') || 
          currentLocation.startsWith('/register') ||
          currentLocation.startsWith('/splash')) {
        return '/dashboard';
      }
      
      // Check if profile setup is required
      if (!authState.user.isProfileComplete && currentLocation != '/profile-setup') {
        return '/profile-setup';
      }
    } else if (authState is AuthLoading) {
      // Show splash screen while loading
      if (currentLocation != '/splash') {
        return '/splash';
      }
    }

    return null; // No redirect needed
  }

  // Admin route protection
  static String? _adminRedirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is AuthAuthenticated) {
      final user = authState.user;
      // Check if user has admin or manager role
      if (user.role != 'admin' && user.role != 'manager') {
        return '/unauthorized';
      }
    } else {
      return '/login';
    }

    return null;
  }

  // Helper methods for navigation
  static void goToLogin(BuildContext context) {
    context.go('/login');
  }

  static void goToDashboard(BuildContext context) {
    context.go('/dashboard');
  }

  static void goToProfile(BuildContext context) {
    context.go('/settings/profile');
  }

  static void goToEmployeeDetail(BuildContext context, String employeeId) {
    context.go('/employees/detail/$employeeId');
  }

  static void goToAttendanceCheckIn(BuildContext context) {
    context.go('/attendance/check-in');
  }

  static void goToLeaveRequest(BuildContext context) {
    context.go('/leave/request');
  }

  static void goToPayrollDetail(BuildContext context, String payrollId) {
    context.go('/payroll/detail/$payrollId');
  }

  static void goToTrainingDetail(BuildContext context, String trainingId) {
    context.go('/training/detail/$trainingId');
  }

  static void goToChat(BuildContext context, String chatId) {
    context.go('/communication/chat/$chatId');
  }

  static void goToAdminDashboard(BuildContext context) {
    context.go('/admin');
  }

  // Back navigation
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  // Replace current route
  static void replace(BuildContext context, String location) {
    context.pushReplacement(location);
  }

  // Push new route
  static void push(BuildContext context, String location) {
    context.push(location);
  }
}
