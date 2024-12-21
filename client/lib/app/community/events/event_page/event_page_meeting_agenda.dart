import 'package:flutter/material.dart';
import 'package:client/app/community/events/event_page/breakout_room_definition/breakout_room_definition_widget.dart';
import 'package:client/app/community/events/event_page/event_page_contract.dart';
import 'package:client/app/community/events/event_page/event_page_presenter.dart';
import 'package:client/app/community/events/event_page/event_permissions_provider.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/events/event_page/live_stream/live_stream_instructions.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/meeting_agenda.dart';
import 'package:client/app/community/events/event_page/template_provider.dart';
import 'package:client/app/community/events/event_page/widgets/add_more_button.dart';
import 'package:client/app/community/events/event_page/widgets/waiting_room_widget/waiting_room_widget.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/action_button.dart';
import 'package:client/common_widgets/confirm_dialog.dart';
import 'package:client/common_widgets/ui_migration.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';

class EventPageMeetingAgenda extends StatefulWidget {
  const EventPageMeetingAgenda({Key? key}) : super(key: key);

  @override
  _EventPageMeetingAgendaState createState() => _EventPageMeetingAgendaState();
}

class _EventPageMeetingAgendaState extends State<EventPageMeetingAgenda>
    implements EventPageView {
  late final EventPagePresenter _presenter;

  Widget _buildBreakoutsSection() {
    final eventProvider = EventProvider.watch(context);
    final event = eventProvider.event;
    if (event.eventType == EventType.hostless ||
        event.breakoutRoomDefinition != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeightConstrainedText(
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
          final updatedEvent = event.copyWith(
            breakoutRoomDefinition: eventProvider.defaultBreakoutRoomDefinition,
          );

          await firestoreEventService.updateEvent(
            event: updatedEvent,
            keys: [Event.kFieldBreakoutRoomDefinition],
          );
        }),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _presenter = EventPagePresenter(context, this);
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = EventProvider.watch(context);
    final event = eventProvider.event;
    final agendaItems = event.agendaItems;

    final templateProvider = Provider.of<TemplateProvider>(context);

    final canEdit = context.watch<EventPermissionsProvider>().canEditEvent;

    final allowBreakoutsDefinition =
        !EventProvider.watch(context).event.isHosted ||
            eventProvider.allowPredefineBreakoutsOnHosted;

    return UIMigration(
      child: MeetingAgendaWrapper(
        allowButtonForUserSubmittedAgenda:
            context.watch<EventPermissionsProvider>().canParticipate,
        communityId: context.watch<CommunityProvider>().communityId,
        template: templateProvider.template,
        event: event,
        isLivestream: event.isLiveStream,
        backgroundColor: AppColor.darkerBlue,
        agendaStartsCollapsed: true,
        child: Column(
          children: [
            if (canEdit && [EventType.hostless].contains(event.eventType)) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeightConstrainedText(
                      'Waiting Room',
                      style:
                          AppTextStyle.subhead.copyWith(color: AppColor.gray1),
                    ),
                    SizedBox(height: 10),
                    WaitingRoomWidget(event: event),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
            if (canEdit &&
                EventProvider.watch(context).isLiveStream &&
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
                    HeightConstrainedText(
                      'Livestream',
                      style:
                          AppTextStyle.subhead.copyWith(color: AppColor.gray1),
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
                      context.watch<EventPermissionsProvider>().canEditEvent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaTitle() {
    return HeightConstrainedText(
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
