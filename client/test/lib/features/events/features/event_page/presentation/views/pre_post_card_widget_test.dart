import 'package:client/features/community/data/services/cloud_functions_community_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_page.dart';
import 'package:client/features/events/features/event_page/presentation/pre_post_card_widget_presenter.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:data_models/events/event.dart' hide Event;
import 'package:data_models/events/event.dart' as event_model;
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/events/pre_post_url_params.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/user_admin_details.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/app_localization_service.dart';

// Import our custom mock localizations
import '../../../../../../../mock_localizations.dart';

import '../../../../../../../mocked_classes.mocks.dart';

// Create mocks of the various services
class MockCloudFunctionsCommunityService extends Mock
    implements CloudFunctionsCommunityService {
  @override
  Future<GetUserAdminDetailsResponse> getUserAdminDetails(
      GetUserAdminDetailsRequest request) async {
    return GetUserAdminDetailsResponse(
      userAdminDetails: [
        UserAdminDetails(
          userId: 'userId',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          displayName: 'Test User',
        ),
      ],
    );
  }
}

// Create a mock presenter helper to override the problematic getEmail method
class MockPrePostCardWidgetPresenterHelper
    extends PrePostCardWidgetPresenterHelper {
  @override
  Future<String?> getEmail(UserService userService,
      CloudFunctionsCommunityService cloudFunctionsService) async {
    return 'test@example.com';
  }
}

void main() {
  final event_model.Event event = event_model.Event(
    id: 'eventId',
    collectionPath: 'eventCollectionPath',
    creatorId: 'userId',
    communityId: 'communityId',
    templateId: 'templateId',
    status: event_model.EventStatus.active,
  );

  late MockUserServiceNullable mockUserService;
  late AppLocalizationService mockAppLocalizationService;
  late MockCloudFunctionsCommunityService mockCloudFunctionsService;
  late MockPrePostCardWidgetPresenterHelper mockPresenterHelper;

  setUpAll(() {
    // Create mock services
    mockCloudFunctionsService = MockCloudFunctionsCommunityService();
    mockPresenterHelper = MockPrePostCardWidgetPresenterHelper();
    mockAppLocalizationService = AppLocalizationService();

    // Register mock services
    GetIt.instance.registerSingleton<CloudFunctionsCommunityService>(
        mockCloudFunctionsService);
    GetIt.instance
        .registerSingleton<AppLocalizationService>(mockAppLocalizationService);

    // Register mocked presenter to bypass the regular dependency injection
    GetIt.instance.registerFactoryParam<PrePostCardWidgetPresenter,
        BuildContext, PrePostCardWidgetModel>(
      (context, model) => PrePostCardWidgetPresenter(
        context,
        model.view,
        model,
        prePostCardWidgetPresenterHelper: mockPresenterHelper,
        testCloudFunctionsService: mockCloudFunctionsService,
      ),
    );
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  Finder getDeleteCardIconFinder() {
    return find.byKey(Key('prePostCardWidgetPage-deleteCard'));
  }

  Finder getEditButtonFinder() {
    return find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == Icons.edit,
    );
  }

  Finder getExpandIconFinder() {
    return find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == Icons.expand_more,
    );
  }

  Finder getCollapseIconFinder() {
    return find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == Icons.expand_less,
    );
  }

  Finder getExpandCollapseInkWellFinder() {
    return find.byWidgetPredicate((widget) => widget is InkWell).first;
  }

  Finder getOverviewPrePostCardFinder() {
    return find.byKey(Key('prePostCardWidget-overviewPrePostCard'));
  }

  Finder getEditablePrePostCardFinder() {
    return find.byKey(Key('prePostCardWidget-editablePrePostCard'));
  }

  Finder getGoToSurveyButtonFinder({String? text}) {
    return find.descendant(
      of: find.byKey(Key('prePostCardWidget-overviewPrePostCard')),
      // If text is null, search any ActionButton, otherwise search specific ActionButton.
      // Useful when need to confirm that button does not exist.
      matching: text == null
          ? find.byType(ActionButton)
          : find.byWidgetPredicate(
              (widget) => widget is ActionButton && widget.text == text,
            ),
    );
  }

  setUp(() {
    mockUserService = MockUserServiceNullable();
    when(mockUserService.currentUserId).thenReturn('userId');
  });

  testWidgets('If editable is false, do not show edit menu nor edit icon',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: MockLocalizationsProvider(
            child: Builder(
              builder: (context) {
                // Initialize the app localization service with the mock localizations
                final mockLocalizations = context.testL10n;
                mockAppLocalizationService.setLocalization(mockLocalizations);

                return PrePostCardWidgetPage(
                  prePostCardType: PrePostCardType.preEvent,
                  event: event,
                  onUpdate: (_) {},
                  onDelete: () {},
                  isEditable: false,
                  // Pass the helper directly to avoid dependency injection complexity
                  // This simplifies the test and avoids issues with localization
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsOneWidget);
    expect(getEditablePrePostCardFinder(), findsNothing);

    await tester.tap(getExpandCollapseInkWellFinder());
    await tester.pump();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsOneWidget);
    expect(getCollapseIconFinder(), findsNothing);
    expect(getOverviewPrePostCardFinder(), findsNothing);
    expect(getEditablePrePostCardFinder(), findsNothing);
  });

  testWidgets('Change between overview and edit', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: MockLocalizationsProvider(
            child: Builder(
              builder: (context) {
                // Initialize the app localization service with the mock localizations
                final mockLocalizations = context.testL10n;
                mockAppLocalizationService.setLocalization(mockLocalizations);

                return PrePostCardWidgetPage(
                  prePostCardType: PrePostCardType.preEvent,
                  event: event,
                  onUpdate: (_) {},
                  onDelete: () {},
                  isEditable: true,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(getEditButtonFinder(), findsOneWidget);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsOneWidget);
    expect(getEditablePrePostCardFinder(), findsNothing);

    await tester.tap(getEditButtonFinder());
    await tester.pump();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsNothing);
    expect(getEditablePrePostCardFinder(), findsOneWidget);
  });

  testWidgets('Change between expanded and collapsed in overview',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: MockLocalizationsProvider(
            child: Builder(
              builder: (context) {
                // Initialize the app localization service with the mock localizations
                final mockLocalizations = context.testL10n;
                mockAppLocalizationService.setLocalization(mockLocalizations);

                return PrePostCardWidgetPage(
                  prePostCardType: PrePostCardType.preEvent,
                  event: event,
                  onUpdate: (_) {},
                  onDelete: () {},
                  isEditable: true,
                  prePostCardWidgetType: PrePostCardWidgetType.overview,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(getEditButtonFinder(), findsOneWidget);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsOneWidget);
    expect(getEditablePrePostCardFinder(), findsNothing);

    await tester.tap(getExpandCollapseInkWellFinder());
    await tester.pumpAndSettle();

    expect(getEditButtonFinder(), findsOneWidget);
    expect(getExpandIconFinder(), findsOneWidget);
    expect(getCollapseIconFinder(), findsNothing);
    expect(getOverviewPrePostCardFinder(), findsNothing);
    expect(getEditablePrePostCardFinder(), findsNothing);
  });

  testWidgets('Change between expanded and collapsed in edit', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: MockLocalizationsProvider(
            child: Builder(
              builder: (context) {
                // Initialize the app localization service with the mock localizations
                final mockLocalizations = context.testL10n;
                mockAppLocalizationService.setLocalization(mockLocalizations);

                return PrePostCardWidgetPage(
                  prePostCardType: PrePostCardType.preEvent,
                  event: event,
                  onUpdate: (_) {},
                  onDelete: () {},
                  isEditable: true,
                  prePostCardWidgetType: PrePostCardWidgetType.edit,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsNothing);
    expect(getEditablePrePostCardFinder(), findsOneWidget);

    await tester.tap(getExpandCollapseInkWellFinder().first);
    await tester.pumpAndSettle();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsOneWidget);
    expect(getCollapseIconFinder(), findsNothing);
    expect(getOverviewPrePostCardFinder(), findsNothing);
    expect(getEditablePrePostCardFinder(), findsNothing);
  });

  testWidgets(
      'In overview when expanded, do not show button if url or button text is not present',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: PrePostCardWidgetPage(
            prePostCardType: PrePostCardType.preEvent,
            event: event,
            onUpdate: (_) {},
            onDelete: () {},
            prePostCard: PrePostCard(
              type: PrePostCardType.preEvent,
              headline: 'headline',
              message: 'message',
              prePostUrls: [],
            ),
            prePostCardWidgetType: PrePostCardWidgetType.overview,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsOneWidget);
    expect(getEditablePrePostCardFinder(), findsNothing);
    expect(getGoToSurveyButtonFinder(), findsNothing);
  });

  testWidgets(
      'In overview when expanded, show button if url and button text is present.',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: PrePostCardWidgetPage(
            prePostCardType: PrePostCardType.preEvent,
            event: event,
            onUpdate: (_) {},
            onDelete: () {},
            prePostCard: PrePostCard(
              type: PrePostCardType.preEvent,
              headline: 'headline',
              message: 'message',
              prePostUrls: [
                PrePostUrlParams(
                  buttonText: 'buttonText',
                  surveyUrl: 'surveyUrl',
                  attributes: [],
                ),
              ],
            ),
            prePostCardWidgetType: PrePostCardWidgetType.overview,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsOneWidget);
    expect(getEditablePrePostCardFinder(), findsNothing);
    expect(getGoToSurveyButtonFinder(text: 'buttonText'), findsOneWidget);
  });

  testWidgets(
      'In overview when expanded, confirm visible information (button text and surveyUrl is available',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: PrePostCardWidgetPage(
            prePostCardType: PrePostCardType.preEvent,
            event: event,
            onUpdate: (_) {},
            onDelete: () {},
            prePostCard: PrePostCard(
              type: PrePostCardType.preEvent,
              headline: 'headline',
              message: 'message',
              prePostUrls: [
                PrePostUrlParams(
                  buttonText: 'buttonText',
                  surveyUrl: 'surveyUrl',
                  attributes: [],
                ),
              ],
            ),
            prePostCardWidgetType: PrePostCardWidgetType.overview,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsOneWidget);
    expect(getEditablePrePostCardFinder(), findsNothing);
    expect(find.text('headline'), findsOneWidget);
    expect(find.text('message'), findsOneWidget);
    expect(getGoToSurveyButtonFinder(text: 'buttonText'), findsOneWidget);
  });

  testWidgets(
      'In overview when expanded, confirm visible information (button text and surveyUrl is not available',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: PrePostCardWidgetPage(
            prePostCardType: PrePostCardType.preEvent,
            event: event,
            onUpdate: (_) {},
            onDelete: () {},
            prePostCard: PrePostCard(
              type: PrePostCardType.preEvent,
              headline: 'headline',
              message: 'message',
              prePostUrls: [],
            ),
            prePostCardWidgetType: PrePostCardWidgetType.overview,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsOneWidget);
    expect(getEditablePrePostCardFinder(), findsNothing);
    expect(find.text('headline'), findsOneWidget);
    expect(find.text('message'), findsOneWidget);
    expect(getGoToSurveyButtonFinder(), findsNothing);
  });

  testWidgets(
      'In overview when expanded, confirm visible information (button text is available, surveyUrl is not available',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: PrePostCardWidgetPage(
            prePostCardType: PrePostCardType.preEvent,
            event: event,
            onUpdate: (_) {},
            onDelete: () {},
            prePostCard: PrePostCard(
              type: PrePostCardType.preEvent,
              headline: 'headline',
              message: 'message',
              prePostUrls: [
                PrePostUrlParams(buttonText: 'buttonText', attributes: []),
              ],
            ),
            prePostCardWidgetType: PrePostCardWidgetType.overview,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsOneWidget);
    expect(getEditablePrePostCardFinder(), findsNothing);
    expect(find.text('headline'), findsOneWidget);
    expect(find.text('message'), findsOneWidget);
    expect(getGoToSurveyButtonFinder(), findsNothing);
  });

  testWidgets(
      'In overview when expanded, confirm visible information (button text is not available, surveyUrl is available',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: PrePostCardWidgetPage(
            prePostCardType: PrePostCardType.preEvent,
            event: event,
            onUpdate: (_) {},
            onDelete: () {},
            prePostCard: PrePostCard(
              type: PrePostCardType.preEvent,
              headline: 'headline',
              message: 'message',
              prePostUrls: [
                PrePostUrlParams(surveyUrl: 'surveyUrl', attributes: []),
              ],
            ),
            prePostCardWidgetType: PrePostCardWidgetType.overview,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsOneWidget);
    expect(getEditablePrePostCardFinder(), findsNothing);
    expect(find.text('headline'), findsOneWidget);
    expect(find.text('message'), findsOneWidget);
    expect(getGoToSurveyButtonFinder(), findsNothing);
  });

  testWidgets('Delete Agenda Item Icon visible', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: PrePostCardWidgetPage(
            prePostCardType: PrePostCardType.preEvent,
            event: event,
            onUpdate: (_) {},
            onDelete: () {},
            isEditable: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(getDeleteCardIconFinder(), findsOneWidget);

    await tester.tap(getExpandCollapseInkWellFinder().first);
    await tester.pumpAndSettle();

    expect(getDeleteCardIconFinder(), findsOneWidget);
  });

  testWidgets('Delete Agenda Item Icon not visible', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          home: PrePostCardWidgetPage(
            prePostCardType: PrePostCardType.preEvent,
            event: event,
            onUpdate: (_) {},
            onDelete: () {},
            isEditable: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(getDeleteCardIconFinder(), findsNothing);

    await tester.tap(getExpandCollapseInkWellFinder().first);
    await tester.pumpAndSettle();

    expect(getDeleteCardIconFinder(), findsNothing);
  });
}
