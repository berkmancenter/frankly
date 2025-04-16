import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_picture.dart';
import 'package:client/features/community/presentation/widgets/carousel/time_indicator.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/events/presentation/widgets/event_participants_list.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';

/// This is the card for the upcoming events shown on the Home page.
///
/// Tapping on it navigates to the event page.
class EventWidget extends StatelessWidget {
  final Event event;

  const EventWidget(
    this.event, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ChangeNotifierProvider(
        create: (context) => EventProvider(
          communityProvider: context.read<CommunityProvider>(),
          templateId: event.templateId,
          eventId: event.id,
        )..initialize(),
        child: Builder(
          builder: (context) {
            final eventProvider = EventProvider.watch(context);
            return CustomStreamBuilder<bool>(
              entryFrom: 'event_widget.build_event',
              stream: eventProvider.hasParticipantAttendedPrerequisiteFuture
                  .asStream(),
              builder: (_, __) {
                return CustomStreamBuilder<Event>(
                  entryFrom: 'event_widget.build_event',
                  stream: eventProvider.eventStream,
                  builder: (context, _) {
                    final isAdmin = Provider.of<UserDataService>(context)
                        .getMembership(
                          Provider.of<CommunityProvider>(context).communityId,
                        )
                        .isAdmin;

                    final hasPrerequisiteTemplate =
                        eventProvider.event.prerequisiteTemplateId != null;

                    final isDisabled = hasPrerequisiteTemplate &&
                        !eventProvider.hasAttendedPrerequisite &&
                        !isAdmin;
                    return MergeSemantics(
                      child: CustomInkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: isDisabled
                            ? null
                            : () => routerDelegate.beamTo(
                                  CommunityPageRoutes(
                                    communityDisplayId:
                                        CommunityProvider.readOrNull(context)
                                                ?.displayId ??
                                            event.communityId,
                                  ).eventPage(
                                    templateId: event.templateId,
                                    eventId: event.id,
                                  ),
                                ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDisabled
                                ? AppColor.white.withOpacity(0.8)
                                : AppColor.white,
                            boxShadow: [
                              if (!isDisabled) AppDecoration.lightBoxShadow,
                            ],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: _buildCardContent(
                            context: context,
                            isDisabled: isDisabled,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardContent({
    required BuildContext context,
    required bool isDisabled,
  }) =>
      Row(
        children: [
          if (event.scheduledTime != null)
            VerticalTimeAndDateIndicator(
              shadow: false,
              isDisabled: isDisabled,
              time: DateTime.fromMillisecondsSinceEpoch(
                (event.scheduledTime?.millisecondsSinceEpoch ?? 0),
              ),
            )
          else
            SizedBox(width: 100),
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: EventOrTemplatePicture(
                  key: Key(event.id),
                  event: event,
                  height: 100,
                ),
              ),
              if (isDisabled)
                Container(
                  width: 90,
                  height: 90,
                  color: Colors.white.withOpacity(0.5),
                ),
            ],
          ),
          Expanded(
            child: _buildCardText(isDisabled),
          ),
        ],
      );

  Widget _buildCardText(bool disabled) => Padding(
        padding: const EdgeInsets.all(12),
        child: _buildCardTextContent(disabled),
      );

  Widget _buildCardTextContent(bool isDisabled) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          HeightConstrainedText(
            event.title ?? 'Scheduled event',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.headline4.copyWith(
              color: isDisabled
                  ? AppColor.darkBlue.withOpacity(0.5)
                  : AppColor.darkBlue,
            ),
          ),
          SizedBox(height: 20.0),
          if (isDisabled)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColor.pink,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColor.redLightMode,
                    child: Icon(
                      Icons.school_outlined,
                      size: 20,
                      color: AppColor.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  HeightConstrainedText(
                    'Prerequisite',
                    style: AppTextStyle.eyebrowSmall
                        .copyWith(color: AppColor.redLightMode),
                  ),
                ],
              ),
            )
          else ...[
            if (event.isLiveStream)
              HeightConstrainedText(
                'Livestream',
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.gray3,
                ),
              ),
            EventPageParticipantsList(
              event,
              iconSize: 30,
              showFullParticipantCount: true,
            ),
          ],
        ],
      );
}
