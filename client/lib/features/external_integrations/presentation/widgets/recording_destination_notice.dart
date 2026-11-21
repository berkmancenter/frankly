import 'dart:async';

import 'package:client/core/data/services/logging_service.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/features/external_integrations/presentation/widgets/integration_badge.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import 'package:flutter/material.dart';

/// "Recordings from this event are sent to [logo] Name". Renders nothing when
/// no external integration is switched on for the event.
///
/// Shows a spinner until the lookup has finished, and an error with a reload
/// button if it fails. [onLoaded] is called once the lookup has succeeded, so
/// a dialog can keep its Continue button off until the participant has seen
/// where recordings go.
class RecordingDestinationNotice extends StatefulWidget {
  final Event event;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onLoaded;

  const RecordingDestinationNotice({
    required this.event,
    this.padding = const EdgeInsets.only(top: 12),
    this.onLoaded,
    Key? key,
  }) : super(key: key);

  @override
  State<RecordingDestinationNotice> createState() =>
      _RecordingDestinationNoticeState();
}

class _RecordingDestinationNoticeState
    extends State<RecordingDestinationNotice> {
  StreamSubscription<List<ExternalIntegration>>? _subscription;
  List<ExternalIntegration>? _integrations;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(RecordingDestinationNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.fullPath != widget.event.fullPath) {
      _integrations = null;
      _failed = false;
      _listen();
    }
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = externalIntegrationsService
        .enabledIntegrationsForEvent(widget.event)
        .listen(
      (integrations) {
        final firstResult = _integrations == null;
        setState(() {
          _integrations = integrations;
          _failed = false;
        });
        if (firstResult) widget.onLoaded?.call();
      },
      onError: (Object error, StackTrace stackTrace) {
        loggingService.log(
          error,
          logType: LogType.error,
          stackTrace: stackTrace,
        );
        if (_integrations == null) setState(() => _failed = true);
      },
    );
  }

  void _reload() {
    setState(() => _failed = false);
    _listen();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final integrations = _integrations;
    if (integrations == null) {
      return Padding(
        padding: widget.padding,
        child: _failed
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.somethingWentWrong,
                      style: context.theme.textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: _reload,
                    child: Text(context.l10n.reload),
                  ),
                ],
              )
            : const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
      );
    }
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
  }
}
