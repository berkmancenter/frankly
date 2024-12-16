import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_drawer.dart';
import 'package:junto/app/junto/discussions/discussion_page/edit_discussion/edit_discussion_drawer.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/calendar_menu_button.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/circle_icon_button.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/discussion_pop_up_menu_button.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/participants_dialog.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/warning_info.dart';
import 'package:junto/app/junto/home/carousel/time_indicator.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/templates/create_topic/create_custom_topic_page.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_dialog.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/app/junto/widgets/share/share_section.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/discussion_participants_list.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_tag_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/prerequisite_topic_widget.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/periodic_builder.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/analytics/share_type.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

enum _ParticipantStatus {
  needsParticipants,
  full,
}

class DiscussionInfo extends StatefulHookWidget {
  static const Key enterConversationButtonKey = Key('enter-button');
  static const Key rsvpButtonKey = Key('rsvp-button');

  final Discussion discussion;
  final void Function() onMessagePressed;
  final DiscussionPagePresenter discussionPagePresenter;
  final Future<JoinDiscussionResults> Function({
    bool showConfirm,
    bool joinJunto,
  }) onJoinDiscussion;

  const DiscussionInfo({
    Key? key,
    required this.discussion,
    required this.onMessagePressed,
    required this.onJoinDiscussion,
    required this.discussionPagePresenter,
  }) : super(key: key);

  @override
  _DiscussionInfoState createState() => _DiscussionInfoState();
}

class _DiscussionInfoState extends State<DiscussionInfo> {
  DiscussionProvider get _discussionProvider => Provider.of<DiscussionProvider>(context);

  BehaviorSubjectWrapper<List<Featured>>? _featuredStream;

  /// Holds state for a checkbox indicating if the user should automatically join the junto when
  /// RSVPing
  bool _joinJuntoDuringRsvp = true;

  Discussion get _discussion => _discussionProvider.discussion;

  bool get _isParticipant => _discussionProvider.isParticipant;

  bool get _canModerateDiscussion =>
      Provider.of<CommunityPermissionsProvider>(context).canModerateContent;

  bool get _canEditCommunity => Provider.of<CommunityPermissionsProvider>(context).canEditCommunity;

  bool get _canEditDiscussion =>
      Provider.of<DiscussionPermissionsProvider>(context).canEditDiscussion;

  Membership get _membership => Provider.of<JuntoUserDataService>(context)
      .getMembership(Provider.of<JuntoProvider>(context).juntoId);

  bool get hasPrerequisiteTopic => widget.discussion.prerequisiteTopicId != null;

  DiscussionPagePresenter get _presenter => widget.discussionPagePresenter;

  bool get showPrerequisiteWarning =>
      hasPrerequisiteTopic &&
      !_discussionProvider.hasAttendedPrerequisite &&
      !_isParticipant &&
      !_canEditCommunity;

  bool _canShowFollowJunto() {
    final isMember = _membership.isMember;
    final doesContainRequireApprovalToJoinFlag =
        _discussionProvider.juntoProvider.settings.requireApprovalToJoin;

    return !isMember && !doesContainRequireApprovalToJoinFlag;
  }

  @override
  void dispose() {
    super.dispose();
    _featuredStream?.dispose();
  }

  _ParticipantStatus get _status {
    if (!_discussionProvider.discussion.isHosted) {
      return _ParticipantStatus.needsParticipants;
    }

    final maxParticipants = _discussion.maxParticipants ?? 0;

    if (_discussionProvider.participantCount >= maxParticipants) {
      return _ParticipantStatus.full;
    } else {
      return _ParticipantStatus.needsParticipants;
    }
  }

  Future<void> _cancelEvent() {
    return alertOnError(context, () => context.read<DiscussionPageProvider>().cancelDiscussion());
  }

  Future<void> _cancelParticipation() {
    return alertOnError(
        context,
        () => context
            .read<DiscussionProvider>()
            .cancelParticipation(participantId: userService.currentUserId!));
  }

  /// generates and downloads ics content as file on browsers
  /// see https://github.com/AnandChowdhary/calendar-link/issues/208#issuecomment-691675931
  void _downloadICSfile(String icsDataString) {
    /// write ics content into a Blob,
    final blob = html.Blob([icsDataString], 'text/plain', 'native');
    html.AnchorElement(
      href: html.Url.createObjectUrlFromBlob(blob).toString(),
    )
      ..setAttribute('download', 'invite.ics')
      ..click();
  }

  String _getShareBody() {
    var body = 'Join an event with me on Frankly!';
    final Junto? junto = Provider.of<JuntoProvider>(context).junto;
    if (_discussion.title != null && junto?.name != null) {
      body = 'Join me in a conversation about "${_discussion.title}" on ${junto?.name}!';
    }
    return body;
  }

  String _getShareUrl() {
    final domain = isDev ? 'gen-hls-bkc-7627.web.app' : 'app.frankly.org';
    final url = routerDelegate.currentConfiguration?.uri?.toString();
    final shareLink = 'https://$domain/share$url';
    return shareLink;
  }

  Future<void> _showCreateGuideFromEventDialog(JuntoProvider juntoProvider) async {
    final topic = _presenter.getCombinedTopicFromDiscussion();
    final newId = firestoreDatabase.generateNewDocId(
        collectionPath: firestoreDatabase.topicsCollection(juntoProvider.junto.id).path);
    await CreateTopicDialog.show(
      communityPermissionsProvider:
          Provider.of<CommunityPermissionsProvider>(context, listen: false),
      juntoProvider: juntoProvider,
      topic: topic.copyWith(id: newId),
      topicActionType: TopicActionType.duplicate,
    );
  }

  Future<void> _showDuplicateEventDialog() async {
    final topic = context.read<TopicProvider>().topic;
    final discussion = DiscussionProvider.read(context).discussion;
    await CreateDiscussionDialog.show(
      context,
      topic: topic,
      discussionType: discussion.discussionType,
      discussionTemplate: discussion,
    );
  }

  Future<void> _showRefreshGuideDialog() async {
    await ConfirmDialog(
      title: 'Are you sure you want to refresh the guide?',
      subText: 'Your event will be reset to the original template. '
          'The list of attendees will not be affected.',
      confirmText: 'Yes, refresh',
      onConfirm: (context) async {
        await alertOnError(context, () async {
          await _presenter.refreshDiscussion();
          Navigator.pop(context);
        });
      },
      cancelText: 'No, nevermind',
    ).show();
  }

  Future<void> _downloadRegistrationData() async {
    final discussionProvider = DiscussionProvider.read(context);
    await alertOnError(context, () async {
      // Open new stream to ensure we always get data (even in the case of 'livestream' event type)
      final participantsWrapper = firestoreDiscussionService.discussionParticipantsStream(
        juntoId: widget.discussion.juntoId,
        topicId: widget.discussion.topicId,
        discussionId: widget.discussion.id,
      );
      final participants = await participantsWrapper.stream
          .map((s) => s.where((p) => p.status == ParticipantStatus.active))
          .first;
      final List<String> userIds = participants.map((p) => p.id).toList();
      await participantsWrapper.dispose();

      final members = await _presenter.getMembersData(userIds);
      if (members.isNotEmpty) {
        await discussionProvider.generateRegistrationDataCsvFile(
          registrationData: members,
          discussionId: discussionProvider.discussionId,
        );
      } else {
        showRegularToast(context, 'No members data', toastType: ToastType.neutral);
      }
    });
  }

  Future<void> _downloadChatsAndSuggestions() async {
    final discussionProvider = DiscussionProvider.read(context);
    await alertOnError(context, () async {
      final response = await _presenter.getChatsAndSuggestions();
      final chatsSuggesions = response.chatsSuggestionsList ?? [];
      if (chatsSuggesions.isNotEmpty) {
        await discussionProvider.generateChatAndSugguestionsDataCsv(
          response: response,
          discussionId: discussionProvider.discussionId,
        );
      } else {
        showRegularToast(context, 'No chats or suggestions data', toastType: ToastType.neutral);
      }
    });
  }

  Widget _buildOptionsIcon() {
    final isMobile = responsiveLayoutService.isMobile(context);

    return DiscussionPopUpMenuButton(
      discussion: _discussionProvider.discussion,
      onSelected: (value) {
        switch (value) {
          case DiscussionPopUpMenuSelection.refreshGuide:
            _showRefreshGuideDialog();
            break;
          case DiscussionPopUpMenuSelection.createGuideFromEvent:
            _showCreateGuideFromEventDialog(Provider.of<JuntoProvider>(context, listen: false));
            break;
          case DiscussionPopUpMenuSelection.duplicateEvent:
            _showDuplicateEventDialog();
            break;
          case DiscussionPopUpMenuSelection.cancelEvent:
            _cancelEvent();
            break;
          case DiscussionPopUpMenuSelection.downloadRegistrationData:
            _downloadRegistrationData();
            break;
          case DiscussionPopUpMenuSelection.downloadChatsAndSuggestions:
            _downloadChatsAndSuggestions();
            break;
        }
      },
      isMobile: isMobile,
    );
  }

  Widget _buildEditEvent() {
    return CircleIconButton(
      onPressed: () => Dialogs.showAppDrawer(
        context,
        AppDrawerSide.right,
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: context.read<DiscussionPageProvider>()),
            ChangeNotifierProvider.value(value: context.read<DiscussionProvider>()),
            ChangeNotifierProvider.value(value: context.read<CommunityPermissionsProvider>()),
            ChangeNotifierProvider.value(value: context.read<JuntoProvider>()),
          ],
          child: EditDiscussionDrawer(),
        ),
      ),
      toolTipText: 'Edit event',
      icon: SizedBox(
        width: 20,
        height: 20,
        child: Icon(
          Icons.edit_outlined,
          size: 20,
          color: AppColor.darkerBlue,
        ),
      ),
    );
  }

  Widget _buildSettingIcon() {
    return CircleIconButton(
      onPressed: () => Dialogs.showAppDrawer(
        context,
        AppDrawerSide.right,
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: context.read<JuntoProvider>()),
            ChangeNotifierProvider.value(value: context.read<DiscussionProvider>()),
          ],
          child: DiscussionSettingsDrawer(
            discussionSettingsDrawerType: DiscussionSettingsDrawerType.discussion,
          ),
        ),
      ),
      toolTipText: 'Event Settings',
      icon: SizedBox(
        width: 20,
        height: 20,
        child: Icon(
          CupertinoIcons.gear_alt,
          size: 20,
          color: AppColor.darkerBlue,
        ),
      ),
    );
  }

  ActionButton _buildEnterConversation(DateTime scheduled) {
    const kConversationOpenText = 'Enter Event';
    final now = clockService.now();
    final daysDifference = differenceInDays(scheduled, now);
    final difference = scheduled.difference(now);
    String text;
    final _externalPlatform =
        _discussion.externalPlatform ?? PlatformItem(platformKey: PlatformKey.junto);
    final isPlatformSelectionEnabled =
        JuntoProvider.watch(context).settings.enablePlatformSelection;
    if (daysDifference > 1) {
      text = 'Starts in $daysDifference Days';
    } else if (daysDifference == 1) {
      text = 'Starts Tomorrow';
    } else if (daysDifference == 0 && difference.inMinutes > 9) {
      text = 'Starts in ${durationString(difference)}';
    } else if (daysDifference < 0) {
      text = 'Event Ended';
    } else {
      text = kConversationOpenText;
    }

    final isConversationOpen = text == kConversationOpenText;

    return ActionButton(
      height: 64,
      type: isConversationOpen ? ActionButtonType.flat : ActionButtonType.outline,
      color: isConversationOpen ? Theme.of(context).colorScheme.primary : null,
      textColor: isConversationOpen
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.primary,
      key: DiscussionInfo.enterConversationButtonKey,
      expand: true,
      onPressed: () => alertOnError(context, () async {
        final discussionPageProvider = context.read<DiscussionPageProvider>();
        JoinDiscussionResults? joinResults;
        if (!DiscussionProvider.read(context).isParticipant) {
          joinResults = await widget.onJoinDiscussion(showConfirm: false);
          if (!joinResults.isJoined) return;
        }
        unawaited(firebaseAnalytics.logEvent(name: 'discussion_enter'));
        await alertOnError(context, () {
          if (_externalPlatform.platformKey == PlatformKey.junto || !isPlatformSelectionEnabled) {
            return discussionPageProvider.enterMeeting(
              surveyQuestions: joinResults?.surveyQuestions,
            );
          } else {
            return launch(_externalPlatform.url ?? '');
          }
        });

        final juntoId = widget.discussion.juntoId;
        final discussionId = widget.discussion.id;
        final guideId = widget.discussion.topicId;
        final isHost = (widget.discussion.discussionType != DiscussionType.hostless) &&
            widget.discussion.creatorId == userService.currentUserId;
        analytics.logEvent(AnalyticsEnterDiscussionEvent(
          juntoId: juntoId,
          discussionId: discussionId,
          asHost: isHost,
          guideId: guideId,
        ));
      }),
      text: text,
    );
  }

  Widget _buildJoinDiscussionButton() {
    final startTime = widget.discussion.scheduledTime ?? clockService.now();
    final isLocked = widget.discussion.isLocked;

    final localDiscussionProvider = _discussionProvider;
    final isBanned = localDiscussionProvider.isBanned;
    final canShowFollowJunto = _canShowFollowJunto();

    final showJoinButton = !isBanned &&
        context.read<DiscussionPermissionsProvider>().canJoinEvent &&
        _status != _ParticipantStatus.full;

    final showEnterConversationButton = _isParticipant ||
        (showJoinButton && clockService.now().isAfter(startTime.subtract(Duration(minutes: 15))));
    if (showPrerequisiteWarning) {
      return WarningInfo(
        icon: CircleAvatar(
          radius: 12,
          backgroundColor: AppColor.redLightMode,
          child: Icon(Icons.school_outlined, size: 20, color: AppColor.white),
        ),
        title: 'Prerequisite Required',
      );
    } else if (isBanned) {
      return WarningInfo(
        icon: Icon(Icons.info_outline, size: 20, color: AppColor.redLightMode),
        title: 'Banned',
        message: 'You were removed from this event and cannot rejoin.',
      );
    } else if (isLocked) {
      return WarningInfo(
        icon: Icon(Icons.info_outline, size: 20, color: AppColor.redLightMode),
        title: 'Locked',
        message: 'This event is locked',
      );
    } else if (showEnterConversationButton) {
      return PeriodicBuilder(
        period: Duration(milliseconds: 1000),
        builder: (_) => _buildEnterConversation(startTime),
      );
    } else if (_status == _ParticipantStatus.full) {
      return ActionButton(
        height: 64,
        text: 'FULL',
        expand: true,
        color: Colors.blueGrey,
      );
    } else if (showJoinButton) {
      return Column(
        children: [
          ActionButton(
            key: DiscussionInfo.rsvpButtonKey,
            height: 64,
            onPressed: () => alertOnError(context, () async {
              await widget.onJoinDiscussion(
                joinJunto: canShowFollowJunto ? _joinJuntoDuringRsvp : false,
              );
            }),
            expand: true,
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).colorScheme.secondary,
            text: 'RSVP',
          ),
          if (canShowFollowJunto) ...[
            SizedBox(height: 10),
            _buildFollowJuntoCheckbox(),
          ],
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildAddToCalendar() {
    final discussion = context.read<DiscussionProvider>().discussion;

    return JuntoStreamBuilder<GetJuntoCalendarLinkResponse>(
      entryFrom: 'DiscussionInfo._buildAddToCalendar',
      showLoading: false,
      stream: cloudFunctionsService
          .getJuntoCalendarLink(GetJuntoCalendarLinkRequest(discussionPath: discussion.fullPath))
          .asStream(),
      builder: (context, snapshot) {
        if (snapshot == null) return SizedBox.shrink();
        return CalendarMenuButton(
          onSelected: (selection) {
            switch (selection) {
              case CalendarMenuSelection.google:
                launch(snapshot.googleCalendarLink);
                break;
              case CalendarMenuSelection.office365:
                launch(snapshot.office365CalendarLink);
                break;
              case CalendarMenuSelection.outlook:
                launch(snapshot.outlookCalendarLink);
                break;
              case CalendarMenuSelection.ical:
                _downloadICSfile(snapshot.icsLink);
            }
          },
        );
      },
    );
  }

  Widget _buildCancelDiscussionButton() {
    return ActionButton(
      onPressed: _cancelEvent,
      type: ActionButtonType.outline,
      color: AppColor.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.close,
            size: 20,
            color: AppColor.gray3,
          ),
          SizedBox(width: 10),
          Flexible(
            child: JuntoText(
              'Cancel event',
              style: AppTextStyle.body.copyWith(color: AppColor.gray3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelParticipationButton() {
    return ActionButton(
      onPressed: _cancelParticipation,
      type: ActionButtonType.outline,
      color: AppColor.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.close,
            size: 20,
            color: AppColor.gray3,
          ),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'Cancel',
              style: AppTextStyle.body.copyWith(color: AppColor.gray3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionVisibility() {
    final isPublic = _discussion.isPublic;
    final docPath =
        '${_discussionProvider.discussion.collectionPath}/${_discussionProvider.discussion.id}';
    return JuntoStreamBuilder<List<Featured>>(
      entryFrom: '_DiscussionInfoState._buildVisibilityText',
      stream: _featuredStream ??=
          firestoreDatabase.getJuntoFeaturedItems(_discussionProvider.juntoId),
      showLoading: false,
      builder: (_, featuredItems) {
        final String? text;
        final AppAsset? appAsset;

        if (isPublic) {
          if (_canEditDiscussion) {
            text =
                'Public${featuredItems!.any((f) => f.documentPath == docPath) && _canModerateDiscussion ? ', Featured' : ''}';
            appAsset = AppAsset.kGlobePng;
          } else {
            text = null;
            appAsset = null;
          }
        } else {
          text = 'Private';
          appAsset = AppAsset.kLockPng;
        }

        // Do not show anything if text is null. Text will be null if user is not admin and
        // the discussion is public
        if (text == null || appAsset == null) {
          return SizedBox.shrink();
        }

        return Row(
          children: [
            Tooltip(
              message: isPublic ? 'Public' : 'Private',
              child: JuntoImage(null, asset: appAsset, width: 20, height: 20),
            ),
            SizedBox(width: 6),
            JuntoText(text, style: AppTextStyle.body.copyWith(color: AppColor.gray3)),
            SizedBox(width: 20),
          ],
        );
      },
    );
  }

  Widget _buildFollowJuntoCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          activeColor: AppColor.darkBlue,
          checkColor: AppColor.brightGreen,
          value: _joinJuntoDuringRsvp,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _joinJuntoDuringRsvp = value;
              });
            }
          },
        ),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            'Follow ${Provider.of<JuntoProvider>(context).junto.name} for access to all events and resources.',
            style: AppTextStyle.bodyMedium,
          ),
        )
      ],
    );
  }

  Widget _buildShareSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: ShareSection(
        url: _getShareUrl(),
        body: _getShareBody(),
        subject: 'Join my event on Frankly!',
        iconColor: Theme.of(context).colorScheme.primary,
        iconBackgroundColor: AppColor.white,
        size: 40,
        iconSize: 20,
        wrapIcons: false,
        shareCallback: (ShareType type) {
          final juntoId = widget.discussion.juntoId;
          final discussionId = widget.discussion.id;
          final guideId = widget.discussion.topicId;
          analytics.logEvent(AnalyticsPressShareEventEvent(
            juntoId: juntoId,
            discussionId: discussionId,
            shareType: type,
            guideId: guideId,
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discussionPageProvider = context.watch<DiscussionPageProvider>();
    final discussionProvider = context.watch<DiscussionProvider>();
    final canEditCommunity = Provider.of<CommunityPermissionsProvider>(context).canEditCommunity;
    final canCancelParticipation =
        Provider.of<DiscussionPermissionsProvider>(context).canCancelParticipation;
    final canAccessParticipantListDetails =
        discussionProvider.discussion.isHosted || canEditCommunity;
    final isMobile = responsiveLayoutService.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: isMobile ? null : BorderRadius.circular(20),
        boxShadow: isMobile
            ? null
            : [
                BoxShadow(
                  color: AppColor.black.withOpacity(0.25),
                  blurRadius: 34,
                  offset: Offset(0, 14),
                ),
              ],
      ),
      child: JuntoUiMigration(
        whiteBackground: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              // Specific padding for sides. at 20 iPhone X (375 width) overflows with
              // `Add to calendar` button.
              margin: EdgeInsets.only(left: 19, right: 19, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VerticalTimeAndDateIndicator(
                        shadow: false,
                        padding: EdgeInsets.only(left: isMobile ? 0 : 16, right: 16),
                        time: DateTime.fromMillisecondsSinceEpoch(
                          (discussionProvider.discussion.scheduledTime?.millisecondsSinceEpoch ??
                              0),
                        ),
                      ),
                      SizedBox(
                        height: isMobile ? 90 : 100,
                        width: isMobile ? 90 : 100,
                        child: JuntoStreamBuilder<Topic>(
                          entryFrom: '_DiscussionInfoState.build',
                          stream: Provider.of<TopicProvider>(context).topicFuture.asStream(),
                          builder: (_, topic) => JuntoImage(
                            discussionProvider.discussion.image ?? topic?.image,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Spacer(),
                      if (_canEditDiscussion)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildOptionsIcon(),
                            SizedBox(width: 5),
                            _buildSettingIcon(),
                            SizedBox(width: 5),
                            _buildEditEvent()
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 0 : 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildDiscussionVisibility(),
                      _buildDiscussionTypeName(),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: JuntoText(
                          _discussion.title ?? '',
                          maxLines: 3,
                          style: AppTextStyle.headline2Light.copyWith(
                            color: Theme.of(context).primaryColor,
                            decoration: _discussion.status == DiscussionStatus.canceled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (discussionPageProvider.tags.isNotEmpty) ...[
                    Wrap(
                      children: [
                        for (var tag in discussionPageProvider.tags)
                          JuntoTagBuilder(
                            tagDefinitionId: tag.definitionId,
                            builder: (_, isLoading, definition) {
                              if (definition == null) return const SizedBox.shrink();
                              return Text(
                                '#${definition.title} ',
                                style: AppTextStyle.body.copyWith(color: AppColor.gray3),
                              );
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: JuntoInkWell(
                              onTap: canAccessParticipantListDetails
                                  ? () => ParticipantsDialog(
                                        discussionProvider: DiscussionProvider.read(context),
                                        discussionPermissions:
                                            context.read<DiscussionPermissionsProvider>(),
                                      ).show(context)
                                  : null,
                              child: DiscussionPageParticipantsList(_discussion),
                            ),
                          ),
                        ),
                        if (_canEditDiscussion)
                          CircleIconButton(
                            onPressed: widget.onMessagePressed,
                            toolTipText: 'Message',
                            icon: SizedBox(
                              width: isMobile ? 30 : 20,
                              height: isMobile ? 30 : 20,
                              child: Icon(CupertinoIcons.paperplane),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildJoinDiscussionButton(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (canCancelParticipation || _canEditDiscussion)
                        Expanded(child: _buildAddToCalendar()),
                      if (canCancelParticipation) ...[
                        Expanded(child: _buildCancelParticipationButton()),
                      ] else if (context
                              .watch<DiscussionPermissionsProvider>()
                              .canCancelDiscussion &&
                          _discussion.status != DiscussionStatus.canceled) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildCancelDiscussionButton(),
                        ),
                      ],
                    ],
                  ),
                  if (showPrerequisiteWarning) ...[
                    SizedBox(height: 10),
                    PrerequisiteTopicWidget(
                      juntoId: widget.discussion.juntoId,
                      prerequisiteTopicId: widget.discussion.prerequisiteTopicId!,
                    ),
                  ]
                ],
              ),
            ),
            if (!showPrerequisiteWarning) _buildShareSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionTypeName() {
    final String? type;
    final AppAsset? appAsset;
    switch (_discussionProvider.discussion.discussionType) {
      case DiscussionType.hosted:
        type = null;
        appAsset = null;
        break;
      case DiscussionType.hostless:
        type = 'Hostless';
        appAsset = AppAsset.kHostlessPng;
        break;
      case DiscussionType.livestream:
        type = 'Livestream';
        appAsset = AppAsset.kPlayScreenPng;
        break;
    }

    if (type == null || appAsset == null) {
      return SizedBox.shrink();
    }

    return Row(
      children: [
        JuntoImage(null, asset: appAsset, width: 20, height: 20),
        SizedBox(width: 6),
        Text(type, style: AppTextStyle.body.copyWith(color: AppColor.gray3)),
      ],
    );
  }
}
