import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/utils/theme_creation_utility.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/discussion_threads/presentation/views/manipulate_discussion_thread_page.dart';
import 'package:client/features/events/features/create_event/presentation/views/create_event_dialog.dart';
import 'package:client/features/templates/presentation/widgets/template_fab.dart';
import 'package:client/features/community/presentation/widgets/community_page_fab.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/resources/presentation/views/create_community_resource_modal.dart';
import 'package:client/features/resources/presentation/community_resources_presenter.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/navbar/bottom_nav_bar.dart';
import 'package:client/core/widgets/navbar/custom_scaffold.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatefulWidget {
  final bool fillViewport;
  final bool isCreateEventFabVisible;
  final Widget content;

  const CommunityPage._({
    required this.fillViewport,
    required this.isCreateEventFabVisible,
    required this.content,
  });

  static Widget create({
    required String displayId,
    bool fillViewport = false,
    bool isCreateEventFabVisible = false,
    required Widget content,
  }) {
    return ChangeNotifierProvider(
      create: (context) => CommunityProvider(
        displayId: displayId,
        navBarProvider: Provider.of<NavBarProvider>(context, listen: false),
      )..initialize(),
      child: CommunityPage._(
        fillViewport: fillViewport,
        isCreateEventFabVisible: isCreateEventFabVisible,
        content: content,
      ),
    );
  }

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  void initState() {
    context.read<NavBarProvider>().checkIfShouldResetNav();
    super.initState();
  }

  bool get _showBottomNav {
    final isNavHiddenInNavProvider = context.watch<NavBarProvider>().hideNav;
    final isLocationWithoutNavBar = CheckCurrentLocation.isInstantPage;
    return !isNavHiddenInNavProvider &&
        !isLocationWithoutNavBar &&
        responsiveLayoutService.showBottomNavBar(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomStreamBuilder<Community?>(
        entryFrom: '_CommunityPageState._buildCommunityContent',
        stream: context.watch<CommunityProvider>().communityStream,
        errorMessage: 'Something went wrong loading this community.',
        builder: (_, community) {
          final darkThemeColor =
              ThemeUtils.parseColor(community?.themeDarkColor) ??
                  AppColor.darkBlue;
          final isOnPageWithDefaultColors =
              CheckCurrentLocation.isTemplatePage ||
                  CheckCurrentLocation.isEventPage ||
                  CheckCurrentLocation.isCommunityAdminPage;
          final enableCustomColors = !isOnPageWithDefaultColors;
          final lightThemeColor =
              ThemeUtils.parseColor(community?.themeLightColor) ??
                  AppColor.gray6;
          return Consumer<UserService>(
            builder: (_, __, ___) => Consumer<UserDataService>(
              builder: (_, __, ___) {
                final primaryColor =
                    enableCustomColors ? darkThemeColor : AppColor.darkBlue;
                final secondaryColor =
                    enableCustomColors ? lightThemeColor : AppColor.brightGreen;

                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: primaryColor,
                          secondary: secondaryColor,
                        ),
                    switchTheme: SwitchTheme.of(context).copyWith(
                      thumbColor: WidgetStateColor.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return secondaryColor;
                        } else {
                          return primaryColor;
                        }
                      }),
                      trackColor: WidgetStateColor.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return primaryColor;
                        } else {
                          return AppColor.gray4;
                        }
                      }),
                    ),
                    radioTheme: RadioTheme.of(context).copyWith(
                      fillColor: WidgetStateColor.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return primaryColor;
                        } else {
                          return AppColor.gray4;
                        }
                      }),
                    ),
                  ),
                  child: ChangeNotifierProvider<CommunityPermissionsProvider>(
                    create: (context) => CommunityPermissionsProvider(
                      communityProvider: Provider.of<CommunityProvider>(
                        context,
                        listen: false,
                      ),
                    )..initialize(),
                    child: Builder(
                      builder: (context) {
                        final isCreateMeetingAvailable =
                            widget.isCreateEventFabVisible &&
                                context
                                    .watch<CommunityPermissionsProvider>()
                                    .canCreateEvent;

                        return CustomScaffold(
                          bgColor: enableCustomColors ? lightThemeColor : null,
                          fillViewport: widget.fillViewport,
                          bottomNavigationBar: _showBottomNav
                              ? CommunityBottomNavBar(
                                  showCreateMeetingButton:
                                      isCreateMeetingAvailable,
                                )
                              : null,
                          floatingActionButton: _buildFab(context),
                          child: widget.content,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget? _buildFab(BuildContext context) {
    if (CheckCurrentLocation.isCommunityResourcesPage) {
      final showResourcesFab =
          context.watch<CommunityPermissionsProvider>().canEditCommunity;
      return _buildResourcesFab(isAvailable: showResourcesFab);
    } else if (CheckCurrentLocation.isDiscussionThreadsPage) {
      return _buildDiscussionThreadsFab();
    } else if (CheckCurrentLocation.isTemplatePage) {
      return TemplateFab();
    } else {
      final isCreateMeetingAvailable = widget.isCreateEventFabVisible &&
          context.watch<CommunityPermissionsProvider>().canCreateEvent;

      return _buildCreateMeetingFab(
        isAvailable: !_showBottomNav && isCreateMeetingAvailable,
        context: context,
      );
    }
  }

  Widget? _buildCreateMeetingFab({
    required bool isAvailable,
    required BuildContext context,
  }) =>
      isAvailable
          ? CommunityPageFloatingActionButton(
              text: 'Create an event',
              onTap: () => CreateEventDialog.show(context),
            )
          : null;

  Widget? _buildResourcesFab({required bool isAvailable}) => isAvailable
      ? ChangeNotifierProvider<CommunityResourcesPresenter>(
          create: (_) => CommunityResourcesPresenter(
            communityProvider: context.read<CommunityProvider>(),
          )..initialize(),
          child: Builder(
            builder: (context) {
              return CommunityPageFloatingActionButton(
                onTap: () => CreateCommunityResourceModal.show(context),
                text: 'Add a resource',
              );
            },
          ),
        )
      : null;

  Widget? _buildDiscussionThreadsFab() {
    return CommunityPageFloatingActionButton(
      text: 'Create post',
      onTap: () => guardSignedIn(
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ManipulateDiscussionThreadPage(
              communityProvider: context.read<CommunityProvider>(),
              discussionThread: null,
            ),
          ),
        ),
      ),
    );
  }
}
