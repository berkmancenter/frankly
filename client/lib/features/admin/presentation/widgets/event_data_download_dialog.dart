import 'dart:convert';

import 'package:client/config/environment.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/events/event.dart';
import 'package:flutter/material.dart';

class EventDataDownloadDialog extends StatefulWidget {
  const EventDataDownloadDialog({
    Key? key,
    required this.event,
    required this.participants,
    required this.hasRecording,
    required this.recordingParts,
    required this.recordingNotifier,
    required this.eventInPast,
  }) : super(key: key);

  final Event event;
  final Iterable<Participant> participants;
  final bool hasRecording;
  final Map<String, int?> recordingParts;
  final ValueNotifier<int?>? recordingNotifier;
  final bool eventInPast;

  @override
  State<EventDataDownloadDialog> createState() =>
      _EventDataDownloadDialogState();
}

class _EventDataDownloadDialogState extends State<EventDataDownloadDialog> {
  late bool recordingSelected;
  late bool registrantListSelected;
  bool chatDataSelected = false;
  bool pollsSuggestionsDataSelected = false;
  bool recordingAutoChecked = false;

  Future<void> downloadAllRecordings(Event event) async {
    final errorMsg = context.l10n.errorOccurred;
    final preparingMsg = context.l10n.recordingPreparing;
    await alertOnError(context, () async {
      final idToken = await userService.firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) throw Exception(errorMsg);
      final response = await http.post(
        Uri.parse('${Environment.functionsUrlPrefix}/downloadRecording'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'eventPath': event.fullPath}),
      );
      if (response.statusCode != 200) {
        throw Exception(errorMsg);
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rawList = body['recordings'];
      if (rawList is! List || rawList.isEmpty) {
        throw Exception(preparingMsg);
      }
      final urls = rawList
          .whereType<Map<String, dynamic>>()
          .map((r) => r['url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
      for (int i = 0; i < urls.length; i++) {
        final anchor = html.AnchorElement(href: urls[i])..target = '_blank';
        html.document.body!.append(anchor);
        anchor.click();
        anchor.remove();
        if (i < urls.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
      setState(() => widget.recordingParts[event.id] = urls.length);
      widget.recordingNotifier?.value = urls.length;
    });
  }

  @override
  void initState() {
    super.initState();
    final recordingParts = widget.recordingNotifier.value ?? 0;
    recordingSelected = widget.showRecording && recordingParts > 0;
    recordingAutoChecked = recordingSelected;
    registrantListSelected = widget.showRegistrant;
  }

  String _recordingAnnotation(BuildContext context, int? parts) {
    if (parts == null) return ' ${context.l10n.recordingStatusChecking}';
    if (parts == 0) return ' ${context.l10n.recordingStatusPreparing}';
    if (parts == -1) return ' ${context.l10n.recordingStatusFailed}';
    return ' ${context.l10n.recordingStatusParts(parts)}';
  }

  Future<void> _handleDownload() async {
    try {
      if (widget.showRecording && recordingSelected) {
        await widget.onDownloadRecordings(widget.event);
      }
      if (widget.showRegistrant && registrantListSelected) {
        await widget.onDownloadRegistrants(widget.event, widget.participants);
      }
      if (chatDataSelected) {
        await widget.onDownloadChatData(widget.event);
      }
      if (pollsSuggestionsDataSelected) {
        await widget.onDownloadPollsSuggestions(widget.event);
      }
    } catch (e) {
      if (mounted) {
        showRegularToast(
          context,
          'Error: ${e.toString()}',
          toastType: ToastType.failed,
        );
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  bool _isDownloadEnabled(int? recordingParts) {
    final recordingReady = widget.showRecording && (recordingParts ?? 0) > 0;
    return (widget.showRecording && recordingSelected && recordingReady) ||
        (widget.showRegistrant && registrantListSelected) ||
        chatDataSelected ||
        pollsSuggestionsDataSelected;
  }

  Widget _buildDialogContent(int? recordingParts) {
    return AlertDialog(
      title: Text(context.l10n.selectData),
      backgroundColor: context.theme.colorScheme.surfaceContainerHighest,
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      content: Material(
        color: context.theme.colorScheme.surfaceContainer,
        child: SingleChildScrollView(
          child: ListBody(
            children: [
              if (widget.showRecording)
                CheckboxListTile(
                  value: recordingSelected,
                  enabled: recordingParts != null && recordingParts != 0,
                  onChanged: (value) => setState(
                    () => recordingSelected = value ?? false,
                  ),
                  title: Text(
                    '${context.l10n.recording}${_recordingAnnotation(context, recordingParts)}',
                  ),
                ),
              if (widget.showRegistrant)
                CheckboxListTile(
                  value: registrantListSelected,
                  onChanged: (value) => setState(
                    () => registrantListSelected = value ?? false,
                  ),
                  title: Text(context.l10n.registrationDataDownload),
                ),
              CheckboxListTile(
                value: chatDataSelected,
                onChanged: (value) => setState(
                  () => chatDataSelected = value ?? false,
                ),
                // TODO: L10n
                title: const Text('Chat Data'),
              ),
              CheckboxListTile(
                value: pollsSuggestionsDataSelected,
                onChanged: (value) => setState(
                  () => pollsSuggestionsDataSelected = value ?? false,
                ),
                // TODO: L10n
                title: const Text('Polls & Suggestions Data'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed:
              _isDownloadEnabled(recordingParts) ? _handleDownload : null,
          child: Text(context.l10n.download),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showRecording) {
      final notifier = widget.recordingNotifier ??
          ValueNotifier(widget.recordingParts[widget.event.id]);
      return ValueListenableBuilder<int?>(
        valueListenable: notifier,
        builder: (context, recordingParts, _) {
          // Auto-check recording when it becomes ready
          if ((recordingParts ?? 0) > 0 && !recordingAutoChecked) {
            recordingAutoChecked = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => recordingSelected = true);
              }
            });
          }
          return _buildDialogContent(recordingParts);
        },
      );
    }
    return _buildDialogContent(null);
  }
}
