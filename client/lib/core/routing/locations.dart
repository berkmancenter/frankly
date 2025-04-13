import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/features/community/features/create_community/presentation/views/new_space_page.dart';
import 'package:client/features/home/presentation/views/home_page.dart';
import 'package:client/features/admin/presentation/views/community_admin.dart';
import 'package:client/features/discussion_threads/presentation/views/discussion_thread_page.dart';
import 'package:client/features/discussion_threads/presentation/views/discussion_threads_page.dart';
import 'package:client/features/events/features/event_page/presentation/views/event_page.dart';
import 'package:client/features/events/presentation/views/events_page.dart';
import 'package:client/features/events/features/instant/presentation/views/instant_event.dart';
import 'package:client/features/community/presentation/views/community_home.dart';
import 'package:client/features/community/presentation/views/community_page.dart';
import 'package:client/features/resources/presentation/views/community_resources.dart';
import 'package:client/features/templates/presentation/views/browse_templates_page.dart';
import 'package:client/features/templates/presentation/views/template_page.dart';
import 'package:client/features/user/presentation/views/email_unsubscribe.dart';
import 'package:client/features/user/presentation/views/user_settings_page.dart';
import 'package:client/core/widgets/initial_loading_widget.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/config/environment.dart';

final routerDelegate = BeamerDelegate(
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(),
      NewSpaceLocation(),
      CommunityLocation(),
      UserSettingsLocation(),
      EmailUnsubscribeLocation(),
    ],
  ),
  notFoundPage: BeamPage(
    child: notFoundPage,
  ),
);

bool listStartsWith(List<String> source, List<String> comparison) {
  for (int i = 0; i < comparison.length; i++) {
    if (i >= source.length || comparison[i] != source[i]) return false;
  }

  return true;
}

bool listEndsWith(List<String> source, List<String> comparison) =>
    listStartsWith(source.reversed.toList(), comparison.reversed.toList());

void updateQueryParameterToJoinEvent() {
  final params = Map<String, String>.from(
    (routerDelegate.currentBeamLocation.state as BeamState).queryParameters,
  );
  final updatedParams = params..addEntries([MapEntry('status', 'joined')]);
  routerDelegate.currentBeamLocation.update(
    (state) => (state as BeamState).copyWith(queryParameters: updatedParams),
  );
}

final notFoundPage = Builder(
  builder: (context) => Scaffold(
    body: Center(
      child: Text(context.l10n.thisUrlWasNotFound),
    ),
  ),
);

BeamPage _buildBeamPage({
  required LocalKey key,
  String title = Environment.appName,
  required Widget child,
}) {
  Widget tempWidget = UIMigration(
    whiteBackground: true,
    child: InitialLoadingWidget(
      child: child,
    ),
  );

  return BeamPage(
    key: key,
    title: title,
    child: tempWidget,
  );
}

class HomeLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/home'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        _buildBeamPage(
          key: ValueKey('home'),
          title: context.l10n.appNameHome(Environment.appName),
          child: HomePage(),
        ),
      ];
}

class NewSpaceLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/newspace'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        _buildBeamPage(
          key: ValueKey('newspace'),
          title: context.l10n.appNameWelcome(Environment.appName),
          child: NewSpacePage(),
        ),
      ];
}

enum UserSettingsSection {
  events,
  profile,
  notifications,
  subscriptions,
}

class UserSettingsLocation extends BeamLocation<BeamState> {
  UserSettingsLocation({
    UserSettingsSection? initialSection,
  });

  static const sectionQueryLookup = <UserSettingsSection, String>{
    UserSettingsSection.events: 'events',
    UserSettingsSection.profile: 'profile',
    UserSettingsSection.notifications: 'notifications',
    UserSettingsSection.subscriptions: 'subscriptions',
  };

  static final queryToSectionLookup = {
    for (final entry in sectionQueryLookup.entries) entry.value: entry.key,
  };

  @override
  List<String> get pathPatterns => [
        '/settings',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        _buildBeamPage(
          key: ValueKey('settings-${state.uri}'),
          title: context.l10n.appNameUserSettings(Environment.appName),
          child: UserSettingsPage(
            communityId: state.queryParameters['communityId'],
            initialSection:
                queryToSectionLookup[state.queryParameters['initialSection']],
          ),
        ),
      ];
}

class EmailUnsubscribeLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => [
        '/emailunsubscribe',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        _buildBeamPage(
          key: ValueKey('emailunsubscribe'),
          title: context.l10n.appNameUnsubscribe(Environment.appName),
          child:
              EmailUnsubscribePage(data: state.queryParameters['data'] ?? ''),
        ),
      ];
}

class CommunityLocation extends BeamLocation<BeamState> {
  static const eventIdParameter = 'eventId';

  CommunityLocation([RouteInformation? routeInformation])
      : super(
          routeInformation,
        );

  @override
  List<String> get pathPatterns {
    const prefix = '/space/:displayId';

    final blueprints = [
      '',
      '/challenge',
      '/instant',
      '/admin',
      '/resources',
      '/discuss/upcoming',
      '/discuss/:templateId',
      '/discuss/:templateId/:$eventIdParameter',
      '/posts',
      '/post/:discussionThreadId',
    ].map((route) => '$prefix$route').toList();
    return blueprints;
  }

  BeamPage _getCommunityBeamPage({
    required String key,
    required String displayId,
    required Widget child,
    String? title,
    bool fillViewport = false,
    bool isCreateEventFabVisible = false,
  }) {
    return _buildBeamPage(
      key: ValueKey(key),
      title: title ?? Environment.appName,
      child: CommunityPage.create(
        displayId: displayId,
        fillViewport: fillViewport,
        isCreateEventFabVisible: isCreateEventFabVisible,
        content: child,
      ),
    );
  }

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final displayId = state.pathParameters['displayId']!;
    final templateId = state.pathParameters['templateId'];

    return [
      if (state.pathPatternSegments.where((p) => p.isNotEmpty).length == 2)
        _getCommunityBeamPage(
          key: 'community-${state.uri}',
          displayId: displayId,
          isCreateEventFabVisible: true,
          child: CommunityHome.create(),
        )
      else if (listEndsWith(state.pathPatternSegments, ['instant']))
        _buildBeamPage(
          key: ValueKey('instant-${state.uri}'),
          child: InstantEvent(
            communityId: displayId,
            templateId: state.queryParameters['templateId'],
            name: state.queryParameters['name'],
            meetingId: state.queryParameters['meetingId'],
            record: state.queryParameters['record'] == 'true',
          ),
        )
      else if (listEndsWith(state.pathPatternSegments, ['admin']))
        _getCommunityBeamPage(
          key: 'community-admin-${state.uri}',
          displayId: displayId,
          child: CommunityAdmin(tab: state.queryParameters['tab']),
        )
      else if (listEndsWith(state.pathPatternSegments, ['discuss', 'upcoming']))
        _getCommunityBeamPage(
          key: 'community-$displayId-discuss-upcoming',
          displayId: displayId,
          child: EventsPage.create(),
          isCreateEventFabVisible: true,
        )
      else if (listEndsWith(state.pathPatternSegments, ['discuss']))
        _getCommunityBeamPage(
          key: 'community-$displayId-browse-templates',
          displayId: displayId,
          child: BrowseTemplatesPage(),
          isCreateEventFabVisible: true,
        )
      else if (listEndsWith(state.pathPatternSegments, ['resources']))
        _getCommunityBeamPage(
          key: 'community-$displayId-resources',
          displayId: displayId,
          child: CommunityResources(),
        )
      else if (state.pathPatternSegments.contains('discuss') &&
          state.pathPatternSegments.length == 4)
        _getCommunityBeamPage(
          key: 'community-$displayId-template-$templateId',
          displayId: displayId,
          child: TemplatePage.create(templateId: templateId ?? ''),
        )
      else if (state.pathPatternSegments.contains('discuss') &&
          state.pathPatternSegments.length == 5)
        _getCommunityBeamPage(
          key:
              'community-$displayId-template-$templateId-${state.pathParameters['eventId']}',
          displayId: displayId,
          child: EventPage(
            templateId: templateId!,
            eventId: state.pathParameters['eventId']!,
            cancel: state.queryParameters['cancel'] == 'true',
            uid: state.queryParameters['uid'],
          ).create(),
        )
      // [community, :displayId, posts]
      else if (state.pathPatternSegments.contains('posts') &&
          state.pathPatternSegments.length == 3)
        _getCommunityBeamPage(
          key: 'community-$displayId-discussionThreads',
          displayId: displayId,
          fillViewport: false,
          child: DiscussionThreadsPage(),
        )
      // [community, :displayId, post, :discussionThreadId]
      else if (state.pathPatternSegments.contains('post') &&
          state.pathPatternSegments.length == 4)
        _getCommunityBeamPage(
          key:
              'community-$displayId-discussionThread-${state.pathParameters['discussionThreadId']}',
          displayId: displayId,
          fillViewport: true,
          child: DiscussionThreadPage(
            discussionThreadId: state.pathParameters['discussionThreadId']!,
            scrollToComments: false,
          ),
        ),
    ];
  }
}

class CommunityPageRoutes {
  final String communityDisplayId;

  CommunityPageRoutes({required this.communityDisplayId});

  String get prefix => '/space/$communityDisplayId';

  CommunityLocation get communityHome => _getLocation(path: prefix);

  CommunityLocation get communityChat =>
      _getLocation(path: '$prefix/discuss/chat');

  CommunityLocation get discussionThreadsPage =>
      _getLocation(path: '$prefix/posts');

  CommunityLocation get eventsPage =>
      _getLocation(path: '$prefix/discuss/upcoming');

  CommunityLocation get resourcesPage =>
      _getLocation(path: '$prefix/resources');

  CommunityLocation get browseTemplatesPage =>
      _getLocation(path: '$prefix/discuss');

  CommunityLocation communityAdmin({String? tab}) => _getLocation(
        path: '$prefix/admin',
        queryParameters: tab != null ? {'tab': tab} : null,
      );

  CommunityLocation templatePage({required String templateId}) => _getLocation(
        path: '$prefix/discuss/$templateId',
      );

  CommunityLocation discussionThreadPage({
    required String discussionThreadId,
    bool scrollToComments = false,
  }) {
    return _getLocation(
      path: '$prefix/post/$discussionThreadId',
    );
  }

  CommunityLocation instantPage({
    required String meetingId,
  }) {
    return _getLocation(
      path: '$prefix/instant',
      queryParameters: {'meetingId': meetingId},
    );
  }

  CommunityLocation eventPage({
    required String templateId,
    required String eventId,
  }) =>
      _getLocation(
        path: '$prefix/discuss/$templateId/$eventId',
      );

  CommunityLocation _getLocation({
    required String path,
    Map<String, String>? queryParameters,
  }) {
    final location = Uri(path: path, queryParameters: queryParameters);
    return CommunityLocation(RouteInformation(uri: location));
  }
}

class CheckCurrentLocation {
  static String get _currentPath =>
      (routerDelegate.currentBeamLocation.state as BeamState)
          .pathPatternSegments
          .join('/');

  static bool get isCommunityRoute => _currentPath.split('/').first == 'space';

  static bool get isCommunityHomePage => _currentPath == 'space/:displayId';

  static bool get isCommunitySchedulePage =>
      _currentPath == 'space/:displayId/discuss/upcoming';

  static bool get isCommunityTemplatesPage =>
      _currentPath == 'space/:displayId/discuss';

  static bool get isCommunityResourcesPage =>
      _currentPath == 'space/:displayId/resources';

  static bool get isCommunityAdminPage =>
      _currentPath == 'space/:displayId/admin';

  static bool get isDiscussionThreadsPage =>
      _currentPath == 'space/:displayId/posts';

  static bool get isDiscussionThreadPage =>
      _currentPath == 'space/:displayId/post/:discussionThreadId';

  static bool get isEventPage =>
      _currentPath == 'space/:displayId/discuss/:templateId/:eventId';

  static bool get isTemplatePage =>
      _currentPath == 'space/:displayId/discuss/:templateId';

  static bool get isInstantPage => _currentPath == 'space/:displayId/instant';
}
