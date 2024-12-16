import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_page.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/services/cloud_functions_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/pre_post_url_params.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../../../../mocked_classes.mocks.dart';

void main() {
  final Discussion discussion = Discussion(
    id: 'discussionId',
    collectionPath: 'discussionCollectionPath',
    creatorId: 'userId',
    juntoId: 'juntoId',
    topicId: 'topicId',
    status: DiscussionStatus.active,
  );

  late MockUserServiceNullable mockUserService;

  setUpAll(() {
    GetIt.instance.registerSingleton(CloudFunctionsService());
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  Finder _getDeleteCardIconFinder() {
    return find.byKey(Key('prePostCardWidgetPage-deleteCard'));
  }

  Finder _getEditButtonFinder() {
    return find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.edit);
  }

  Finder _getExpandIconFinder() {
    return find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.expand_more);
  }

  Finder _getCollapseIconFinder() {
    return find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.expand_less);
  }

  Finder _getExpandCollapseInkWellFinder() {
    return find.byWidgetPredicate((widget) => widget is InkWell).first;
  }

  Finder _getOverviewPrePostCardFinder() {
    return find.byKey(Key('prePostCardWidget-overviewPrePostCard'));
  }

  Finder _getEditablePrePostCardFinder() {
    return find.byKey(Key('prePostCardWidget-editablePrePostCard'));
  }

  Finder _getGoToSurveyButtonFinder({String? text}) {
    return find.descendant(
      of: find.byKey(Key('prePostCardWidget-overviewPrePostCard')),
      // If text is null, search any ActionButton, otherwise search specific ActionButton.
      // Useful when need to confirm that button does not exist.
      matching: text == null
          ? find.byType(ActionButton)
          : find.byWidgetPredicate((widget) => widget is ActionButton && widget.text == text),
    );
  }

  setUp(() {
    mockUserService = MockUserServiceNullable();
    when(mockUserService.currentUserId).thenReturn('userId');
  });

  testWidgets('If editable is false, do not show edit menu nor edit icon', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          isEditable: false,
        ),
      ),
    ));

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsOneWidget);
    expect(_getEditablePrePostCardFinder(), findsNothing);

    await tester.tap(_getExpandCollapseInkWellFinder());
    await tester.pump();

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsOneWidget);
    expect(_getCollapseIconFinder(), findsNothing);
    expect(_getOverviewPrePostCardFinder(), findsNothing);
    expect(_getEditablePrePostCardFinder(), findsNothing);
  });

  testWidgets('Change between overview and edit', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          isEditable: true,
        ),
      ),
    ));

    expect(_getEditButtonFinder(), findsOneWidget);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsOneWidget);
    expect(_getEditablePrePostCardFinder(), findsNothing);

    await tester.tap(_getEditButtonFinder());
    await tester.pump();

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsNothing);
    expect(_getEditablePrePostCardFinder(), findsOneWidget);
  });

  testWidgets('Change between expanded and collapsed in overview', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          isEditable: true,
          prePostCardWidgetType: PrePostCardWidgetType.overview,
        ),
      ),
    ));

    expect(_getEditButtonFinder(), findsOneWidget);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsOneWidget);
    expect(_getEditablePrePostCardFinder(), findsNothing);

    await tester.tap(_getExpandCollapseInkWellFinder());
    await tester.pumpAndSettle();

    expect(_getEditButtonFinder(), findsOneWidget);
    expect(_getExpandIconFinder(), findsOneWidget);
    expect(_getCollapseIconFinder(), findsNothing);
    expect(_getOverviewPrePostCardFinder(), findsNothing);
    expect(_getEditablePrePostCardFinder(), findsNothing);
  });

  testWidgets('Change between expanded and collapsed in edit', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          isEditable: true,
          prePostCardWidgetType: PrePostCardWidgetType.edit,
        ),
      ),
    ));

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsNothing);
    expect(_getEditablePrePostCardFinder(), findsOneWidget);

    await tester.tap(_getExpandCollapseInkWellFinder().first);
    await tester.pumpAndSettle();

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsOneWidget);
    expect(_getCollapseIconFinder(), findsNothing);
    expect(_getOverviewPrePostCardFinder(), findsNothing);
    expect(_getEditablePrePostCardFinder(), findsNothing);
  });

  testWidgets('In overview when expanded, do not show button if url or button text is not present',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
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
    ));

    await tester.pumpAndSettle();

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsOneWidget);
    expect(_getEditablePrePostCardFinder(), findsNothing);
    expect(_getGoToSurveyButtonFinder(), findsNothing);
  });

  testWidgets('In overview when expanded, show button if url and button text is present.',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          prePostCard: PrePostCard(
            type: PrePostCardType.preEvent,
            headline: 'headline',
            message: 'message',
            prePostUrls: [
              PrePostUrlParams(buttonText: 'buttonText', surveyUrl: 'surveyUrl', attributes: [])
            ],
          ),
          prePostCardWidgetType: PrePostCardWidgetType.overview,
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsOneWidget);
    expect(_getEditablePrePostCardFinder(), findsNothing);
    expect(_getGoToSurveyButtonFinder(text: 'buttonText'), findsOneWidget);
  });

  testWidgets(
      'In overview when expanded, confirm visible information (button text and surveyUrl is available',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          prePostCard: PrePostCard(
            type: PrePostCardType.preEvent,
            headline: 'headline',
            message: 'message',
            prePostUrls: [
              PrePostUrlParams(buttonText: 'buttonText', surveyUrl: 'surveyUrl', attributes: [])
            ],
          ),
          prePostCardWidgetType: PrePostCardWidgetType.overview,
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsOneWidget);
    expect(_getEditablePrePostCardFinder(), findsNothing);
    expect(find.text('headline'), findsOneWidget);
    expect(find.text('message'), findsOneWidget);
    expect(_getGoToSurveyButtonFinder(text: 'buttonText'), findsOneWidget);
  });

  testWidgets(
      'In overview when expanded, confirm visible information (button text and surveyUrl is not available',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
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
    ));

    await tester.pumpAndSettle();

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsOneWidget);
    expect(_getEditablePrePostCardFinder(), findsNothing);
    expect(find.text('headline'), findsOneWidget);
    expect(find.text('message'), findsOneWidget);
    expect(_getGoToSurveyButtonFinder(), findsNothing);
  });

  testWidgets(
      'In overview when expanded, confirm visible information (button text is available, surveyUrl is not available',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          prePostCard: PrePostCard(
            type: PrePostCardType.preEvent,
            headline: 'headline',
            message: 'message',
            prePostUrls: [PrePostUrlParams(buttonText: 'buttonText', attributes: [])],
          ),
          prePostCardWidgetType: PrePostCardWidgetType.overview,
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsOneWidget);
    expect(_getEditablePrePostCardFinder(), findsNothing);
    expect(find.text('headline'), findsOneWidget);
    expect(find.text('message'), findsOneWidget);
    expect(_getGoToSurveyButtonFinder(), findsNothing);
  });

  testWidgets(
      'In overview when expanded, confirm visible information (button text is not available, surveyUrl is available',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          prePostCard: PrePostCard(
            type: PrePostCardType.preEvent,
            headline: 'headline',
            message: 'message',
            prePostUrls: [PrePostUrlParams(surveyUrl: 'surveyUrl', attributes: [])],
          ),
          prePostCardWidgetType: PrePostCardWidgetType.overview,
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(_getEditButtonFinder(), findsNothing);
    expect(_getExpandIconFinder(), findsNothing);
    expect(_getCollapseIconFinder(), findsOneWidget);
    expect(_getOverviewPrePostCardFinder(), findsOneWidget);
    expect(_getEditablePrePostCardFinder(), findsNothing);
    expect(find.text('headline'), findsOneWidget);
    expect(find.text('message'), findsOneWidget);
    expect(_getGoToSurveyButtonFinder(), findsNothing);
  });

  testWidgets('Delete Agenda Item Icon visible', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          isEditable: true,
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(_getDeleteCardIconFinder(), findsOneWidget);

    await tester.tap(_getExpandCollapseInkWellFinder().first);
    await tester.pumpAndSettle();

    expect(_getDeleteCardIconFinder(), findsOneWidget);
  });

  testWidgets('Delete Agenda Item Icon not visible', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider<UserService>(create: (_) => mockUserService)],
      child: MaterialApp(
        home: PrePostCardWidgetPage(
          prePostCardType: PrePostCardType.preEvent,
          discussion: discussion,
          onUpdate: (_) {},
          onDelete: () {},
          isEditable: false,
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(_getDeleteCardIconFinder(), findsNothing);

    await tester.tap(_getExpandCollapseInkWellFinder().first);
    await tester.pumpAndSettle();

    expect(_getDeleteCardIconFinder(), findsNothing);
  });
}
