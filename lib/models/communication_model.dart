import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'communication_model.g.dart';

/// Communication types
enum CommunicationType { message, announcement, notification, memo, alert }

/// Communication priority levels
enum CommunicationPriority { low, normal, high, urgent }

/// Notification priority levels
enum NotificationPriority { low, normal, high, urgent }

/// Notification types
enum NotificationType { info, warning, error, success, reminder }

/// Main communication model for unified messaging
@JsonSerializable()
class CommunicationModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final CommunicationType type;
  final CommunicationPriority priority;
  final String senderId;
  final String senderName;
  final List<String> recipients;
  final List<String> readBy;
  final Map<String, DateTime>? readAt;
  final List<String>? attachments;
  final bool isActive;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommunicationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.priority = CommunicationPriority.normal,
    required this.senderId,
    required this.senderName,
    required this.recipients,
    this.readBy = const [],
    this.readAt,
    this.attachments,
    this.isActive = true,
    this.scheduledAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunicationModel.fromJson(Map<String, dynamic> json) =>
      _$CommunicationModelFromJson(json);
  Map<String, dynamic> toJson() => _$CommunicationModelToJson(this);

  /// Check if communication is read by specific user
  bool isReadBy(String userId) => readBy.contains(userId);

  /// Check if communication is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if communication is scheduled for future
  bool get isScheduled {
    if (scheduledAt == null) return false;
    return DateTime.now().isBefore(scheduledAt!);
  }

  /// Get read percentage
  double get readPercentage {
    if (recipients.isEmpty) return 0.0;
    return (readBy.length / recipients.length) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        type,
        priority,
        senderId,
        senderName,
        recipients,
        readBy,
        readAt,
        attachments,
        isActive,
        scheduledAt,
        expiresAt,
        createdAt,
        updatedAt,
      ];

  CommunicationModel copyWith({
    String? id,
    String? title,
    String? content,
    CommunicationType? type,
    CommunicationPriority? priority,
    String? senderId,
    String? senderName,
    List<String>? recipients,
    List<String>? readBy,
    Map<String, DateTime>? readAt,
    List<String>? attachments,
    bool? isActive,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunicationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipients: recipients ?? this.recipients,
      readBy: readBy ?? this.readBy,
      readAt: readAt ?? this.readAt,
      attachments: attachments ?? this.attachments,
      isActive: isActive ?? this.isActive,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Announcement model for company-wide communications
@JsonSerializable()
class AnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final CommunicationPriority priority;
  final List<String> targetAudience; // departments, roles, or 'all'
  final List<String>? attachments;
  final String createdBy;
  final String createdByName;
  final bool isActive;
  final bool isPinned;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.priority = CommunicationPriority.normal,
    required this.targetAudience,
    this.attachments,
    required this.createdBy,
    required this.createdByName,
    this.isActive = true,
    this.isPinned = false,
    this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);
  Map<String, dynamic> toJson() => _$AnnouncementModelToJson(this);

  /// Check if announcement is published
  bool get isPublished {
    if (publishedAt == null) return false;
    return DateTime.now().isAfter(publishedAt!) || DateTime.now().isAtSameMomentAs(publishedAt!);
  }

  /// Check if announcement is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        priority,
        targetAudience,
        attachments,
        createdBy,
        createdByName,
        isActive,
        isPinned,
        publishedAt,
        expiresAt,
        createdAt,
        updatedAt,
      ];
}

/// Notification model for individual user notifications
@JsonSerializable()
class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final String recipientId;
  final String senderId;
  final String senderName;
  final Map<String, dynamic>? data; // Additional data for deep linking
  final String? imageUrl;
  final String? actionUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type = NotificationType.info,
    this.priority = NotificationPriority.normal,
    required this.recipientId,
    required this.senderId,
    required this.senderName,
    this.data,
    this.imageUrl,
    this.actionUrl,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        priority,
        recipientId,
        senderId,
        senderName,
        data,
        imageUrl,
        actionUrl,
        isRead,
        readAt,
        createdAt,
        updatedAt,
      ];

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    String? recipientId,
    String? senderId,
    String? senderName,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
