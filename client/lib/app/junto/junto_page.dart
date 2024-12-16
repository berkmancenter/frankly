import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/theme_creation_utility.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussion_threads/manipulate_discussion_thread/manipulate_discussion_thread_page.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/templates/topic_fab.dart';
import 'package:junto/app/junto/home/junto_page_fab.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/resources/create_junto_resource_modal.dart';
import 'package:junto/app/junto/resources/junto_resources_presenter.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/navbar/bottom_nav_bar.dart';
import 'package:junto/common_widgets/navbar/junto_scaffold.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

class JuntoPage extends StatefulWidget {
  final bool fillViewport;
  final bool isCreateConversationFabVisible;
  final Widget content;

  const JuntoPage._({
    required this.fillViewport,
    required this.isCreateConversationFabVisible,
    required this.content,
  });

  static Widget create({
    required String displayId,
    bool fillViewport = false,
    bool isCreateConversationFabVisible = false,
    required Widget content,
  }) {
    return ChangeNotifierProvider(
      create: (context) => JuntoProvider(
        displayId: displayId,
        navBarProvider: Provider.of<NavBarProvider>(context, listen: false),
      )..initialize(),
      child: JuntoPage._(
        fillViewport: fillViewport,
        isCreateConversationFabVisible: isCreateConversationFabVisible,
        content: content,
      ),
    );
  }

  @override
  _JuntoPageState createState() => _JuntoPageState();
}

class _JuntoPageState extends State<JuntoPage> {
  @override
  void initState() {
    context.read<NavBarProvider>().checkIfShouldResetNav();
    super.initState();
  }

  bool get _showBottomNav {
    final isNavHiddenInNavProvider = context.watch<NavBarProvider>().hideNav;
    final isLocationWithoutNavBar =
        CheckCurrentLocation.isInstantPage || CheckCurrentLocation.isUnifyAmericaPage;
    return !isNavHiddenInNavProvider &&
        !isLocationWithoutNavBar &&
        responsiveLayoutService.showBottomNavBar(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: JuntoStreamBuilder<Junto?>(
        entryFrom: '_JuntoPageState._buildJuntoContent',
        stream: context.watch<JuntoProvider>().juntoStream,
        errorMessage: 'Something went wrong loading this community.',
        builder: (_, junto) {
          final darkThemeColor = ThemeUtils.parseColor(junto?.themeDarkColor) ?? AppColor.darkBlue;
          final isOnPageWithDefaultColors = CheckCurrentLocation.isTopicPage ||
              CheckCurrentLocation.isDiscussionPage ||
              CheckCurrentLocation.isJuntoAdminPage;
          final enableCustomColors = !isOnPageWithDefaultColors;
          final lightThemeColor = ThemeUtils.parseColor(junto?.themeLightColor) ?? AppColor.gray6;
          return Consumer<UserService>(
            builder: (_, __, ___) => Consumer<JuntoUserDataService>(
              builder: (_, __, ___) {
                final primaryColor = enableCustomColors ? darkThemeColor : AppColor.darkBlue;
                final secondaryColor = enableCustomColors ? lightThemeColor : AppColor.brightGreen;

                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: primaryColor,
                          secondary: secondaryColor,
                        ),
                    switchTheme: SwitchTheme.of(context).copyWith(
                      thumbColor: MaterialStateColor.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return secondaryColor;
                        } else {
                          return primaryColor;
                        }
                      }),
                      trackColor: MaterialStateColor.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return primaryColor;
                        } else {
                          return AppColor.gray4;
                        }
                      }),
                    ),
                    radioTheme: RadioTheme.of(context).copyWith(
                      fillColor: MaterialStateColor.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return primaryColor;
                        } else {
                          return AppColor.gray4;
                        }
                      }),
                    ),
                  ),
                  child: ChangeNotifierProvider<CommunityPermissionsProvider>(
                    create: (context) => CommunityPermissionsProvider(
                        juntoProvider: Provider.of<JuntoProvider>(context, listen: false))
                      ..initialize(),
                    child: Builder(
                      builder: (context) {
                        final isCreateMeetingAvailable = widget.isCreateConversationFabVisible &&
                            context.watch<CommunityPermissionsProvider>().canCreateEvent;

                        return JuntoScaffold(
                          bgColor: enableCustomColors ? lightThemeColor : AppColor.gray6,
                          fillViewport: widget.fillViewport,
                          child: widget.content,
                          bottomNavigationBar: _showBottomNav
                              ? JuntoBottomNavBar(showCreateMeetingButton: isCreateMeetingAvailable)
                              : null,
                          floatingActionButton: _buildFab(context),
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
    if (CheckCurrentLocation.isJuntoResourcesPage) {
      final showResourcesFab = context.watch<CommunityPermissionsProvider>().canEditCommunity;
      return _buildResourcesFab(isAvailable: showResourcesFab);
    } else if (CheckCurrentLocation.isDiscussionThreadsPage) {
      return _buildDiscussionThreadsFab();
    } else if (CheckCurrentLocation.isTopicPage) {
      return TopicFab();
    } else {
      final isCreateMeetingAvailable = widget.isCreateConversationFabVisible &&
          context.watch<CommunityPermissionsProvider>().canCreateEvent;

      return _buildCreateMeetingFab(
        isAvailable: !_showBottomNav && isCreateMeetingAvailable,
        context: context,
      );
    }
  }

  Widget? _buildCreateMeetingFab({required bool isAvailable, required BuildContext context}) =>
      isAvailable
          ? JuntoPageFloatingActionButton(
              text: 'Create an event',
              onTap: () => CreateDiscussionDialog.show(context),
            )
          : null;

  Widget? _buildResourcesFab({required bool isAvailable}) => isAvailable
      ? ChangeNotifierProvider<JuntoResourcesPresenter>(
          create: (_) =>
              JuntoResourcesPresenter(juntoProvider: context.read<JuntoProvider>())..initialize(),
          child: Builder(builder: (context) {
            return JuntoPageFloatingActionButton(
              onTap: () => CreateJuntoResourceModal.show(context),
              text: 'Add a resource',
            );
          }),
        )
      : null;

  Widget? _buildDiscussionThreadsFab() {
    return JuntoPageFloatingActionButton(
      text: 'Create post',
      onTap: () => guardSignedIn(
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ManipulateDiscussionThreadPage(
              juntoProvider: context.read<JuntoProvider>(),
              discussionThread: null,
            ),
          ),
        ),
      ),
    );
  }
}
