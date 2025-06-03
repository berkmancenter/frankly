import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/buttons/app_clickable_widget.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'meeting_guide_card_item_user_suggestions_contract.dart';
import '../../data/models/meeting_guide_card_item_user_suggestions_model.dart';
import '../meeting_guide_card_item_user_suggestions_presenter.dart';

class MeetingGuideCardItemUserSuggestions extends StatefulWidget {
  const MeetingGuideCardItemUserSuggestions({Key? key}) : super(key: key);

  @override
  _MeetingGuideCardItemUserSuggestionsState createState() =>
      _MeetingGuideCardItemUserSuggestionsState();
}

class _MeetingGuideCardItemUserSuggestionsState
    extends State<MeetingGuideCardItemUserSuggestions>
    implements MeetingGuideCardItemUserSuggestionsView {
  final _textEditingController = TextEditingController();
  late final MeetingGuideCardItemUserSuggestionsModel _model;
  late final MeetingGuideCardItemUserSuggestionsPresenter _presenter;

  final _submitNotifier = SubmitNotifier();

  @override
  void initState() {
    super.initState();

    _model = MeetingGuideCardItemUserSuggestionsModel();
    _presenter =
        MeetingGuideCardItemUserSuggestionsPresenter(context, this, _model);
  }

  @override
  void updateView() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    context.watch<EventProvider>();
    final isMobile = _presenter.isMobile(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: isMobile
              ? const EdgeInsets.symmetric(vertical: 10)
              : const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: CustomStreamBuilder<List<ParticipantAgendaItemDetails>>(
                  entryFrom:
                      '_MeetingGuideCardItemUserSuggestionsCloudState.build',
                  stream: _presenter.getParticipantAgendaItemDetailsStream(),
                  builder: (context, participantAgendaItemDetails) {
                    final agendaItemsWithSuggestions = _presenter
                        .getFormattedDetails(participantAgendaItemDetails);

                    if (agendaItemsWithSuggestions.isEmpty) {
                      return SingleChildScrollView(
                        child: _buildEmptySuggestions(),
                      );
                    } else {
                      return ListView.builder(
                        controller: ScrollController(),
                        itemCount: agendaItemsWithSuggestions.length,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final agendaItemDetails =
                              agendaItemsWithSuggestions[index];

                          return _buildSuggestionCard(agendaItemDetails);
                        },
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              _buildInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: _textEditingController,
            padding: EdgeInsets.zero,
            onEditingComplete: () => _submitNotifier.submit(),
            textStyle: AppTextStyle.body
                .copyWith(color: context.theme.colorScheme.primary),
            hintStyle: AppTextStyle.body
                .copyWith(color: context.theme.colorScheme.onPrimaryContainer),
            maxLines: 1,
            borderRadius: 40,
            borderColor: context.theme.colorScheme.onPrimaryContainer,
            fillColor: context.theme.colorScheme.surfaceContainerLowest,
            hintText: context.l10n.suggest,
          ),
        ),
        SizedBox(width: 10),
        ActionButton(
          controller: _submitNotifier,
          shape: CircleBorder(),
          minWidth: 48,
          padding: const EdgeInsets.all(14),
          onPressed: () => alertOnError(context, () async {
            await _presenter.addSuggestion(_textEditingController.text);
            _textEditingController.clear();
          }),
          color: context.theme.colorScheme.primary,
          child: ProxiedImage(
            null,
            asset: AppAsset.kAirplaneWhite,
            width: 20,
            height: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySuggestions() {
    return EmptyPageContent(
      type: EmptyPageType.suggestions,
      titleText: 'Suggestions will show up here',
      subtitleText:
          'You can upvote and downvote suggested agenda items to discuss',
    );
  }

  @override
  void showMessage(String message, {ToastType toastType = ToastType.neutral}) {
    showRegularToast(context, message, toastType: toastType);
  }

  Widget _buildSuggestionCard(
    ParticipantAgendaItemDetails participantAgendaItemDetails,
  ) {
    final isMobile = _presenter.isMobile(context);
    final isMySuggestion =
        _presenter.isMySuggestion(participantAgendaItemDetails);
    final meetingUserSuggestion =
        participantAgendaItemDetails.suggestions.first;
    final likeImagePath = _presenter.getLikeImagePath(meetingUserSuggestion);
    final dislikeImagePath =
        _presenter.getDislikeImagePath(meetingUserSuggestion);
    final likeDislikeCount =
        _presenter.getLikeDislikeCount(meetingUserSuggestion);
    final canModerate = _presenter.canModerateSuggestions;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 10 : 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.theme.colorScheme.surface,
          border: isMySuggestion
              ? Border.all(color: context.theme.colorScheme.primary)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: UserProfileChip(
                    userId: participantAgendaItemDetails.userId,
                    textStyle: AppTextStyle.bodyMedium.copyWith(
                      color: context.theme.colorScheme.onPrimaryContainer,
                    ),
                    showName: true,
                    showIsYou: true,
                    showBorder: true,
                    imageHeight: isMobile ? 30 : 42,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      likeDislikeCount,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: context.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(width: 5),
                    AppClickableWidget(
                      child: ProxiedImage(
                        null,
                        asset: likeImagePath,
                        width: 20,
                        height: 20,
                      ),
                      onTap: () => alertOnError(
                        context,
                        () => _presenter.toggleLikeDislike(
                          LikeType.like,
                          participantAgendaItemDetails,
                          meetingUserSuggestion,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    AppClickableWidget(
                      child: ProxiedImage(
                        null,
                        asset: dislikeImagePath,
                        width: 20,
                        height: 20,
                      ),
                      onTap: () => alertOnError(
                        context,
                        () => _presenter.toggleLikeDislike(
                          LikeType.dislike,
                          participantAgendaItemDetails,
                          meetingUserSuggestion,
                        ),
                      ),
                    ),
                    if (isMySuggestion || canModerate) ...[
                      SizedBox(width: 10),
                      AppClickableWidget(
                        child: ProxiedImage(
                          null,
                          asset: AppAsset.kXPng,
                          width: 20,
                          height: 20,
                        ),
                        onTap: () async {
                          final isSuccess = await ConfirmDialog(
                            title: context.l10n.removeSuggestion,
                            confirmText: context.l10n.remove,
                            cancelText: context.l10n.cancel,
                            onConfirm: (context) =>
                                Navigator.pop(context, true),
                          ).show();

                          if (isSuccess == true) {
                            await alertOnError(
                              context,
                              () => _presenter.removeSuggestion(
                                meetingUserSuggestion,
                                participantAgendaItemDetails.userId ?? '',
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              meetingUserSuggestion.suggestion,
              style: AppTextStyle.body.copyWith(
                color: context.theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
