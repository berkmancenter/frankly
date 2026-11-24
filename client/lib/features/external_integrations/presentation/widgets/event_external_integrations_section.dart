import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/widgets/custom_switch_tile.dart';
import 'package:client/features/external_integrations/data/models/event_integration_change.dart';
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
///
/// Nothing is written here. Edits are reported through [onChanged] and kept
/// in [pendingChanges] by the event settings drawer, which writes them when
/// the drawer is saved.
class EventExternalIntegrationsSection extends StatefulWidget {
  final Event event;

  /// Unsaved changes keyed by integration id.
  final Map<String, EventIntegrationChange> pendingChanges;

  /// Called with an integration's new values, or `null` when they match the
  /// saved settings again.
  final void Function(String integrationId, EventIntegrationChange? change)
      onChanged;

  const EventExternalIntegrationsSection({
    required this.event,
    required this.pendingChanges,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

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
                  integration: integration,
                  settings: settings[integration.id],
                  pendingChange: widget.pendingChanges[integration.id],
                  onChanged: (change) =>
                      widget.onChanged(integration.id, change),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EventIntegrationTile extends StatefulWidget {
  final ExternalIntegration integration;
  final EventExternalIntegrationSettings? settings;
  final EventIntegrationChange? pendingChange;
  final void Function(EventIntegrationChange? change) onChanged;

  const _EventIntegrationTile({
    required this.integration,
    required this.settings,
    required this.pendingChange,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<_EventIntegrationTile> createState() => _EventIntegrationTileState();
}

class _EventIntegrationTileState extends State<_EventIntegrationTile> {
  late final TextEditingController _reference;

  bool get _savedEnabled => widget.settings?.enabled ?? false;
  String get _savedReference => widget.settings?.externalReference ?? '';
  bool get _enabled => widget.pendingChange?.enabled ?? _savedEnabled;

  @override
  void initState() {
    super.initState();
    _reference = TextEditingController(
      text: widget.pendingChange?.externalReference ?? _savedReference,
    );
  }

  @override
  void didUpdateWidget(_EventIntegrationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow a saved value that changed elsewhere, unless the host is
    // editing this field.
    if (widget.pendingChange == null && _reference.text != _savedReference) {
      _reference.text = _savedReference;
    }
  }

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  /// Reports the current values to the drawer, or `null` when they match
  /// what is saved, so there is nothing to save.
  void _update({bool? enabled}) {
    final change = EventIntegrationChange(
      enabled: enabled ?? _enabled,
      externalReference: _reference.text,
    );
    final unchanged = change.enabled == _savedEnabled &&
        change.externalReference.trim() == _savedReference;
    widget.onChanged(unchanged ? null : change);
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.integration.description;
    final referenceLabel = widget.integration.externalReferenceLabel ??
        context.l10n.eventIntegrationReferenceHint;

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
            onUpdate: (value) => _update(enabled: value),
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
                ),
                onChanged: (_) => _update(),
              ),
            ),
        ],
      ),
    );
  }
}
