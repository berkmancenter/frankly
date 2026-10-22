import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_switch_tile.dart';
import 'package:client/features/external_integrations/presentation/widgets/integration_badge.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef _SectionData = (
  List<ExternalIntegration>,
  Map<String, EventExternalIntegrationSettings>,
);

/// Event settings: lets the host switch each external integration on or off
/// for this event and set the optional pass-through reference. Renders
/// nothing when the community has no active integration.
class EventExternalIntegrationsSection extends StatefulWidget {
  final Event event;

  const EventExternalIntegrationsSection({required this.event, Key? key})
      : super(key: key);

  @override
  State<EventExternalIntegrationsSection> createState() =>
      _EventExternalIntegrationsSectionState();
}

class _EventExternalIntegrationsSectionState
    extends State<EventExternalIntegrationsSection> {
  late final Stream<_SectionData> _data;

  @override
  void initState() {
    super.initState();
    _data = Rx.combineLatest2(
      externalIntegrationsService.activeIntegrations(widget.event.communityId),
      externalIntegrationsService.eventSettings(widget.event),
      (
        List<ExternalIntegration> integrations,
        Map<String, EventExternalIntegrationSettings> settings,
      ) =>
          (integrations, settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_SectionData>(
      stream: _data,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || data.$1.isEmpty) return const SizedBox.shrink();
        final (integrations, settings) = data;
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.eventIntegrationsTitle,
                style: context.theme.textTheme.titleSmall,
              ),
              SizedBox(height: 4),
              Text(
                context.l10n.eventIntegrationNeedsRecording,
                style: context.theme.textTheme.bodySmall,
              ),
              SizedBox(height: 8),
              for (final integration in integrations)
                _EventIntegrationTile(
                  key: ValueKey(integration.id),
                  event: widget.event,
                  integration: integration,
                  settings: settings[integration.id],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EventIntegrationTile extends StatefulWidget {
  final Event event;
  final ExternalIntegration integration;
  final EventExternalIntegrationSettings? settings;

  const _EventIntegrationTile({
    required this.event,
    required this.integration,
    required this.settings,
    Key? key,
  }) : super(key: key);

  @override
  State<_EventIntegrationTile> createState() => _EventIntegrationTileState();
}

class _EventIntegrationTileState extends State<_EventIntegrationTile> {
  late final TextEditingController _reference;
  bool _saving = false;

  bool get _enabled => widget.settings?.enabled ?? false;

  @override
  void initState() {
    super.initState();
    _reference =
        TextEditingController(text: widget.settings?.externalReference ?? '');
  }

  @override
  void didUpdateWidget(_EventIntegrationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final saved = widget.settings?.externalReference ?? '';
    if (oldWidget.settings?.externalReference != saved &&
        _reference.text == (oldWidget.settings?.externalReference ?? '')) {
      _reference.text = saved;
    }
  }

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  Future<void> _save({required bool enabled}) async {
    setState(() => _saving = true);
    await alertOnError(
      context,
      () => externalIntegrationsService.updateEventSettings(
        event: widget.event,
        integrationId: widget.integration.id,
        enabled: enabled,
        externalReference: _reference.text,
      ),
    );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.integration.description;
    final referenceLabel = widget.integration.externalReferenceLabel ??
        context.l10n.eventIntegrationReferenceHint;
    final referenceChanged =
        _reference.text.trim() != (widget.settings?.externalReference ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSwitchTile(
            textWidget: Align(
              alignment: Alignment.centerLeft,
              child: IntegrationBadge(integration: widget.integration),
            ),
            val: _enabled,
            loading: _saving,
            onUpdate: (value) => _save(enabled: value),
          ),
          if (description != null && description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                description,
                style: context.theme.textTheme.bodySmall,
              ),
            ),
          if (_enabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: TextField(
                controller: _reference,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: referenceLabel,
                  isDense: true,
                  counterText: '',
                  suffixIcon: referenceChanged
                      ? IconButton(
                          tooltip: context.l10n.save,
                          icon: Icon(Icons.check),
                          onPressed:
                              _saving ? null : () => _save(enabled: true),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _save(enabled: true),
              ),
            ),
        ],
      ),
    );
  }
}
