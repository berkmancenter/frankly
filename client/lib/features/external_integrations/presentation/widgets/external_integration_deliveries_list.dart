import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/features/external_integrations/presentation/widgets/integration_badge.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef _DeliveriesData = (
  List<ExternalIntegrationDelivery>,
  List<ExternalIntegration>,
);

/// Delivery status of an event's recordings and transcripts per external
/// integration, with a Resend action. Renders nothing when nothing was sent.
class ExternalIntegrationDeliveriesList extends StatefulWidget {
  final Event event;

  const ExternalIntegrationDeliveriesList({required this.event, Key? key})
      : super(key: key);

  @override
  State<ExternalIntegrationDeliveriesList> createState() =>
      _ExternalIntegrationDeliveriesListState();
}

class _ExternalIntegrationDeliveriesListState
    extends State<ExternalIntegrationDeliveriesList> {
  late final Stream<_DeliveriesData> _data;
  final Set<String> _resending = {};

  @override
  void initState() {
    super.initState();
    _data = Rx.combineLatest2(
      externalIntegrationsService.deliveriesForEvent(widget.event),
      externalIntegrationsService.allIntegrations(widget.event.communityId),
      (List<ExternalIntegrationDelivery> d, List<ExternalIntegration> i) =>
          (d, i),
    );
  }

  Future<void> _resend(ExternalIntegrationDelivery delivery) async {
    setState(() => _resending.add(delivery.id));
    final result = await alertOnError(context, () async {
      await externalIntegrationsService.resendDelivery(delivery.id);
      return true;
    });
    if (!mounted) return;
    setState(() => _resending.remove(delivery.id));
    if (result == true) {
      showRegularToast(
        context,
        context.l10n.deliveryResent,
        toastType: ToastType.success,
      );
    }
  }

  String _statusText(BuildContext context, ExternalIntegrationDelivery d) {
    switch (d.status) {
      case ExternalIntegrationDeliveryStatus.pending:
        return context.l10n.deliveryStatusPending;
      case ExternalIntegrationDeliveryStatus.delivered:
        return context.l10n.deliveryStatusDelivered;
      case ExternalIntegrationDeliveryStatus.failed:
        return context.l10n.deliveryStatusFailed;
    }
  }

  Color _statusColor(BuildContext context, ExternalIntegrationDelivery d) {
    final colors = context.theme.colorScheme;
    switch (d.status) {
      case ExternalIntegrationDeliveryStatus.pending:
        return colors.onSurfaceVariant;
      case ExternalIntegrationDeliveryStatus.delivered:
        return colors.primary;
      case ExternalIntegrationDeliveryStatus.failed:
        return colors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_DeliveriesData>(
      stream: _data,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || data.$1.isEmpty) return const SizedBox.shrink();
        final (deliveries, integrations) = data;
        final byId = {for (final i in integrations) i.id: i};

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.integrationDeliveries,
                style: context.theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              for (final delivery in deliveries)
                _buildRow(context, delivery, byId[delivery.integrationId]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    ExternalIntegrationDelivery delivery,
    ExternalIntegration? integration,
  ) {
    final l10n = context.l10n;
    final kind =
        delivery.eventType == ExternalIntegrationEventTypes.recordingReady
            ? l10n.deliveryKindRecording
            : l10n.deliveryKindTranscript;
    final fileName = delivery.artifactPath?.split('/').last ?? '';
    final lastError = delivery.lastError;
    final resending = _resending.contains(delivery.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (integration != null)
                  IntegrationBadge(integration: integration, logoSize: 16)
                else
                  Text(l10n.integrationRemoved),
                Text(
                  '$kind · $fileName',
                  style: context.theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_statusText(context, delivery)} · '
                  '${l10n.deliveryAttempts(delivery.attempts)}',
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: _statusColor(context, delivery),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (lastError != null &&
                    delivery.status !=
                        ExternalIntegrationDeliveryStatus.delivered)
                  Text(
                    lastError,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (integration != null)
            TextButton(
              onPressed: resending ? null : () => _resend(delivery),
              child: resending
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.deliveryResend),
            ),
        ],
      ),
    );
  }
}
