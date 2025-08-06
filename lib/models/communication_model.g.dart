// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunicationModel _$CommunicationModelFromJson(Map<String, dynamic> json) =>
    CommunicationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: $enumDecode(_$CommunicationTypeEnumMap, json['type']),
      priority: $enumDecodeNullable(
              _$CommunicationPriorityEnumMap, json['priority']) ??
          CommunicationPriority.normal,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      recipients: (json['recipients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      readBy: (json['readBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      readAt: (json['readAt'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, DateTime.parse(e as String)),
      ),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CommunicationModelToJson(CommunicationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'type': _$CommunicationTypeEnumMap[instance.type]!,
      'priority': _$CommunicationPriorityEnumMap[instance.priority]!,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'recipients': instance.recipients,
      'readBy': instance.readBy,
      'readAt':
          instance.readAt?.map((k, e) => MapEntry(k, e.toIso8601String())),
      'attachments': instance.attachments,
      'isActive': instance.isActive,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CommunicationTypeEnumMap = {
  CommunicationType.message: 'message',
  CommunicationType.announcement: 'announcement',
  CommunicationType.notification: 'notification',
  CommunicationType.memo: 'memo',
  CommunicationType.alert: 'alert',
};

const _$CommunicationPriorityEnumMap = {
  CommunicationPriority.low: 'low',
  CommunicationPriority.normal: 'normal',
  CommunicationPriority.high: 'high',
  CommunicationPriority.urgent: 'urgent',
};

AnnouncementModel _$AnnouncementModelFromJson(Map<String, dynamic> json) =>
    AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      priority: $enumDecodeNullable(
              _$CommunicationPriorityEnumMap, json['priority']) ??
          CommunicationPriority.normal,
      targetAudience: (json['targetAudience'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdBy: json['createdBy'] as String,
      createdByName: json['createdByName'] as String,
      isActive: json['isActive'] as bool? ?? true,
      isPinned: json['isPinned'] as bool? ?? false,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AnnouncementModelToJson(AnnouncementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'priority': _$CommunicationPriorityEnumMap[instance.priority]!,
      'targetAudience': instance.targetAudience,
      'attachments': instance.attachments,
      'createdBy': instance.createdBy,
      'createdByName': instance.createdByName,
      'isActive': instance.isActive,
      'isPinned': instance.isPinned,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']) ??
          NotificationType.info,
      priority: $enumDecodeNullable(
              _$NotificationPriorityEnumMap, json['priority']) ??
          NotificationPriority.normal,
      recipientId: json['recipientId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'recipientId': instance.recipientId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'data': instance.data,
      'imageUrl': instance.imageUrl,
      'actionUrl': instance.actionUrl,
      'isRead': instance.isRead,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.info: 'info',
  NotificationType.warning: 'warning',
  NotificationType.error: 'error',
  NotificationType.success: 'success',
  NotificationType.reminder: 'reminder',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};
