import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import 'package:rxdart/rxdart.dart';

/// Reads and changes external integrations (webhooks that receive recordings
/// and transcripts). Configuration changes go through Cloud Functions; the
/// per-event switch is written directly by the host.
class ExternalIntegrationsService {
  CollectionReference<Map<String, dynamic>> _integrations(String communityId) =>
      firestoreDatabase
          .communityRef(communityId)
          .collection(ExternalIntegration.kCollection);

  /// All integrations of a community, including inactive ones (for admins).
  Stream<List<ExternalIntegration>> allIntegrations(String communityId) {
    return _integrations(communityId).snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ExternalIntegration.fromJson(
                  {...fromFirestoreJson(doc.data()), 'id': doc.id},
                ),
              )
              .toList()
            ..sort((a, b) => a.displayName.compareTo(b.displayName)),
        );
  }

  /// Integrations event hosts and participants can see.
  Stream<List<ExternalIntegration>> activeIntegrations(String communityId) {
    return allIntegrations(communityId)
        .map((list) => list.where((i) => i.isActive).toList());
  }

  /// Admin-only webhook URL of an integration.
  Future<ExternalIntegrationEndpoint?> getEndpoint({
    required String communityId,
    required String integrationId,
  }) async {
    final doc = await firestoreDatabase
        .communityRef(communityId)
        .collection(ExternalIntegrationEndpoint.kCollection)
        .doc(integrationId)
        .get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return ExternalIntegrationEndpoint.fromJson(fromFirestoreJson(data));
  }

  CollectionReference<Map<String, dynamic>> _eventSettings(Event event) =>
      firestoreDatabase.firestore
          .doc(event.fullPath)
          .collection(EventExternalIntegrationSettings.kCollection);

  /// Per-event settings keyed by integration id.
  Stream<Map<String, EventExternalIntegrationSettings>> eventSettings(
    Event event,
  ) {
    return _eventSettings(event).snapshots().map(
          (snapshot) => {
            for (final doc in snapshot.docs)
              doc.id: EventExternalIntegrationSettings.fromJson(
                {
                  ...fromFirestoreJson(doc.data()),
                  'integrationId': doc.id,
                },
              ),
          },
        );
  }

  /// Integrations that will receive this event's recordings. Empty when the
  /// feature is not used, so callers can hide their UI.
  ///
  /// Follows changes to both the community's integrations and the event's
  /// settings. The settings are only listened to while the community has an
  /// active integration.
  Stream<List<ExternalIntegration>> enabledIntegrationsForEvent(Event event) {
    return activeIntegrations(event.communityId).switchMap(
      (integrations) => integrations.isEmpty
          ? Stream.value(const <ExternalIntegration>[])
          : eventSettings(event).map(
              (settings) => integrations
                  .where((i) => settings[i.id]?.enabled ?? false)
                  .toList(),
            ),
    );
  }

  Future<void> updateEventSettings({
    required Event event,
    required String integrationId,
    required bool enabled,
    String? externalReference,
  }) async {
    final reference = externalReference?.trim();
    await _eventSettings(event).doc(integrationId).set(
          toFirestoreJson(
            EventExternalIntegrationSettings(
              integrationId: integrationId,
              enabled: enabled,
              externalReference:
                  (reference == null || reference.isEmpty) ? null : reference,
              updatedBy: userService.currentUserId,
            ).toJson(),
          ),
        );
  }

  Stream<List<ExternalIntegrationDelivery>> deliveriesForEvent(Event event) {
    return firestoreDatabase.firestore
        .collection(ExternalIntegrationDelivery.kCollection)
        .where(
          ExternalIntegrationDelivery.kFieldCommunityId,
          isEqualTo: event.communityId,
        )
        .where(ExternalIntegrationDelivery.kFieldEventId, isEqualTo: event.id)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ExternalIntegrationDelivery.fromJson(
                  {...fromFirestoreJson(doc.data()), 'id': doc.id},
                ),
              )
              .toList()
            ..sort(
              (a, b) => (a.artifactPath ?? '').compareTo(b.artifactPath ?? ''),
            ),
        );
  }

  Future<UpsertExternalIntegrationResponse> upsertIntegration(
    UpsertExternalIntegrationRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      UpsertExternalIntegrationRequest.functionName,
      request.toJson(),
    );
    return UpsertExternalIntegrationResponse.fromJson(
      Map<String, dynamic>.from(result),
    );
  }

  Future<String> rotateSecret({
    required String communityId,
    required String integrationId,
  }) async {
    final result = await cloudFunctions.callFunction(
      RotateExternalIntegrationSecretRequest.functionName,
      RotateExternalIntegrationSecretRequest(
        communityId: communityId,
        integrationId: integrationId,
      ).toJson(),
    );
    return RotateExternalIntegrationSecretResponse.fromJson(
      Map<String, dynamic>.from(result),
    ).secret;
  }

  Future<void> deleteIntegration({
    required String communityId,
    required String integrationId,
  }) async {
    await cloudFunctions.callFunction(
      DeleteExternalIntegrationRequest.functionName,
      DeleteExternalIntegrationRequest(
        communityId: communityId,
        integrationId: integrationId,
      ).toJson(),
    );
  }

  Future<void> resendDelivery(String deliveryId) async {
    await cloudFunctions.callFunction(
      ResendExternalIntegrationDeliveryRequest.functionName,
      ResendExternalIntegrationDeliveryRequest(deliveryId: deliveryId).toJson(),
    );
  }
}
