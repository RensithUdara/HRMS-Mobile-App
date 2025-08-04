import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/exceptions.dart';

/// Notification service for Firebase Cloud Messaging and local notifications
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Notification channels for Android
  static const String _generalChannelId = 'general_notifications';
  static const String _hrChannelId = 'hr_notifications';
  static const String _attendanceChannelId = 'attendance_notifications';
  static const String _leaveChannelId = 'leave_notifications';
  static const String _payrollChannelId = 'payroll_notifications';

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      throw Exception('Failed to initialize notification service: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      throw const PermissionException('Notification permission denied');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        _generalChannelId,
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        _hrChannelId,
        'HR Notifications',
        description: 'HR-related notifications',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        _attendanceChannelId,
        'Attendance Notifications',
        description: 'Attendance-related notifications',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        _leaveChannelId,
        'Leave Notifications',
        description: 'Leave-related notifications',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        _payrollChannelId,
        'Payroll Notifications',
        description: 'Payroll-related notifications',
        importance: Importance.high,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      throw Exception('Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw Exception('Failed to unsubscribe from topic: $e');
    }
  }

  /// Save FCM token to Firestore
  Future<void> saveTokenToFirestore(String userId) async {
    try {
      final token = await getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw DatabaseException('Failed to save FCM token: $e');
    }
  }

  /// Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'imageUrl': imageUrl,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException('Failed to send notification: $e');
    }
  }

  /// Send notification to multiple users
  Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final docRef = _firestore.collection('notifications').doc();
        batch.set(docRef, {
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
          'imageUrl': imageUrl,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Failed to send notifications: $e');
    }
  }

  /// Send notification to topic subscribers
  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      await _firestore.collection('topic_notifications').add({
        'topic': topic,
        'title': title,
        'body': body,
        'data': data ?? {},
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException('Failed to send topic notification: $e');
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = _generalChannelId,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _generalChannelId,
        'General Notifications',
        channelDescription: 'General app notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      throw Exception('Failed to show local notification: $e');
    }
  }

  /// Schedule local notification
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = _generalChannelId,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _generalChannelId,
        'General Notifications',
        channelDescription: 'General app notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Note: For scheduling, you might need to use a different package
      // like flutter_local_notifications with timezone support
      await _localNotifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      throw Exception('Failed to schedule local notification: $e');
    }
  }

  /// Get user notifications
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException('Failed to mark notification as read: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      throw DatabaseException('Failed to get unread notification count: $e');
    }
  }

  /// HR-specific notification methods

  /// Send leave request notification
  Future<void> sendLeaveRequestNotification({
    required String managerId,
    required String employeeName,
    required String leaveType,
    required String startDate,
    required String endDate,
  }) async {
    await sendNotificationToUser(
      userId: managerId,
      title: 'New Leave Request',
      body: '$employeeName has requested $leaveType from $startDate to $endDate',
      data: {
        'type': 'leave_request',
        'action': 'approve_reject',
      },
    );
  }

  /// Send leave approval notification
  Future<void> sendLeaveApprovalNotification({
    required String employeeId,
    required String leaveType,
    required bool isApproved,
    String? managerName,
  }) async {
    final status = isApproved ? 'approved' : 'rejected';
    await sendNotificationToUser(
      userId: employeeId,
      title: 'Leave Request $status',
      body: 'Your $leaveType request has been $status${managerName != null ? ' by $managerName' : ''}',
      data: {
        'type': 'leave_response',
        'status': status,
      },
    );
  }

  /// Send attendance reminder
  Future<void> sendAttendanceReminder(String employeeId) async {
    await sendNotificationToUser(
      userId: employeeId,
      title: 'Attendance Reminder',
      body: 'Don\'t forget to mark your attendance for today',
      data: {
        'type': 'attendance_reminder',
        'action': 'mark_attendance',
      },
    );
  }

  /// Send payslip notification
  Future<void> sendPayslipNotification({
    required String employeeId,
    required String month,
    required int year,
  }) async {
    await sendNotificationToUser(
      userId: employeeId,
      title: 'Payslip Available',
      body: 'Your payslip for $month $year is now available',
      data: {
        'type': 'payslip_available',
        'month': month,
        'year': year.toString(),
      },
    );
  }

  /// Send birthday notification
  Future<void> sendBirthdayNotification({
    required List<String> userIds,
    required String employeeName,
  }) async {
    await sendNotificationToUsers(
      userIds: userIds,
      title: 'Birthday Today! 🎉',
      body: 'Wish $employeeName a happy birthday!',
      data: {
        'type': 'birthday',
        'celebration': 'true',
      },
    );
  }

  /// Send company announcement
  Future<void> sendCompanyAnnouncement({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    await sendNotificationToTopic(
      topic: 'company_announcements',
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: {
        'type': 'company_announcement',
      },
    );
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Handling a foreground message: ${message.messageId}');
    
    // Show local notification when app is in foreground
    showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? 'You have a new notification',
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Navigate to appropriate screen based on notification data
    // This would be handled by your app's navigation logic
  }

  /// Handle local notification tap
  void _onLocalNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Handle local notification tap
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Handle background message
}
