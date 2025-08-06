import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/communication_model.dart';

class CommunicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _communicationsCollection = 'communications';
  static const String _announcementsCollection = 'announcements';
  static const String _notificationsCollection = 'notifications';

  // Get all communications with optional filters
  Future<List<CommunicationModel>> getAllCommunications({
    String? employeeId,
    String? type,
    String? status,
  }) async {
    try {
      Query query = _firestore.collection(_communicationsCollection);

      // Apply filters
      if (employeeId != null) {
        query = query.where('recipients', arrayContains: employeeId);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CommunicationModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch communications: $e');
    }
  }

  // Get communication by ID
  Future<CommunicationModel?> getCommunicationById(String communicationId) async {
    try {
      final doc = await _firestore
          .collection(_communicationsCollection)
          .doc(communicationId)
          .get();

      if (doc.exists) {
        return CommunicationModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch communication: $e');
    }
  }

  // Create new communication
  Future<void> createCommunication(CommunicationModel communication) async {
    try {
      await _firestore
          .collection(_communicationsCollection)
          .doc(communication.id)
          .set(communication.toJson());
    } catch (e) {
      throw Exception('Failed to create communication: $e');
    }
  }

  // Update communication
  Future<void> updateCommunication(CommunicationModel communication) async {
    try {
      await _firestore
          .collection(_communicationsCollection)
          .doc(communication.id)
          .update(communication.toJson());
    } catch (e) {
      throw Exception('Failed to update communication: $e');
    }
  }

  // Delete communication
  Future<void> deleteCommunication(String communicationId) async {
    try {
      await _firestore
          .collection(_communicationsCollection)
          .doc(communicationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete communication: $e');
    }
  }

  // Mark communication as read
  Future<void> markAsRead({
    required String communicationId,
    required String employeeId,
  }) async {
    try {
      await _firestore
          .collection(_communicationsCollection)
          .doc(communicationId)
          .update({
        'readBy': FieldValue.arrayUnion([employeeId]),
        'readAt.$employeeId': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  // Create announcement
  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    try {
      await _firestore
          .collection(_announcementsCollection)
          .doc(announcement.id)
          .set(announcement.toJson());

      // Also create as communication for unified access
      final communication = CommunicationModel(
        id: announcement.id,
        title: announcement.title,
        content: announcement.content,
        type: CommunicationType.announcement,
        priority: announcement.priority,
        senderId: announcement.createdBy,
        senderName: 'HR Team',
        recipients: announcement.targetAudience,
        createdAt: announcement.createdAt,
        updatedAt: announcement.updatedAt,
        isActive: announcement.isActive,
      );

      await createCommunication(communication);
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  // Send notification
  Future<void> sendNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notification.id)
          .set(notification.toJson());

      // Also create as communication for unified access
      final communication = CommunicationModel(
        id: notification.id,
        title: notification.title,
        content: notification.message,
        type: CommunicationType.notification,
        priority: notification.priority,
        senderId: notification.senderId,
        senderName: notification.senderName,
        recipients: [notification.recipientId],
        createdAt: notification.createdAt,
        updatedAt: notification.updatedAt,
        isActive: true,
      );

      await createCommunication(communication);
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  // Get announcements
  Future<List<AnnouncementModel>> getAnnouncements({
    bool? isActive,
    String? targetDepartment,
  }) async {
    try {
      Query query = _firestore.collection(_announcementsCollection);

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      if (targetDepartment != null) {
        query = query.where('targetAudience', arrayContains: targetDepartment);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch announcements: $e');
    }
  }

  // Get employee notifications
  Future<List<NotificationModel>> getEmployeeNotifications(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('recipientId', isEqualTo: employeeId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('recipientId', isEqualTo: employeeId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread notifications count: $e');
    }
  }

  // Search communications
  Future<List<CommunicationModel>> searchCommunications({
    required String searchTerm,
    String? employeeId,
    String? type,
  }) async {
    try {
      Query query = _firestore.collection(_communicationsCollection);

      if (employeeId != null) {
        query = query.where('recipients', arrayContains: employeeId);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      final snapshot = await query.get();
      final allCommunications = snapshot.docs
          .map((doc) => CommunicationModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter results based on search term
      return allCommunications.where((communication) {
        final searchLower = searchTerm.toLowerCase();
        return communication.title.toLowerCase().contains(searchLower) ||
               communication.content.toLowerCase().contains(searchLower) ||
               communication.senderName.toLowerCase().contains(searchLower);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search communications: $e');
    }
  }

  // Send bulk notification
  Future<void> sendBulkNotification({
    required String title,
    required String message,
    required List<String> recipientIds,
    required String senderId,
    required String senderName,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final recipientId in recipientIds) {
        final notification = NotificationModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_$recipientId',
          title: title,
          message: message,
          recipientId: recipientId,
          senderId: senderId,
          senderName: senderName,
          priority: priority,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final notificationRef = _firestore
            .collection(_notificationsCollection)
            .doc(notification.id);
        
        batch.set(notificationRef, notification.toJson());

        // Also add to communications
        final communication = CommunicationModel(
          id: notification.id,
          title: title,
          content: message,
          type: CommunicationType.notification,
          priority: CommunicationPriority.values.firstWhere(
            (p) => p.name == priority.name,
            orElse: () => CommunicationPriority.normal,
          ),
          senderId: senderId,
          senderName: senderName,
          recipients: [recipientId],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );

        final communicationRef = _firestore
            .collection(_communicationsCollection)
            .doc(communication.id);
        
        batch.set(communicationRef, communication.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to send bulk notification: $e');
    }
  }

  // Get communication statistics
  Future<Map<String, dynamic>> getCommunicationStatistics({
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_communicationsCollection);

      if (employeeId != null) {
        query = query.where('recipients', arrayContains: employeeId);
      }

      if (startDate != null && endDate != null) {
        query = query
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final communications = snapshot.docs
          .map((doc) => CommunicationModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      int totalCommunications = communications.length;
      int announcements = 0;
      int notifications = 0;
      int messages = 0;
      int readCommunications = 0;

      for (final communication in communications) {
        switch (communication.type.name) {
          case 'announcement':
            announcements++;
            break;
          case 'notification':
            notifications++;
            break;
          case 'message':
            messages++;
            break;
        }

        if (employeeId != null && communication.readBy.contains(employeeId)) {
          readCommunications++;
        }
      }

      final readRate = totalCommunications > 0 ? (readCommunications / totalCommunications) * 100 : 0.0;

      return {
        'totalCommunications': totalCommunications,
        'announcements': announcements,
        'notifications': notifications,
        'messages': messages,
        'readCommunications': readCommunications,
        'readRate': readRate,
        'communications': communications,
      };
    } catch (e) {
      throw Exception('Failed to get communication statistics: $e');
    }
  }
}
