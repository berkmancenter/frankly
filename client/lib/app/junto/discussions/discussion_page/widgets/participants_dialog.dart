import 'package:collection/collection.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/user_profile_chip.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:provider/provider.dart';
import 'package:junto/services/firestore/firestore_utils.dart';

class ParticipantsDialog extends StatelessWidget {
  final DiscussionProvider discussionProvider;
  final DiscussionPermissionsProvider discussionPermissions;

  const ParticipantsDialog({
    required this.discussionProvider,
    required this.discussionPermissions,
  });

  Discussion get discussion => discussionProvider.discussion;

  Future<bool> show(BuildContext context) async {
    final juntoProvider = Provider.of<JuntoProvider>(context, listen: false);
    return (await showJuntoDialog(
            builder: (context) => InheritedProvider.value(
                  value: juntoProvider,
                  child: this,
                ))) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: discussionProvider,
      builder: (context, _) => JuntoUiMigration(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: JuntoUiMigration(
            whiteBackground: true,
            child: Container(
              padding: const EdgeInsets.all(40),
              child: Align(
                alignment: Alignment.topCenter,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {},
                    child: discussionProvider.useParticipantCountEstimate
                        ? _buildLivestreamConversationLayout(context)
                        : _buildRegularConversationLayout(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLivestreamConversationLayout(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppColor.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCloseDialogIcon(context),
            _buildDialogTitle(),
            Flexible(
              child: _buildLiveStreamDiscussionParticipants(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularConversationLayout(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: JuntoListView(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColor.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: JuntoListView(
                shrinkWrap: true,
                children: [
                  _buildCloseDialogIcon(context),
                  _buildDialogTitle(),
                  ..._buildDiscussionParticipants(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseDialogIcon(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ActionButton(
        height: 40,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        minWidth: 50,
        borderRadius: BorderRadius.circular(0),
        color: Colors.transparent,
        icon: Icon(
          Icons.close,
          size: 40,
          color: AppColor.darkBlue,
        ),
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }

  Widget _buildDialogTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: JuntoText(
        '${discussionProvider.participantCount} Participant${discussionProvider.participantCount > 1 ? 's' : ''}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColor.darkBlue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLiveStreamDiscussionParticipants(BuildContext context) {
    return FirestoreListView(
      shrinkWrap: true,
      itemBuilder: (context, documentSnapshot) {
        final participant = Participant.fromJson(
            fromFirestoreJson(documentSnapshot.data() as Map<String, dynamic>));
        return _buildParticipant(participant, context);
      },
      query: firestoreDiscussionService.discussionParticipantsQuery(
        discussion: discussionProvider.discussion,
      ),
      pageSize: 40,
      emptyBuilder: (_) => JuntoText('No one is here yet.'),
      errorBuilder: (_, __, ___) =>
          JuntoText('Something went wrong loading participants. Please refresh.'),
    );
  }

  List<Widget> _buildDiscussionParticipants(BuildContext context) {
    final participantsList = discussionProvider.discussionParticipants.toList();
    final creator = participantsList.firstWhereOrNull((p) => p.id == discussion.creatorId);
    final self = participantsList
        .firstWhereOrNull((p) => p.id == Provider.of<UserService>(context).currentUserId);

    // Check if creator and current user are the same and also removes from the list
    // repeated elements and shows current user in the first position of the particpants list.
    final newAdditions = [creator, self].where((p) => p != null).map((p) => p!).toSet();
    newAdditions.forEach(participantsList.remove);
    participantsList.insertAll(0, newAdditions);

    return [
      for (final p in participantsList) _buildParticipant(p, context),
    ];
  }

  Widget _buildParticipant(Participant participant, BuildContext context) {
    return _Participant(
      id: participant.id,
      isRemoveAllowed:
          discussionPermissions.canRemoveParticipant(participant) && !discussion.isLocked,
      onRemove: () => alertOnError(
          context, () => discussionProvider.cancelParticipation(participantId: participant.id)),
    );
  }
}

class _Participant extends StatelessWidget {
  final String? id;
  final bool isRemoveAllowed;
  final Function() onRemove;

  const _Participant({
    required this.id,
    required this.isRemoveAllowed,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: UserProfileChip(userId: id)),
          if (isRemoveAllowed)
            JuntoInkWell(
              onTap: onRemove,
              boxShape: BoxShape.circle,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.close, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
