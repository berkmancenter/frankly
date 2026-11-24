import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/features/external_integrations/presentation/widgets/integration_badge.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Community admin settings for external integrations: list, add, edit,
/// rotate secret and delete. The data model allows several integrations per
/// community.
class ExternalIntegrationsAdminSection extends StatefulWidget {
  final String communityId;

  const ExternalIntegrationsAdminSection({required this.communityId, Key? key})
      : super(key: key);

  @override
  State<ExternalIntegrationsAdminSection> createState() =>
      _ExternalIntegrationsAdminSectionState();
}

class _ExternalIntegrationsAdminSectionState
    extends State<ExternalIntegrationsAdminSection> {
  late Stream<List<ExternalIntegration>> _integrations;

  @override
  void initState() {
    super.initState();
    _integrations =
        externalIntegrationsService.allIntegrations(widget.communityId);
  }

  Future<void> _edit(ExternalIntegration? integration) async {
    String? webhookUrl;
    if (integration != null) {
      final endpoint = await alertOnError(
        context,
        () => externalIntegrationsService.getEndpoint(
          communityId: widget.communityId,
          integrationId: integration.id,
        ),
      );
      webhookUrl = endpoint?.webhookUrl;
    }
    if (!mounted) return;
    // Not dismissible from outside: a save in progress may return a new
    // secret that is shown only once.
    final secret = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _IntegrationFormDialog(
        communityId: widget.communityId,
        integration: integration,
        webhookUrl: webhookUrl,
      ),
    );
    if (!mounted) return;
    if (secret != null) {
      await _showSecret(secret);
    }
  }

  Future<void> _showSecret(String secret) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.integrationSigningSecret),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dialogContext.l10n.integrationSecretShownOnce),
            SizedBox(height: 12),
            SelectableText(
              secret,
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: secret));
              if (!dialogContext.mounted) return;
              showRegularToast(
                dialogContext,
                dialogContext.l10n.copiedToClipboard,
                toastType: ToastType.success,
              );
            },
            child: Text(dialogContext.l10n.integrationCopySecret),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.l10n.integrationDone),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.theme.colorScheme.error,
            ),
            child: Text(title),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _rotate(ExternalIntegration integration) async {
    final l10n = context.l10n;
    if (!await _confirm(
      l10n.integrationRotateSecret,
      l10n.integrationRotateSecretConfirm,
    )) {
      return;
    }
    if (!mounted) return;
    final secret = await alertOnError(
      context,
      () => externalIntegrationsService.rotateSecret(
        communityId: widget.communityId,
        integrationId: integration.id,
      ),
    );
    if (secret != null && mounted) await _showSecret(secret);
  }

  Future<void> _delete(ExternalIntegration integration) async {
    final l10n = context.l10n;
    if (!await _confirm(
      l10n.integrationDelete,
      l10n.integrationDeleteConfirm(integration.displayName),
    )) {
      return;
    }
    if (!mounted) return;
    await alertOnError(
      context,
      () => externalIntegrationsService.deleteIntegration(
        communityId: widget.communityId,
        integrationId: integration.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExternalIntegration>>(
      stream: _integrations,
      builder: (context, snapshot) {
        final integrations = snapshot.data ?? const <ExternalIntegration>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 28),
            if (snapshot.hasData && integrations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.l10n.noExternalIntegrations,
                  style: context.theme.textTheme.bodyMedium,
                ),
              ),
            for (final integration in integrations)
              _IntegrationCard(
                integration: integration,
                onEdit: () => _edit(integration),
                onRotate: () => _rotate(integration),
                onDelete: () => _delete(integration),
              ),
            SizedBox(height: 12),
            ActionButton(
              type: ActionButtonType.outline,
              icon: Icon(Icons.add),
              text: context.l10n.addIntegration,
              onPressed: () => _edit(null),
            ),
          ],
        );
      },
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  final ExternalIntegration integration;
  final VoidCallback onEdit;
  final VoidCallback onRotate;
  final VoidCallback onDelete;

  const _IntegrationCard({
    required this.integration,
    required this.onEdit,
    required this.onRotate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final description = integration.description;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: IntegrationBadge(
                    integration: integration,
                    logoSize: 28,
                    style: context.theme.textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    integration.isActive
                        ? l10n.integrationActive
                        : l10n.integrationInactive,
                  ),
                ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(description, style: context.theme.textTheme.bodySmall),
            ],
            SizedBox(height: 8),
            Text(
              [
                if (integration.events
                    .contains(ExternalIntegrationEventTypes.recordingReady))
                  l10n.integrationEventRecordingReady,
                if (integration.events
                    .contains(ExternalIntegrationEventTypes.transcriptReady))
                  l10n.integrationEventTranscriptReady,
                if (integration.enabledForNewEvents)
                  l10n.integrationEnabledForNewEvents,
              ].join(' · '),
              style: context.theme.textTheme.bodySmall,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton(onPressed: onEdit, child: Text(l10n.edit)),
                TextButton(
                  onPressed: onRotate,
                  child: Text(l10n.integrationRotateSecret),
                ),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: context.theme.colorScheme.error,
                  ),
                  child: Text(l10n.integrationDelete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Add/edit form. Pops with the new signing secret when an integration was
/// created, otherwise with null.
class _IntegrationFormDialog extends StatefulWidget {
  final String communityId;
  final ExternalIntegration? integration;
  final String? webhookUrl;

  const _IntegrationFormDialog({
    required this.communityId,
    required this.integration,
    required this.webhookUrl,
  });

  @override
  State<_IntegrationFormDialog> createState() => _IntegrationFormDialogState();
}

class _IntegrationFormDialogState extends State<_IntegrationFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _logoUrl;
  late final TextEditingController _description;
  late final TextEditingController _webhookUrl;
  late final TextEditingController _referenceLabel;
  late Set<String> _events;
  late bool _enabledForNewEvents;
  late bool _isActive;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final integration = widget.integration;
    _name = TextEditingController(text: integration?.displayName ?? '');
    _logoUrl = TextEditingController(text: integration?.logoUrl ?? '');
    _description = TextEditingController(text: integration?.description ?? '');
    _webhookUrl = TextEditingController(text: widget.webhookUrl ?? '');
    _referenceLabel =
        TextEditingController(text: integration?.externalReferenceLabel ?? '');
    _events = {
      ...(integration?.events ?? ExternalIntegrationEventTypes.all),
    };
    _enabledForNewEvents = integration?.enabledForNewEvents ?? false;
    _isActive = integration?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _logoUrl.dispose();
    _description.dispose();
    _webhookUrl.dispose();
    _referenceLabel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty ||
        _webhookUrl.text.trim().isEmpty ||
        _events.isEmpty) {
      setState(() => _error = context.l10n.integrationNameRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final response = await externalIntegrationsService.upsertIntegration(
        UpsertExternalIntegrationRequest(
          communityId: widget.communityId,
          integrationId: widget.integration?.id,
          displayName: _name.text.trim(),
          logoUrl: _logoUrl.text.trim().isEmpty ? null : _logoUrl.text.trim(),
          description: _description.text.trim(),
          externalReferenceLabel: _referenceLabel.text.trim(),
          webhookUrl: _webhookUrl.text.trim(),
          events: _events.toList(),
          enabledForNewEvents: _enabledForNewEvents,
          isActive: _isActive,
        ),
      );
      if (!mounted) return;
      showRegularToast(
        context,
        context.l10n.integrationSaved,
        toastType: ToastType.success,
      );
      Navigator.pop(context, response.secret);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = errorMessageFrom(e);
      });
    }
  }

  String errorMessageFrom(Object e) {
    if (e is FirebaseFunctionsException) return e.message ?? e.code;
    return e.toString();
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, counterText: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // While saving, back and Escape must not close the dialog: the response
    // may carry the new secret, which is only shown once.
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(
          widget.integration == null
              ? l10n.addIntegration
              : l10n.editIntegration,
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field(_name, l10n.integrationDisplayName, maxLength: 80),
                _field(
                  _logoUrl,
                  l10n.integrationLogoUrl,
                  keyboardType: TextInputType.url,
                ),
                _field(
                  _description,
                  l10n.integrationDescription,
                  maxLines: 2,
                  maxLength: 500,
                ),
                _field(
                  _webhookUrl,
                  l10n.integrationWebhookUrl,
                  keyboardType: TextInputType.url,
                ),
                _field(
                  _referenceLabel,
                  l10n.integrationReferenceLabel,
                  maxLength: 60,
                ),
                Text(
                  l10n.integrationEventsToSend,
                  style: context.theme.textTheme.titleSmall,
                ),
                for (final entry in {
                  ExternalIntegrationEventTypes.recordingReady:
                      l10n.integrationEventRecordingReady,
                  ExternalIntegrationEventTypes.transcriptReady:
                      l10n.integrationEventTranscriptReady,
                }.entries)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: _events.contains(entry.key),
                    title: Text(entry.value),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _events.add(entry.key);
                      } else {
                        _events.remove(entry.key);
                      }
                    }),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _enabledForNewEvents,
                  title: Text(l10n.integrationEnabledForNewEvents),
                  onChanged: (value) =>
                      setState(() => _enabledForNewEvents = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  title: Text(l10n.integrationActive),
                  onChanged: (value) => setState(() => _isActive = value),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: TextStyle(color: context.theme.colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
