import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_discussion_dialog/pre_post_discussion_dialog_page.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/widgets_preview/colorful_meter_preview.dart';
import 'package:junto/widgets_preview/leave_regular_dialog_preview.dart';
import 'package:junto/widgets_preview/leave_suggestions_dialog_preview.dart';
import 'package:junto/widgets_preview/ui_option_selection.dart';
import 'package:junto/widgets_preview/ui_switch_tile.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/pre_post_url_params.dart';

class WidgetsPreview extends StatefulWidget {
  @override
  State<WidgetsPreview> createState() => _WidgetsPreviewState();
}

class _WidgetsPreviewState extends State<WidgetsPreview> {
  /// [LeaveRegularDialog]
  bool _leaveRegularDialogIsWithJunto = false;

  /// [LeaveSuggestionsDialog]
  bool _leaveSuggestionsDialogIsWithJunto = false;

  /// [Toast]
  ToastType _toastToastType = ToastType.neutral;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Widgets preview'),
      ),
      body: ListView(
        children: [
          _Section(
            title: 'Colorful Meter',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ColorfulMeterPreview()),
            ),
          ),
          _Section(
            title: 'Pre/Post',
            onTap: () => PrePostDiscussionDialogPage.show(
                prePostCardData: PrePostCard(
                  headline: 'Headline Goes Here',
                  message:
                      'Message goes here. Please take this survey before the event. It will only take about 5 minutes.',
                  type: PrePostCardType.preEvent,
                  prePostUrls: [
                    PrePostUrlParams(surveyUrl: 'https://google.com'),
                  ],
                ),
                discussion: Discussion(
                  id: 'discussionId',
                  topicId: 'topicId',
                  juntoId: 'juntoId',
                  collectionPath: 'discussions',
                  creatorId: 'creator',
                  status: DiscussionStatus.active,
                )),
          ),
          _Section(
            title: 'Leave regular dialog',
            attributes: [
              UiSwitchTile(
                title: 'Is with Frankly?',
                value: _leaveRegularDialogIsWithJunto,
                onChanged: (value) => setState(() => _leaveRegularDialogIsWithJunto = value),
              )
            ],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaveRegularDialogPreview(
                  junto: _leaveRegularDialogIsWithJunto ? Junto(id: '', name: '<community name>') : null,
                  onFollowTap: _leaveRegularDialogIsWithJunto ? () => Navigator.pop(context) : null,
                ),
              ),
            ),
          ),
          _Section(
            title: 'Leave suggestions dialog',
            attributes: [
              UiSwitchTile(
                title: 'Is with Frankly?',
                value: _leaveSuggestionsDialogIsWithJunto,
                onChanged: (value) => setState(() => _leaveSuggestionsDialogIsWithJunto = value),
              )
            ],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaveSuggestionsDialogPreview(
                  junto: _leaveSuggestionsDialogIsWithJunto
                      ? Junto(id: '', name: '<community name>')
                      : null,
                  onFollowTap:
                      _leaveSuggestionsDialogIsWithJunto ? () => Navigator.pop(context) : null,
                ),
              ),
            ),
          ),
          _Section(
            title: 'Toast Preview',
            attributes: [
              UiOptionSelection<ToastType>(
                name: 'Type',
                availableOptions: ToastType.values,
                currentOption: _toastToastType,
                onOptionSelected: (value) => setState(() => _toastToastType = value),
              ),
            ],
            onTap: () => showRegularToast(context, 'Some message', toastType: _toastToastType),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> attributes;
  final void Function()? onTap;

  const _Section({
    Key? key,
    required this.title,
    this.attributes = const [],
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyle.headline3,
          ),
          Divider(height: 1),
          ...attributes.toList(),
          ListTile(
            title: Text('Open Widget'),
            trailing: onTap != null ? Icon(Icons.arrow_forward_ios) : SizedBox.shrink(),
            onTap: onTap,
          ),
          Divider(height: 1),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
