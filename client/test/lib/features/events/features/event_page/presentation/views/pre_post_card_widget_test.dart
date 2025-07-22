import 'package:client/features/community/data/services/cloud_functions_community_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_page.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/events/pre_post_url_params.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:client/core/localization/app_localization_service.dart';
import 'package:client/services.dart';
import 'package:data_models/cloud_functions/requests.dart';

import '../../../../../../../mocked_classes.mocks.dart';
import '../../../../../../../test_helpers.dart';

void main() {
  setUpAll(() async {
    await GetIt.instance.reset();
    TestHelpers.setupLocalizationForTests();
    if (!GetIt.instance.isRegistered<CloudFunctionsCommunityService>()) {
      GetIt.instance.registerSingleton(CloudFunctionsCommunityService());
    }
  });
  
  tearDownAll(() async {
    await GetIt.instance.reset();
    await TestHelpers.cleanupAfterTests();
  });

  tearDown(() async {
    if (GetIt.instance.isRegistered<CloudFunctionsCommunityService>()) {
      GetIt.instance.unregister<CloudFunctionsCommunityService>();
    }
  });
  final Event event = Event(
    id: 'eventId',
    collectionPath: 'eventCollectionPath',
    creatorId: 'userId',
    communityId: 'communityId',
    templateId: 'templateId',
    status: EventStatus.active,
  );

  late MockUserServiceNullable mockUserService;

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
    // Try finding IconButton by type first
    final iconButtons = find.byType(IconButton);
    if (iconButtons.evaluate().isNotEmpty) {
      // If there are multiple IconButtons, find the one with expand/collapse icons
      for (final element in iconButtons.evaluate()) {
        final widget = element.widget as IconButton;
        if (widget.icon is Icon) {
          final icon = widget.icon as Icon;
          if (icon.icon == Icons.expand_more || icon.icon == Icons.expand_less) {
            return find.byWidget(widget);
          }
        }
      }
      // If no specific expand/collapse icon found, return the last IconButton
      return iconButtons.last;
    }
    return iconButtons;
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
    
    // Mock CloudFunctionsCommunityService to return userAdminDetails
    final mockCloudFunctionsService = MockCloudFunctionsCommunityService();
    when(mockCloudFunctionsService.getUserAdminDetails(any)).thenAnswer((_) async => 
      GetUserAdminDetailsResponse(userAdminDetails: [UserAdminDetails(email: 'test@email.com')]),);
    
    // Register the mock service if not already registered
    if (GetIt.instance.isRegistered<CloudFunctionsCommunityService>()) {
      GetIt.instance.unregister<CloudFunctionsCommunityService>();
    }
    GetIt.instance.registerSingleton<CloudFunctionsCommunityService>(mockCloudFunctionsService);
  });

  testWidgets('If editable is false, do not show edit menu nor edit icon',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserService>(create: (_) => mockUserService),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: PrePostCardWidgetPage(
            prePostCardType: PrePostCardType.preEvent,
            event: event,
            onUpdate: (_) {},
            onDelete: () {},
            isEditable: true,
            prePostCardWidgetType: PrePostCardWidgetType.overview,
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              // Initialize the app localization service
              final localizations = AppLocalizations.of(context)!;
              appLocalizationService.setLocalization(localizations);
              
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
    );

    await tester.pumpAndSettle();
    
    // Wait for localization to be fully initialized
    await tester.pump();

    expect(getEditButtonFinder(), findsNothing);
    expect(getExpandIconFinder(), findsNothing);
    expect(getCollapseIconFinder(), findsOneWidget);
    expect(getOverviewPrePostCardFinder(), findsNothing);
    expect(getEditablePrePostCardFinder(), findsOneWidget);

    // Find the expand/collapse icon specifically by its icon type
    final expandCollapseButton = find.byIcon(Icons.expand_less);
    expect(expandCollapseButton, findsOneWidget);
    
    await tester.tap(expandCollapseButton);
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
    
    // Wait for localization to be fully initialized
    await tester.pump();

    expect(getDeleteCardIconFinder(), findsOneWidget);

    expect(getExpandCollapseInkWellFinder(), findsAtLeastNWidgets(1));
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
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
    
    // Wait for localization to be fully initialized
    await tester.pump();

    expect(getDeleteCardIconFinder(), findsNothing);

    expect(getExpandCollapseInkWellFinder(), findsAtLeastNWidgets(1));
    await tester.tap(getExpandCollapseInkWellFinder().first);
    await tester.pumpAndSettle();

    expect(getDeleteCardIconFinder(), findsNothing);
  });
}
