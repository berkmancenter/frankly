import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/events/create_event/create_event_dialog.dart';
import 'package:client/app/community/home/community_page_fab.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/templates/attended_prerequisite_provider.dart';
import 'package:client/app/community/templates/new_event_card.dart';
import 'package:client/app/community/templates/template_page_provider.dart';
import 'package:client/common_widgets/create_dialog_ui_migration.dart';
import 'package:client/common_widgets/custom_stream_builder.dart';
import 'package:client/services/services.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/admin/plan_capability_list.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

import '../../../routing/locations.dart';

class TemplateFab extends StatefulWidget {
  const TemplateFab({Key? key}) : super(key: key);

  @override
  State<TemplateFab> createState() => _TemplateFabState();
}

class _TemplateFabState extends State<TemplateFab> {
  void _defaultToHosted() =>
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pop(context, EventType.hosted);
      });

  @override
  Widget build(BuildContext context) {
    final showFab = responsiveLayoutService.isMobile(context) &&
        context.watch<CommunityPermissionsProvider>().canCreateEvent;

    if (!showFab) return SizedBox.shrink();

    return CommunityPageFloatingActionButton(
      text: 'Create an event',
      onTap: () async {
        final communityId =
            Provider.of<CommunityProvider>(context, listen: false).communityId;
        final templateId =
            (routerDelegate.currentBeamLocation.state as BeamState)
                    .pathParameters['templateId'] ??
                '';

        final Template? template =
            await firestoreDatabase.getTemplate(communityId, templateId);

        if (template == null) return;

        final isAdmin = userDataService.getMembership(communityId).isAdmin;
        final permissions = context.read<CommunityPermissionsProvider>();

        final EventType? eventType;
        if (permissions.canModerateContent) {
          eventType = await CreateDialogUiMigration<EventType>(
            isCloseButtonVisible: false,
            builder: (_) {
              analytics.logEvent(
                AnalyticsPressCreateEventFromGuideEvent(
                  communityId: template.communityId,
                  guideId: template.id,
                ),
              );

              return MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                    value: context.read<CommunityProvider>(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => AttendedPrerequisiteProvider(
                      template: template,
                      isAdmin: isAdmin,
                    )..initialize(),
                  ),
                  ChangeNotifierProvider(
                    // New event card below uses from the template page provider to handle
                    // if the help tooltip is visible or not. We don't have access to that here
                    // so we create a replacement. We dont initialize it as the streams are unused.
                    create: (_) => TemplatePageProvider(
                      communityId:
                          context.read<CommunityProvider>().communityId,
                      templateId: templateId,
                    ),
                  ),
                ],
                child: _buildLoadCapabilities(template),
              );
            },
          ).show();
        } else {
          eventType = EventType.hosted;
        }

        if (eventType != null) {
          await CreateEventDialog.show(
            context,
            eventType: eventType,
            template: template,
          );
        }
      },
    );
  }

  Widget _buildLoadCapabilities(Template template) {
    final communityProvider = Provider.of<CommunityProvider>(context);

    return Builder(
      builder: (innerContext) {
        return CustomStreamBuilder<PlanCapabilityList>(
          stream: cloudFunctionsService
              .getCommunityCapabilities(
                GetCommunityCapabilitiesRequest(
                  communityId: communityProvider.communityId,
                ),
              )
              .asStream(),
          entryFrom: 'TemplateFab.build',
          builder: (_, capabilities) {
            final hasLiveStream = capabilities?.hasLivestreams == true;

            // If the user doesn't have options, we will proceed to the second step automatically.
            // If the plan capabilities do not include hasLiveStream or the user is not moderator,
            // they will not have other options and we can immediately close the dialog with `hosted` option.
            if (!hasLiveStream) {
              _defaultToHosted();
              return SizedBox.shrink();
            } else {
              return _loadPrerequisite(template);
            }
          },
        );
      },
    );
  }

  Widget _loadPrerequisite(Template template) {
    return Builder(
      builder: (innerContext) {
        return CustomStreamBuilder<bool>(
          entryFrom: 'TemplateFab._showCreateEventDialog',
          stream: innerContext
              .watch<AttendedPrerequisiteProvider>()
              .hasParticipantAttendedPrerequisiteFuture
              .asStream(),
          builder: (_, hasAttendedPrerequisite) {
            return NewEventCard(
              template: template,
              hasAttendedPrerequisite: hasAttendedPrerequisite ?? false,
              onCreateEventTap: (eventType) =>
                  Navigator.pop(context, eventType),
            );
          },
        );
      },
    );
  }
}
