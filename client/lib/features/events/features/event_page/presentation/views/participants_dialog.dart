import 'package:collection/collection.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';
import 'package:client/core/utils/firestore_utils.dart';

class ParticipantsDialog extends StatelessWidget {
  final EventProvider eventProvider;
  final EventPermissionsProvider eventPermissions;

  const ParticipantsDialog({
    required this.eventProvider,
    required this.eventPermissions,
  });

  Event get event => eventProvider.event;

  Future<bool> show(BuildContext context) async {
    final communityProvider =
        Provider.of<CommunityProvider>(context, listen: false);
    return (await showCustomDialog(
          builder: (context) => InheritedProvider.value(
            value: communityProvider,
            child: this,
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: eventProvider,
      builder: (context, _) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {},
                child: eventProvider.useParticipantCountEstimate
                    ? _buildLivestreamEventLayout(context)
                    : _buildRegularEventLayout(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLivestreamEventLayout(BuildContext context) {
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
              child: _buildLiveStreamEventParticipants(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularEventLayout(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: CustomListView(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColor.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CustomListView(
                shrinkWrap: true,
                children: [
                  _buildCloseDialogIcon(context),
                  _buildDialogTitle(),
                  ..._buildEventParticipants(context),
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
      child: HeightConstrainedText(
        '${eventProvider.participantCount} Participant${eventProvider.participantCount > 1 ? 's' : ''}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColor.darkBlue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLiveStreamEventParticipants(BuildContext context) {
    return FirestoreListView(
      shrinkWrap: true,
      itemBuilder: (context, documentSnapshot) {
        final participant = Participant.fromJson(
          fromFirestoreJson(documentSnapshot.data() as Map<String, dynamic>),
        );
        return _buildParticipant(participant, context);
      },
      query: firestoreEventService.eventParticipantsQuery(
        event: eventProvider.event,
      ),
      pageSize: 40,
      emptyBuilder: (_) => HeightConstrainedText('No one is here yet.'),
      errorBuilder: (_, __, ___) => HeightConstrainedText(
        'Something went wrong loading participants. Please refresh.',
      ),
    );
  }

  List<Widget> _buildEventParticipants(BuildContext context) {
    final participantsList = eventProvider.eventParticipants.toList();
    final creator =
        participantsList.firstWhereOrNull((p) => p.id == event.creatorId);
    final self = participantsList.firstWhereOrNull(
      (p) => p.id == Provider.of<UserService>(context).currentUserId,
    );

    // Check if creator and current user are the same and also removes from the list
    // repeated elements and shows current user in the first position of the particpants list.
    final newAdditions =
        [creator, self].where((p) => p != null).map((p) => p!).toSet();
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
          eventPermissions.canRemoveParticipant(participant) && !event.isLocked,
      onRemove: () => alertOnError(
        context,
        () => eventProvider.cancelParticipation(
          participantId: participant.id,
        ),
      ),
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
            CustomInkWell(
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
