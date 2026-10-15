// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_integration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ExternalIntegration _$$_ExternalIntegrationFromJson(
        Map<String, dynamic> json) =>
    _$_ExternalIntegration(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      displayName: json['displayName'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      externalReferenceLabel: json['externalReferenceLabel'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      enabledForNewEvents: json['enabledForNewEvents'] as bool? ?? false,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: dateTimeFromTimestamp(json['createdAt']),
      updatedAt: dateTimeFromTimestamp(json['updatedAt']),
      secretRotatedAt: dateTimeFromTimestamp(json['secretRotatedAt']),
    );

Map<String, dynamic> _$$_ExternalIntegrationToJson(
        _$_ExternalIntegration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'communityId': instance.communityId,
      'displayName': instance.displayName,
      'logoUrl': instance.logoUrl,
      'description': instance.description,
      'externalReferenceLabel': instance.externalReferenceLabel,
      'isActive': instance.isActive,
      'enabledForNewEvents': instance.enabledForNewEvents,
      'events': instance.events,
      'createdAt': serverTimestampOrNull(instance.createdAt),
      'updatedAt': serverTimestampOrNull(instance.updatedAt),
      'secretRotatedAt': serverTimestampOrNull(instance.secretRotatedAt),
    };

_$_ExternalIntegrationEndpoint _$$_ExternalIntegrationEndpointFromJson(
        Map<String, dynamic> json) =>
    _$_ExternalIntegrationEndpoint(
      integrationId: json['integrationId'] as String,
      communityId: json['communityId'] as String,
      webhookUrl: json['webhookUrl'] as String,
      updatedAt: dateTimeFromTimestamp(json['updatedAt']),
    );

Map<String, dynamic> _$$_ExternalIntegrationEndpointToJson(
        _$_ExternalIntegrationEndpoint instance) =>
    <String, dynamic>{
      'integrationId': instance.integrationId,
      'communityId': instance.communityId,
      'webhookUrl': instance.webhookUrl,
      'updatedAt': serverTimestampOrNull(instance.updatedAt),
    };

_$_EventExternalIntegrationSettings
    _$$_EventExternalIntegrationSettingsFromJson(Map<String, dynamic> json) =>
        _$_EventExternalIntegrationSettings(
          integrationId: json['integrationId'] as String,
          enabled: json['enabled'] as bool? ?? false,
          externalReference: json['externalReference'] as String?,
          updatedBy: json['updatedBy'] as String?,
          updatedAt: dateTimeFromTimestamp(json['updatedAt']),
        );

Map<String, dynamic> _$$_EventExternalIntegrationSettingsToJson(
        _$_EventExternalIntegrationSettings instance) =>
    <String, dynamic>{
      'integrationId': instance.integrationId,
      'enabled': instance.enabled,
      'externalReference': instance.externalReference,
      'updatedBy': instance.updatedBy,
      'updatedAt': serverTimestamp(instance.updatedAt),
    };

_$_ExternalIntegrationDelivery _$$_ExternalIntegrationDeliveryFromJson(
        Map<String, dynamic> json) =>
    _$_ExternalIntegrationDelivery(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      integrationId: json['integrationId'] as String,
      eventType: json['eventType'] as String,
      eventPath: json['eventPath'] as String?,
      recordingSessionId: json['recordingSessionId'] as String?,
      artifactKey: json['artifactKey'] as String?,
      artifactPath: json['artifactPath'] as String?,
      status: $enumDecodeNullable(
              _$ExternalIntegrationDeliveryStatusEnumMap, json['status'],
              unknownValue: ExternalIntegrationDeliveryStatus.pending) ??
          ExternalIntegrationDeliveryStatus.pending,
      attempts: json['attempts'] as int? ?? 0,
      lastError: json['lastError'] as String?,
      lastResponseStatus: json['lastResponseStatus'] as int?,
      createdAt: dateTimeFromTimestamp(json['createdAt']),
      updatedAt: dateTimeFromTimestamp(json['updatedAt']),
      lastAttemptAt: dateTimeFromTimestamp(json['lastAttemptAt']),
      nextAttemptAt: dateTimeFromTimestamp(json['nextAttemptAt']),
      deliveredAt: dateTimeFromTimestamp(json['deliveredAt']),
    );

Map<String, dynamic> _$$_ExternalIntegrationDeliveryToJson(
        _$_ExternalIntegrationDelivery instance) =>
    <String, dynamic>{
      'id': instance.id,
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'integrationId': instance.integrationId,
      'eventType': instance.eventType,
      'eventPath': instance.eventPath,
      'recordingSessionId': instance.recordingSessionId,
      'artifactKey': instance.artifactKey,
      'artifactPath': instance.artifactPath,
      'status': _$ExternalIntegrationDeliveryStatusEnumMap[instance.status]!,
      'attempts': instance.attempts,
      'lastError': instance.lastError,
      'lastResponseStatus': instance.lastResponseStatus,
      'createdAt': serverTimestampOrNull(instance.createdAt),
      'updatedAt': serverTimestampOrNull(instance.updatedAt),
      'lastAttemptAt': serverTimestampOrNull(instance.lastAttemptAt),
      'nextAttemptAt': serverTimestampOrNull(instance.nextAttemptAt),
      'deliveredAt': serverTimestampOrNull(instance.deliveredAt),
    };

const _$ExternalIntegrationDeliveryStatusEnumMap = {
  ExternalIntegrationDeliveryStatus.pending: 'pending',
  ExternalIntegrationDeliveryStatus.delivered: 'delivered',
  ExternalIntegrationDeliveryStatus.failed: 'failed',
};
