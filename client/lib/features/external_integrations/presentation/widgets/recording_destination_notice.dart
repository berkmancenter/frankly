import 'package:client/core/localization/localization_helper.dart';
import 'package:client/features/external_integrations/presentation/widgets/integration_badge.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import 'package:flutter/material.dart';

/// "Recordings from this event are sent to [logo] Name". Renders nothing when
/// no external integration is switched on for the event.
class RecordingDestinationNotice extends StatefulWidget {
  final Event event;
  final EdgeInsetsGeometry padding;

  const RecordingDestinationNotice({
    required this.event,
    this.padding = const EdgeInsets.only(top: 12),
    Key? key,
  }) : super(key: key);

  @override
  State<RecordingDestinationNotice> createState() =>
      _RecordingDestinationNoticeState();
}

class _RecordingDestinationNoticeState
    extends State<RecordingDestinationNotice> {
  late Stream<List<ExternalIntegration>> _integrations;

  @override
  void initState() {
    super.initState();
    _integrations =
        externalIntegrationsService.enabledIntegrationsForEvent(widget.event);
  }

  @override
  void didUpdateWidget(RecordingDestinationNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.fullPath != widget.event.fullPath) {
      _integrations =
          externalIntegrationsService.enabledIntegrationsForEvent(widget.event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExternalIntegration>>(
      stream: _integrations,
      builder: (context, snapshot) {
        final integrations = snapshot.data ?? const [];
        if (integrations.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.recordingsAreSentTo,
                style: context.theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  for (final integration in integrations)
                    IntegrationBadge(integration: integration),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
