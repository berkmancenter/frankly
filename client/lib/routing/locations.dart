import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/new_space_page.dart';
import 'package:junto/app/home/home_page.dart';
import 'package:junto/app/junto/admin/junto_admin.dart';
import 'package:junto/app/junto/discussion_threads/discussion_thread/discussion_thread_page.dart';
import 'package:junto/app/junto/discussion_threads/discussion_threads_page.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page.dart';
import 'package:junto/app/junto/discussions/discussions_page.dart';
import 'package:junto/app/junto/discussions/instant/instant_discussion.dart';
import 'package:junto/app/junto/discussions/instant_unify/instant_unify_discussion.dart';
import 'package:junto/app/junto/home/junto_home.dart';
import 'package:junto/app/junto/junto_page.dart';
import 'package:junto/app/junto/resources/junto_resources.dart';
import 'package:junto/app/junto/templates/browse_topics_page.dart';
import 'package:junto/app/junto/templates/topic_page.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/app/self/email_unsubscribe.dart';
import 'package:junto/app/self/user_settings_page.dart';
import 'package:junto/common_widgets/initial_loading_widget.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/junto_app.dart';

final routerDelegate = BeamerDelegate(
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(),
      NewSpaceLocation(),
      JuntoLocation(),
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

void updateQueryParameterToJoinDiscussion() {
  final params = Map<String, String>.from(
      (routerDelegate.currentBeamLocation.state as BeamState).queryParameters);
  final updatedParams = params..addEntries([MapEntry('status', 'joined')]);
  routerDelegate.currentBeamLocation.update(
    (state) => (state as BeamState).copyWith(queryParameters: updatedParams),
  );
}

final notFoundPage = Scaffold(
  body: Center(
    child: Text('This URL was not found.'),
  ),
);

BeamPage _buildBeamPage({
  required LocalKey key,
  String title = 'Frankly',
  required Widget child,
}) {
  Widget tempWidget = JuntoUiMigration(
    whiteBackground: true,
    child: InitialLoadingWidget(
      child: child,
    ),
  );

  if (isDev) {
    tempWidget = AppVersionIndicator(
      child: tempWidget,
    );
  }

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
          title: 'Frankly - Home',
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
          title: 'Frankly - Welcome',
          child: NewSpacePage(),
        ),
      ];
}

enum UserSettingsSection {
  conversations,
  profile,
  notifications,
  subscriptions,
}

class UserSettingsLocation extends BeamLocation<BeamState> {
  UserSettingsLocation({
    UserSettingsSection? initialSection,
  });

  static const sectionQueryLookup = <UserSettingsSection, String>{
    UserSettingsSection.conversations: 'conversations',
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
          title: 'Frankly - User Settings',
          child: UserSettingsPage(
            juntoId: state.queryParameters['juntoId'],
            initialSection: queryToSectionLookup[state.queryParameters['initialSection']],
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
          title: 'Frankly - Unsubscribe',
          child: EmailUnsubscribePage(data: state.queryParameters['data'] ?? ''),
        ),
      ];
}

class JuntoLocation extends BeamLocation<BeamState> {
  static const discussionIdParameter = 'discussionId';

  JuntoLocation([RouteInformation? routeInformation]) : super(routeInformation, );

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
      '/discuss/:topicId',
      '/discuss/:topicId/:$discussionIdParameter',
      '/posts',
      '/post/:discussionThreadId',
    ].map((route) => '$prefix$route').toList();
    return blueprints;
  }

  BeamPage _getJuntoBeamPage({
    required String key,
    required String displayId,
    required Widget child,
    String? title,
    bool fillViewport = false,
    bool isCreateConversationFabVisible = false,
  }) {
    return _buildBeamPage(
      key: ValueKey(key),
      title: title ?? 'Frankly',
      child: JuntoPage.create(
        displayId: displayId,
        fillViewport: fillViewport,
        isCreateConversationFabVisible: isCreateConversationFabVisible,
        content: child,
      ),
    );
  }

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final displayId = state.pathParameters['displayId']!;
    final topicId = state.pathParameters['topicId'];

    return [
      if (state.pathPatternSegments.where((p) => p.isNotEmpty).length == 2)
        _getJuntoBeamPage(
          key: 'junto-${state.uri}',
          displayId: displayId,
          isCreateConversationFabVisible: true,
          child: JuntoHome.create(),
        )
      else if (listEndsWith(state.pathPatternSegments, ['challenge']))
        _buildBeamPage(
          key: ValueKey('instant-challenge-${state.uri}'),
          child: InstantUnifyDiscussion(
            juntoId: displayId,
            userId: state.queryParameters['userId'],
            userDisplay: state.queryParameters['userDisplay'],
            meetingId: state.queryParameters['meetingId'],
            typeformLink: state.queryParameters['typeformLink'],
            redirectUrl: state.queryParameters['redirectUrl'],
            record: state.queryParameters['record']?.toLowerCase() == 'true',
          ),
        )
      else if (listEndsWith(state.pathPatternSegments, ['instant']))
        _buildBeamPage(
          key: ValueKey('instant-${state.uri}'),
          child: InstantDiscussion(
            juntoId: displayId,
            topicId: state.queryParameters['topicId'],
            name: state.queryParameters['name'],
            meetingId: state.queryParameters['meetingId'],
            record: state.queryParameters['record'] == 'true',
          ),
        )
      else if (listEndsWith(state.pathPatternSegments, ['admin']))
        _getJuntoBeamPage(
          key: 'junto-admin-${state.uri}',
          displayId: displayId,
          child: JuntoAdmin(tab: state.queryParameters['tab']),
        )
      else if (listEndsWith(state.pathPatternSegments, ['discuss', 'upcoming']))
        _getJuntoBeamPage(
          key: 'junto-$displayId-discuss-upcoming',
          displayId: displayId,
          child: DiscussionsPage.create(),
          isCreateConversationFabVisible: true,
        )
      else if (listEndsWith(state.pathPatternSegments, ['discuss']))
        _getJuntoBeamPage(
          key: 'junto-$displayId-browse-topics',
          displayId: displayId,
          child: BrowseTopicsPage(),
          isCreateConversationFabVisible: true,
        )
      else if (listEndsWith(state.pathPatternSegments, ['resources']))
        _getJuntoBeamPage(
          key: 'junto-$displayId-resources',
          displayId: displayId,
          child: JuntoResources(),
        )
      else if (state.pathPatternSegments.contains('discuss') &&
          state.pathPatternSegments.length == 4)
        _getJuntoBeamPage(
          key: 'junto-$displayId-topic-$topicId',
          displayId: displayId,
          child: TopicPage.create(topicId: topicId ?? ''),
        )
      else if (state.pathPatternSegments.contains('discuss') &&
          state.pathPatternSegments.length == 5)
        _getJuntoBeamPage(
          key: 'junto-$displayId-topic-$topicId-${state.pathParameters['discussionId']}',
          displayId: displayId,
          child: DiscussionPage(
            topicId: topicId!,
            discussionId: state.pathParameters['discussionId']!,
            cancel: state.queryParameters['cancel'] == 'true',
            uid: state.queryParameters['uid'],
          ).create(),
        )
      // [junto, :displayId, posts]
      else if (state.pathPatternSegments.contains('posts') && state.pathPatternSegments.length == 3)
        _getJuntoBeamPage(
          key: 'junto-$displayId-discussionThreads',
          displayId: displayId,
          fillViewport: false,
          child: DiscussionThreadsPage(),
        )
      // [junto, :displayId, post, :discussionThreadId]
      else if (state.pathPatternSegments.contains('post') && state.pathPatternSegments.length == 4)
        _getJuntoBeamPage(
          key: 'junto-$displayId-discussionThread-${state.pathParameters['discussionThreadId']}',
          displayId: displayId,
          fillViewport: true,
          child: DiscussionThreadPage(
            discussionThreadId: state.pathParameters['discussionThreadId']!,
            scrollToComments: false,
          ),
        )
    ];
  }
}

class JuntoPageRoutes {
  final String juntoDisplayId;

  JuntoPageRoutes({required this.juntoDisplayId});

  String get prefix => '/space/$juntoDisplayId';

  JuntoLocation get juntoHome => _getLocation(path: prefix);

  JuntoLocation get juntoChat => _getLocation(path: '$prefix/discuss/chat');

  JuntoLocation get discussionThreadsPage => _getLocation(path: '$prefix/posts');

  JuntoLocation get discussionsPage => _getLocation(path: '$prefix/discuss/upcoming');

  JuntoLocation get resourcesPage => _getLocation(path: '$prefix/resources');

  JuntoLocation get browseTopicsPage => _getLocation(path: '$prefix/discuss');

  JuntoLocation juntoAdmin({String? tab}) => _getLocation(
        path: '$prefix/admin',
        queryParameters: tab != null ? {'tab': tab} : null,
      );

  JuntoLocation topicPage({required String topicId}) => _getLocation(
        path: '$prefix/discuss/$topicId',
      );

  JuntoLocation discussionThreadPage({
    required String discussionThreadId,
    bool scrollToComments = false,
  }) {
    return _getLocation(
      path: '$prefix/post/$discussionThreadId',
    );
  }

  JuntoLocation instantPage({
    required String meetingId,
  }) {
    return _getLocation(
      path: '$prefix/instant',
      queryParameters: {'meetingId': meetingId},
    );
  }

  JuntoLocation discussionPage({required String topicId, required String discussionId}) =>
      _getLocation(
        path: '$prefix/discuss/$topicId/$discussionId',
      );

  JuntoLocation _getLocation({
    required String path,
    Map<String, String>? queryParameters,
  }) {
    final location = Uri(path: path, queryParameters: queryParameters);
    return JuntoLocation(RouteInformation(uri: location));
  }
}

class CheckCurrentLocation {
  static String get _currentPath =>
      (routerDelegate.currentBeamLocation.state as BeamState).pathPatternSegments.join('/');

  static bool get isJuntoRoute => _currentPath.split('/').first == 'space';

  static bool get isJuntoHomePage => _currentPath == 'space/:displayId';

  static bool get isJuntoSchedulePage => _currentPath == 'space/:displayId/discuss/upcoming';

  static bool get isJuntoTopicsPage => _currentPath == 'space/:displayId/discuss';

  static bool get isJuntoResourcesPage => _currentPath == 'space/:displayId/resources';

  static bool get isJuntoAdminPage => _currentPath == 'space/:displayId/admin';

  static bool get isDiscussionThreadsPage => _currentPath == 'space/:displayId/posts';

  static bool get isDiscussionThreadPage =>
      _currentPath == 'space/:displayId/post/:discussionThreadId';

  static bool get isDiscussionPage =>
      _currentPath == 'space/:displayId/discuss/:topicId/:discussionId';

  static bool get isTopicPage => _currentPath == 'space/:displayId/discuss/:topicId';

  static bool get isInstantPage => _currentPath == 'space/:displayId/instant';

  static bool get isUnifyAmericaPage => _currentPath == 'space/:displayId/challenge';
}
