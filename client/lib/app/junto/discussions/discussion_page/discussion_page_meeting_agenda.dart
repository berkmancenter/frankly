import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/breakout_room_definition/breakout_room_definition_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_stream/live_stream_instructions.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/add_more_button.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/waiting_room_widget/waiting_room_widget.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:provider/provider.dart';

class DiscussionPageMeetingAgenda extends StatefulWidget {
  const DiscussionPageMeetingAgenda({Key? key}) : super(key: key);

  @override
  _DiscussionPageMeetingAgendaState createState() => _DiscussionPageMeetingAgendaState();
}

class _DiscussionPageMeetingAgendaState extends State<DiscussionPageMeetingAgenda>
    implements DiscussionPageView {
  late final DiscussionPagePresenter _presenter;

  Widget _buildBreakoutsSection() {
    final discussionProvider = DiscussionProvider.watch(context);
    final discussion = discussionProvider.discussion;
    if (discussion.discussionType == DiscussionType.hostless ||
        discussion.breakoutRoomDefinition != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JuntoText(
              'Add breakouts',
              style: AppTextStyle.subhead.copyWith(color: AppColor.gray1),
            ),
            SizedBox(height: 10),
            BreakoutRoomDefinitionWidget(),
          ],
        ),
      );
    } else {
      return AddMoreButton(
        isWhiteBackground: true,
        label: 'Define Breakouts (Optional)',
        onPressed: () => alertOnError(context, () async {
          final updatedDiscussion = discussion.copyWith(
            breakoutRoomDefinition: discussionProvider.defaultBreakoutRoomDefinition,
          );

          await firestoreDiscussionService.updateDiscussion(
            discussion: updatedDiscussion,
            keys: [Discussion.kFieldBreakoutRoomDefinition],
          );
        }),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _presenter = DiscussionPagePresenter(context, this);
  }

  @override
  Widget build(BuildContext context) {
    final discussionProvider = DiscussionProvider.watch(context);
    final discussion = discussionProvider.discussion;
    final agendaItems = discussion.agendaItems;

    final topicProvider = Provider.of<TopicProvider>(context);

    final canEdit = context.watch<DiscussionPermissionsProvider>().canEditDiscussion;

    final allowBreakoutsDefinition = !DiscussionProvider.watch(context).discussion.isHosted ||
        discussionProvider.allowPredefineBreakoutsOnHosted;

    return JuntoUiMigration(
      child: MeetingAgendaWrapper(
        allowButtonForUserSubmittedAgenda:
            context.watch<DiscussionPermissionsProvider>().canParticipate,
        juntoId: context.watch<JuntoProvider>().juntoId,
        topic: topicProvider.topic,
        discussion: discussion,
        isLivestream: discussion.isLiveStream,
        backgroundColor: AppColor.darkerBlue,
        agendaStartsCollapsed: true,
        child: Column(
          children: [
            if (canEdit && [DiscussionType.hostless].contains(discussion.discussionType)) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    JuntoText(
                      'Waiting Room',
                      style: AppTextStyle.subhead.copyWith(color: AppColor.gray1),
                    ),
                    SizedBox(height: 10),
                    WaitingRoomWidget(discussion: discussion),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
            if (canEdit &&
                DiscussionProvider.watch(context).isLiveStream &&
                !responsiveLayoutService.isMobile(context)) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    JuntoText(
                      'Livestream',
                      style: AppTextStyle.subhead.copyWith(color: AppColor.gray1),
                    ),
                    SizedBox(height: 10),
                    LiveStreamInstructions(whiteBackground: true),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
            if (canEdit && allowBreakoutsDefinition) ...[
              _buildBreakoutsSection(),
              SizedBox(height: 20),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (agendaItems.isNotEmpty)
                  if (responsiveLayoutService.isMobile(context)) ...[
                    _buildAgendaTitle(),
                    if (canEdit)
                      Align(
                        alignment: Alignment.topRight,
                        child: _buildClearAllButton(),
                      ),
                  ] else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: _buildAgendaTitle(),
                        ),
                        if (canEdit) _buildClearAllButton(),
                      ],
                    ),
                SizedBox(height: 10),
                MeetingAgenda(
                  canUserEditAgenda:
                      context.watch<DiscussionPermissionsProvider>().canEditDiscussion,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaTitle() {
    return JuntoText(
      'Agenda',
      style: AppTextStyle.subhead.copyWith(color: AppColor.gray1),
    );
  }

  Widget _buildClearAllButton() {
    return ActionButton(
      color: Colors.transparent,
      textColor: AppColor.darkBlue,
      onPressed: () => _showClearAgendaItemsDialog(),
      text: 'Clear all',
      icon: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Icon(Icons.close, color: AppColor.darkBlue, size: 20),
      ),
      iconSide: ActionButtonIconSide.right,
      padding: EdgeInsets.zero,
    );
  }

  Future<void> _showClearAgendaItemsDialog() async {
    final delete = await ConfirmDialog(
      title: 'Clear agenda?',
      mainText:
          'Are you sure you want to remove all agenda items from the breakout rooms? You won\'t be able to undo this.',
      cancelText: 'Cancel',
      confirmText: 'Yes, clear',
      textAlign: TextAlign.start,
    ).show(context: context);

    if (delete) {
      await alertOnError(context, () => _presenter.deleteAgendaItems());
    }
  }

  @override
  void updateView() {
    setState(() {});
  }

  @override
  void showMessage(String message, {ToastType toastType = ToastType.neutral}) {
    showRegularToast(context, message, toastType: toastType);
  }
}
