import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_discussion_dialog/pre_post_discussion_dialog_presenter.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/pre_post_url_params.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockBuildContext mockBuildContext = MockBuildContext();
  final MockPrePostDiscussionDialogView mockView = MockPrePostDiscussionDialogView();
  final MockPrePostDiscussionDialogModel mockModel = MockPrePostDiscussionDialogModel();
  final MockPrePostDiscussionDialogPresenterHelper mockHelper =
      MockPrePostDiscussionDialogPresenterHelper();
  final MockResponsiveLayoutService mockResponsiveLayoutService = MockResponsiveLayoutService();
  final MockUserAdminDetailsProvider mockUserAdminDetailsProvider = MockUserAdminDetailsProvider();
  final MockUserService mockUserService = MockUserService();

  late PrePostDiscussionDialogPresenter presenter;

  setUp(() {
    presenter = PrePostDiscussionDialogPresenter(
      mockModel,
      helper: mockHelper,
      testResponsiveLayoutService: mockResponsiveLayoutService,
      userAdminDetailsProvider: mockUserAdminDetailsProvider,
    );

    when(mockModel.discussion).thenReturn(Discussion(
      id: 'test-discussion-id',
      collectionPath: 'discussionCollectionPath',
      creatorId: 'userId',
      juntoId: 'juntoId',
      topicId: 'topicId',
      status: DiscussionStatus.active,
    ));

    GetIt.instance.registerSingleton<UserService>(mockUserService);
    when(mockUserService.currentUserId).thenReturn('userId');
    when(mockUserAdminDetailsProvider.getInfoFuture())
        .thenAnswer((_) => Future.value(UserAdminDetails(email: 'user@email.com')));
  });

  tearDown(() {
    GetIt.instance.reset();

    reset(mockBuildContext);
    reset(mockView);
    reset(mockModel);
    reset(mockHelper);
    reset(mockResponsiveLayoutService);
    reset(mockUserAdminDetailsProvider);
    reset(mockUserService);
  });

  group('isMobile', () {
    test('true', () {
      when(mockResponsiveLayoutService.isMobile(mockBuildContext)).thenReturn(true);

      final result = presenter.isMobile(mockBuildContext);

      expect(result, isTrue);
    });

    test('false', () {
      when(mockResponsiveLayoutService.isMobile(mockBuildContext)).thenReturn(false);

      final result = presenter.isMobile(mockBuildContext);

      expect(result, isFalse);
    });
  });

  group('getSize', () {
    test('without scale param', () {
      when(mockResponsiveLayoutService.getDynamicSize(mockBuildContext, 100)).thenReturn(10);

      final result = presenter.getSize(mockBuildContext, 100);

      expect(result, 10);
    });

    test('without scale param', () {
      when(
        mockResponsiveLayoutService.getDynamicSize(mockBuildContext, 100, scale: 10),
      ).thenReturn(200);

      final result = presenter.getSize(mockBuildContext, 100, scale: 10);

      expect(result, 200);
    });
  });

  group('launchSurvey', () {
    test('surveyUrl is null', () async {
      final prePostUrls = [PrePostUrlParams(attributes: [])];
      final prePostCard =
          PrePostCard.newCard(PrePostCardType.preEvent).copyWith(prePostUrls: prePostUrls);
      when(mockModel.prePostCard).thenReturn(prePostCard);

      await presenter.launchSurvey(prePostUrls[0]);

      verifyNever(mockHelper.launchUrl(any, any));
    });

    test('surveyUrl is not null', () async {
      final prePostUrls = [PrePostUrlParams(surveyUrl: 'surveyUrl', attributes: [])];
      final prePostCard =
          PrePostCard.newCard(PrePostCardType.preEvent).copyWith(prePostUrls: prePostUrls);
      when(mockModel.prePostCard).thenReturn(prePostCard);

      await presenter.launchSurvey(prePostUrls[0]);

      verify(mockHelper.launchUrl('surveyUrl', any)).called(1);
    });
  });
}
