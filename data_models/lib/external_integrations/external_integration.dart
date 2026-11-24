import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'external_integration.freezed.dart';
part 'external_integration.g.dart';

/// Webhook event types an external integration can subscribe to.
///
/// Stored as plain strings so that unknown values written by a newer server
/// never break older clients.
class ExternalIntegrationEventTypes {
  static const String recordingReady = 'recording.ready';
  static const String transcriptReady = 'transcript.ready';

  static const List<String> all = [recordingReady, transcriptReady];
}

/// A community-level external integration: a webhook receiver that is sent
/// recording and transcript artifacts when they are ready.
///
/// Stored at `community/{communityId}/external-integrations/{id}`. Readable by
/// signed-in users (so participants can see where recordings go); written only
/// by Cloud Functions. The webhook URL and the signing secret are stored
/// elsewhere (see [ExternalIntegrationEndpoint]) so that they are not exposed
/// to participants.
@Freezed(makeCollectionsUnmodifiable: false)
class ExternalIntegration with _$ExternalIntegration {
  static const String kCollection = 'external-integrations';
  static const String kFieldIsActive = 'isActive';

  factory ExternalIntegration({
    required String id,
    required String communityId,
    required String displayName,

    /// Image shown next to [displayName] in the UI.
    String? logoUrl,

    /// Short description shown to community admins and event hosts.
    String? description,

    /// Optional label for the free-text value hosts can set per event
    /// (for example "Project ID"). The value is passed through to the
    /// webhook payload untouched.
    String? externalReferenceLabel,

    /// When false, no deliveries are sent and the integration is hidden from
    /// event hosts and participants.
    @Default(true) bool isActive,

    /// Whether the integration is switched on for newly created events.
    @Default(false) bool enabledForNewEvents,

    /// Event types this integration receives. See
    /// [ExternalIntegrationEventTypes].
    @Default([]) List<String> events,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? createdAt,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? updatedAt,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? secretRotatedAt,
  }) = _ExternalIntegration;

  factory ExternalIntegration.fromJson(Map<String, dynamic> json) =>
      _$ExternalIntegrationFromJson(json);
}

/// Admin-only delivery target of an [ExternalIntegration].
///
/// Stored at `community/{communityId}/external-integration-endpoints/{id}`
/// (same id as the integration). Readable by community admins only; written
/// only by Cloud Functions.
@Freezed(makeCollectionsUnmodifiable: false)
class ExternalIntegrationEndpoint with _$ExternalIntegrationEndpoint {
  static const String kCollection = 'external-integration-endpoints';

  factory ExternalIntegrationEndpoint({
    required String integrationId,
    required String communityId,
    required String webhookUrl,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? updatedAt,
  }) = _ExternalIntegrationEndpoint;

  factory ExternalIntegrationEndpoint.fromJson(Map<String, dynamic> json) =>
      _$ExternalIntegrationEndpointFromJson(json);
}

/// Per-event switch for an [ExternalIntegration].
///
/// Stored at
/// `community/{c}/templates/{t}/events/{e}/external-integration-settings/{integrationId}`.
/// Written by the event host or community moderators. A missing document
/// means the integration is off for this event.
@Freezed(makeCollectionsUnmodifiable: false)
class EventExternalIntegrationSettings with _$EventExternalIntegrationSettings {
  static const String kCollection = 'external-integration-settings';
  static const String kFieldEnabled = 'enabled';
  static const String kFieldExternalReference = 'externalReference';

  factory EventExternalIntegrationSettings({
    required String integrationId,
    @Default(false) bool enabled,

    /// Free-text value passed through to the webhook payload untouched.
    String? externalReference,
    String? updatedBy,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? updatedAt,
  }) = _EventExternalIntegrationSettings;

  factory EventExternalIntegrationSettings.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$EventExternalIntegrationSettingsFromJson(json);
}

enum ExternalIntegrationDeliveryStatus {
  pending,
  delivered,
  failed,
}

/// Status of one webhook delivery (one artifact, one integration).
///
/// Stored at `external-integration-deliveries/{id}`. Readable by community
/// moderators; written only by Cloud Functions. The id is derived from the
/// integration id, event type and artifact path, so it is stable across
/// retries and resends.
@Freezed(makeCollectionsUnmodifiable: false)
class ExternalIntegrationDelivery with _$ExternalIntegrationDelivery {
  static const String kCollection = 'external-integration-deliveries';
  static const String kFieldCommunityId = 'communityId';
  static const String kFieldEventId = 'eventId';

  factory ExternalIntegrationDelivery({
    required String id,
    required String communityId,
    required String eventId,
    required String integrationId,
    required String eventType,
    String? eventPath,
    String? recordingSessionId,
    String? artifactKey,
    String? artifactPath,
    @JsonKey(unknownEnumValue: ExternalIntegrationDeliveryStatus.pending)
    @Default(ExternalIntegrationDeliveryStatus.pending)
    ExternalIntegrationDeliveryStatus status,
    @Default(0) int attempts,
    String? lastError,
    int? lastResponseStatus,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? createdAt,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? updatedAt,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? lastAttemptAt,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? nextAttemptAt,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? deliveredAt,
  }) = _ExternalIntegrationDelivery;

  factory ExternalIntegrationDelivery.fromJson(Map<String, dynamic> json) =>
      _$ExternalIntegrationDeliveryFromJson(json);
}
