import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/features/community/utils/community_theme_utils.dart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/user_submitted_agenda_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/app_clickable_widget.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class UserSubmittedAgenda extends StatefulWidget {
  @override
  _UserSubmittedAgendaState createState() => _UserSubmittedAgendaState();
}

class _UserSubmittedAgendaState extends State<UserSubmittedAgenda> {
  UserSubmittedAgendaProvider get provider =>
      Provider.of<UserSubmittedAgendaProvider>(context);
  UserSubmittedAgendaProvider get readProvider =>
      Provider.of<UserSubmittedAgendaProvider>(context, listen: false);
  final _submitController = SubmitNotifier();

  Widget _buildVotingButton({
    required String itemId,
    required bool upvote,
    required int numVotes,
    required IconData icon,
    required bool selected,
  }) {
    final color = selected ? AppColor.brightGreen : AppColor.darkBlue;
    return TextButton(
      onPressed: () => readProvider.vote(upvote: upvote, itemId: itemId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Icon(icon, color: color),
            ),
            Text(
              numVotes.toString(),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(SuggestedAgendaItem item) {
    final userId = Provider.of<UserService>(context).currentUserId;

    final canDelete = Provider.of<EventPermissionsProvider>(context)
        .canDeleteSuggestedItem(item);

    return Container(
      key: Key(item.id ?? ''),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10) - EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                UserProfileChip(
                  userId: item.creatorId,
                  textStyle: TextStyle(
                    color: AppColor.darkBlue,
                    fontSize: 16,
                  ),
                  showBorder: false,
                  showName: true,
                  imageHeight: 30,
                ),
                Spacer(),
                _buildVotingButton(
                  numVotes: item.upvotedUserIds.length,
                  icon: Icons.thumb_up_outlined,
                  itemId: item.id ?? '',
                  upvote: true,
                  selected: item.upvotedUserIds.contains(userId),
                ),
                _buildVotingButton(
                  numVotes: item.downvotedUserIds.length,
                  icon: Icons.thumb_down_outlined,
                  itemId: item.id ?? '',
                  upvote: false,
                  selected: item.downvotedUserIds.contains(userId),
                ),
                if (canDelete)
                  AppClickableWidget(
                    child: ProxiedImage(
                      null,
                      asset: AppAsset.kXPng,
                      width: 24,
                      height: 24,
                    ),
                    onTap: () => readProvider.delete(item.id ?? ''),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        return SelectableLinkify(
                          text: item.content ?? '',
                          textAlign: TextAlign.left,
                          style: AppTextStyle.eyebrow
                              .copyWith(color: AppColor.gray1),
                          options: LinkifyOptions(looseUrl: true),
                          onOpen: (link) => launch(link.url),
                        );
                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(Icons.copy),
                        splashRadius: 20,
                        padding: const EdgeInsets.all(8),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: item.content!),
                          );
                          showRegularToast(
                            context,
                            context.l10n.textCopied,
                            toastType: ToastType.success,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySuggestions() => Center(
        child: EmptyPageContent(
          type: EmptyPageType.suggestions,
          titleText: context.l10n.makeASuggestion,
          subtitleText: context.l10n.suggestAgendaItemHint,
          showContainer: false,
          isBackgroundDark: Theme.of(context).isDark,
        ),
      );

  Widget _buildContent() {
    return CustomStreamBuilder<List<SuggestedAgendaItem>>(
      entryFrom: '_UserSubmittedAgendaState._buildContent',
      stream: provider.suggestedAgendaItemsStream,
      builder: (context, suggestedItems) {
        if (suggestedItems == null || suggestedItems.isEmpty) {
          return _buildEmptySuggestions();
        } else {
          return ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: suggestedItems.map(_buildItem).toList(),
          );
        }
      },
    );
  }

  Widget _buildInput() {
    final canSubmit = !isNullOrEmpty(readProvider.newSubmissionContent.trim());

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: readProvider.newSubmissionController,
              padding: EdgeInsets.zero,
              contentPadding: EdgeInsets.all(20),
              onEditingComplete:
                  canSubmit ? () => _submitController.submit() : null,
              textStyle: body.copyWith(color: AppColor.black),
              maxLines: 1,
              borderType: BorderType.none,
              borderRadius: 30,
              hintText: context.l10n.addSomethingHere,
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(width: 10),
          ActionButton(
            shape: CircleBorder(),
            minWidth: 58,
            padding: EdgeInsets.symmetric(vertical: 10),
            borderRadius: BorderRadius.circular(50),
            controller: _submitController,
            onPressed: canSubmit
                ? () => alertOnError(context, () => readProvider.submit())
                : null,
            color: canSubmit ? AppColor.darkBlue : AppColor.gray4,
            child: Icon(
              CupertinoIcons.paperplane,
              size: 30,
              color: AppColor.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildContent(),
        ),
        _buildInput(),
      ],
    );
  }
}
