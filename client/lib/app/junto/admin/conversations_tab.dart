import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:junto/app/junto/admin/members_tab.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/empty_page_content.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/cloud_functions_service.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:universal_html/html.dart' as html;

class ConversationsTab extends StatefulWidget {
  @override
  _ConversationsTabState createState() => _ConversationsTabState();
}

class _ConversationsTabState extends State<ConversationsTab> {
  late BehaviorSubjectWrapper<List<Discussion>> _allDiscussions;

  var _numToShow = 10;

  @override
  void initState() {
    super.initState();

    _allDiscussions = firestoreDiscussionService.juntoDiscussions(
      juntoId: JuntoProvider.read(context).juntoId,
    );
  }

  @override
  void dispose() {
    _allDiscussions.dispose();
    super.dispose();
  }

  Widget _buildRowEntry({double? width, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      width: width,
      child: child,
    );
  }

  Widget _buildDiscussionHeaders({required bool showDetails}) {
    return Row(
      children: [
        _buildRowEntry(
          width: 200,
          child: Text(
            'Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _buildRowEntry(
          width: 320,
          child: Text(
            'Title',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        if (showDetails)
          _buildRowEntry(
            width: 70,
            child: Text(
              'Visibility',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (showDetails)
          _buildRowEntry(
            width: 80,
            child: Text(
              'Live?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (showDetails)
          _buildRowEntry(
            width: 100,
            child: Text(
              'Num Participants',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        _buildRowEntry(
          width: 170,
          child: Text(
            'Recordings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingSection(Discussion discussion) {
    if (!(discussion.discussionSettings?.alwaysRecord ?? false)) {
      return Text('');
    } else {
      return ActionButton(
        type: ActionButtonType.outline,
        loadingHeight: 16,
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        textColor: Theme.of(context).primaryColor,
        onPressed: () => alertOnError(
          context,
          () async {
            final origin = FirebaseFunctions.instance.httpsCallable('temp').delegate.origin ?? '';

            final idToken = await userService.firebaseAuth.currentUser?.getIdToken();
            final projectId = isDev ? 'gen-hls-bkc-7627' : 'asml-deliberations';
            var downloadTriggerUrl =
                'https://us-central1-$projectId.cloudfunctions.net/downloadRecording';
            if (CloudFunctionsService.usingEmulator) {
              downloadTriggerUrl = '$origin/$projectId/us-central1/downloadRecording';
            }
            final response = await http.post(
              Uri.parse(downloadTriggerUrl),
              headers: {'Authorization': 'Bearer $idToken'},
              body: {
                'discussionPath': discussion.fullPath,
              },
            );

            final content = response.bodyBytes;

            final blob = html.Blob([content]);

            final blobUrl = html.Url.createObjectUrlFromBlob(blob);

            final anchor = html.AnchorElement(href: blobUrl)
              ..setAttribute("download", "recording.zip");
            anchor.click();

            html.Url.revokeObjectUrl(blobUrl);
          },
        ),
        sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.right,
        text: 'Download',
      );
    }
  }

  Widget _buildDiscussionRow(
      {required int index, required Discussion discussion, required bool showDetails}) {
    final timeFormat = DateFormat('MMM d yyyy, h:mma');
    final timezone = getTimezoneAbbreviation(discussion.scheduledTime!);
    final time = timeFormat.format(discussion.scheduledTime ?? clockService.now());

    return Container(
      color: index.isEven ? blueBackground : Colors.white70,
      child: Row(
        children: [
          _buildRowEntry(
            width: 200,
            child: GestureDetector(
              onTap: () => routerDelegate.beamTo(
                  JuntoPageRoutes(juntoDisplayId: JuntoProvider.read(context).displayId)
                      .discussionPage(
                topicId: discussion.topicId,
                discussionId: discussion.id,
              )),
              child: JuntoText(
                '$time $timezone',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          _buildRowEntry(
            width: 320,
            child: JuntoText(discussion.title ?? discussion.id),
          ),
          if (showDetails)
            _buildRowEntry(
              width: 70,
              child: JuntoText(discussion.isPublic == true ? 'Public' : 'Private'),
            ),
          _buildRowEntry(
            width: 170,
            child: _buildRecordingSection(discussion),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionsList({required List<Discussion> discussions, required bool showDetails}) {
    return JuntoListView(
      children: [
        for (int i = 0; i < discussions.length; i++)
          FittedBox(
            fit: BoxFit.fitWidth,
            child: _buildDiscussionRow(
              index: i,
              discussion: discussions[i],
              showDetails: showDetails,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showDetails = !responsiveLayoutService.isMobile(context);
    return JuntoStreamBuilder<List<Discussion>>(
      stream: _allDiscussions.stream,
      entryFrom: '_ConversationsTabState.build',
      builder: (_, discussions) {
        if (discussions == null || discussions.isEmpty) {
          return EmptyPageContent(
            type: EmptyPageType.events,
            showContainer: false,
          );
        }

        return JuntoListView(
          children: [
            FittedBox(
              fit: BoxFit.fitWidth,
              child: _buildDiscussionHeaders(showDetails: showDetails),
            ),
            _buildDiscussionsList(
              discussions: discussions.take(_numToShow).toList(),
              showDetails: showDetails,
            ),
            if (_numToShow < discussions.length)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: ActionButton(
                  onPressed: () => setState(() => _numToShow += 10),
                  text: 'View more',
                ),
              ),
          ],
        );
      },
    );
  }
}
