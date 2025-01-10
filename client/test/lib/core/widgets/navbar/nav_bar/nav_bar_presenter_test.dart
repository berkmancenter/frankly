import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/widgets/navbar/nav_bar/nav_bar_model.dart';
import 'package:client/core/widgets/navbar/nav_bar/nav_bar_presenter.dart';
import 'package:data_models/community/community.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockContext = MockBuildContext();
  final mockView = MockNavBarView();
  final mockCommunityPermissionsProvider = MockCommunityPermissionsProvider();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockUserService = MockUserService();
  final mockCommunityProvider = MockCommunityProvider();
  final mockSharedPreferencesService = MockSharedPreferencesService();
  final mockGlobalKey = MockGlobalKey();
  final mockRenderBox = MockRenderBox();
  final mockPaymentUtils = MockPaymentUtils();
  final mockCloudFunctionsService = MockCloudFunctionsPaymentsService();
  final mockFirestoreAgreementsService = MockFirestoreAgreementsService();
  final mockPartnerAgreement = MockPartnerAgreement();
  final mockCommunitySettings = MockCommunitySettings();

  late NavBarModel model;
  late NavBarPresenter presenter;

  setUp(() {
    model = NavBarModel(adminButtonKey: mockGlobalKey);
    presenter = NavBarPresenter(
      mockContext,
      mockView,
      model,
      communityPermissionsProvider: mockCommunityPermissionsProvider,
      responsiveLayoutService: mockResponsiveLayoutService,
      userService: mockUserService,
      communityProvider: mockCommunityProvider,
      sharedPreferencesService: mockSharedPreferencesService,
      paymentUtils: mockPaymentUtils,
      cloudFunctionsService: mockCloudFunctionsService,
      firestoreAgreementsService: mockFirestoreAgreementsService,
    );
  });

  tearDown(() {
    reset(mockContext);
    reset(mockView);
    reset(mockCommunityPermissionsProvider);
    reset(mockResponsiveLayoutService);
    reset(mockUserService);
    reset(mockCommunityProvider);
    reset(mockSharedPreferencesService);
    reset(mockGlobalKey);
    reset(mockRenderBox);
    reset(mockPaymentUtils);
    reset(mockCloudFunctionsService);
    reset(mockFirestoreAgreementsService);
    reset(mockPartnerAgreement);
    reset(mockCommunitySettings);
  });

  group('init', () {
    test('true', () {
      when(mockSharedPreferencesService.isOnboardingOverviewTooltipShown())
          .thenReturn(true);

      presenter.init();

      expect(model.isOnboardingTooltipShown, isTrue);
      verify(mockView.updateView()).called(1);
    });

    test('false', () {
      when(mockSharedPreferencesService.isOnboardingOverviewTooltipShown())
          .thenReturn(false);

      presenter.init();

      expect(model.isOnboardingTooltipShown, isFalse);
      verify(mockView.updateView()).called(1);
    });
  });

  group('isCommunityLocation', () {}, skip: 'cannot test due to global usage');

  group('isCommunityHomePage', () {}, skip: 'cannot test due to global usage');

  group('canViewCommunityLinks', () {
    test(
      'provider is null',
      () {},
      skip:
          'current framework does not work well with nullable provider/service',
    );

    test('true', () {
      when(mockCommunityPermissionsProvider.canViewCommunityLinks)
          .thenReturn(true);

      final result = presenter.canViewCommunityLinks();

      expect(result, isTrue);
    });

    test('false', () {
      when(mockCommunityPermissionsProvider.canViewCommunityLinks)
          .thenReturn(false);

      final result = presenter.canViewCommunityLinks();

      expect(result, isFalse);
    });
  });

  group('showBottomNavBar', () {
    test('true', () {
      when(mockResponsiveLayoutService.showBottomNavBar(mockContext))
          .thenReturn(true);

      final result = presenter.showBottomNavBar(mockContext);

      expect(result, isTrue);
    });

    test('false', () {
      when(mockResponsiveLayoutService.showBottomNavBar(mockContext))
          .thenReturn(false);

      final result = presenter.showBottomNavBar(mockContext);

      expect(result, isFalse);
    });
  });

  group('isMobile', () {
    test('true', () {
      when(mockResponsiveLayoutService.isMobile(mockContext)).thenReturn(true);

      final result = presenter.isMobile(mockContext);

      expect(result, isTrue);
    });

    test('false', () {
      when(mockResponsiveLayoutService.isMobile(mockContext)).thenReturn(false);

      final result = presenter.isMobile(mockContext);

      expect(result, isFalse);
    });
  });

  group('isSignedIn', () {
    test('true', () {
      when(mockUserService.isSignedIn).thenReturn(true);

      final result = presenter.isSignedIn();

      expect(result, isTrue);
    });

    test('false', () {
      when(mockUserService.isSignedIn).thenReturn(false);

      final result = presenter.isSignedIn();

      expect(result, isFalse);
    });
  });

  group('getCurrentOnboardingStep', () {
    test(
      'provider is null',
      () {
        presenter = NavBarPresenter(
          mockContext,
          mockView,
          model,
          communityProvider: null,
        );

        final result = presenter.getCurrentOnboardingStep();

        expect(result, isNull);
      },
      skip:
          'current framework does not work well with nullable provider/service',
    );

    test('success', () {
      final onboardingStep = OnboardingStep
          .values[Random().nextInt(OnboardingStep.values.length - 1)];
      when(mockCommunityProvider.getCurrentOnboardingStep())
          .thenReturn(onboardingStep);

      final result = presenter.getCurrentOnboardingStep();

      expect(result, onboardingStep);
    });
  });

  test('closeOnboardingTooltip', () async {
    model.isOnboardingTooltipShown = true;
    when(
      mockSharedPreferencesService
          .updateOnboardingOverviewTooltipVisibility(false),
    ).thenAnswer((_) async => true);

    presenter.closeOnboardingTooltip();

    verify(
      mockSharedPreferencesService
          .updateOnboardingOverviewTooltipVisibility(false),
    ).called(1);
    expect(model.isOnboardingTooltipShown, isFalse);
    verify(mockView.updateView()).called(1);
  });

  group('getCompletedStepCount', () {
    test(
      'provider is null',
      () {},
      skip:
          'current framework does not work well with nullable provider/service',
    );

    test('success', () {
      final community = Community(
        id: '',
        onboardingSteps: [
          OnboardingStep.brandSpace,
          OnboardingStep.hostEvent,
        ],
      );
      when(mockCommunityProvider.community).thenReturn(community);

      final result = presenter.getCompletedStepCount();

      expect(result, 2);
    });
  });

  test('getCommunity', () {
    final community = Community(id: 'id');
    when(mockCommunityProvider.community).thenReturn(community);

    final result = presenter.getCommunity();

    expect(result, community);
  });

  group('updateAdminButtonYPosition', () {
    test('new position is different than previous position', () {
      model.adminButtonXPosition = 0.123;
      when(mockRenderBox.localToGlobal(any)).thenReturn(Offset(1.23, 2.34));
      when(mockGlobalKey.currentContext).thenReturn(mockContext);
      when(mockContext.findRenderObject()).thenReturn(mockRenderBox);

      presenter.updateAdminButtonXPosition();

      expect(model.adminButtonXPosition, 1.23);
    });

    test('new position is same as previous position', () {
      model.adminButtonXPosition = 0.123;
      when(mockRenderBox.localToGlobal(Offset.zero))
          .thenReturn(Offset(0.123, 2.34));
      when(mockGlobalKey.currentContext).thenReturn(mockContext);
      when(mockContext.findRenderObject()).thenReturn(mockRenderBox);

      presenter.updateAdminButtonXPosition();

      expect(model.adminButtonXPosition, 0.123);
    });
  });

  group(
    'isAdminButtonVisible',
    () {},
    skip: 'current framework does not work well with nullable provider/service',
  );

  group('isOnboardingOverviewEnabled', () {
    test('true', () {
      when(mockCommunityProvider.community)
          .thenReturn(Community(id: 'id', isOnboardingOverviewEnabled: true));

      final result = presenter.isOnboardingOverviewEnabled();

      expect(result, isTrue);
    });

    test('false', () {
      when(mockCommunityProvider.community)
          .thenReturn(Community(id: 'id', isOnboardingOverviewEnabled: false));

      final result = presenter.isOnboardingOverviewEnabled();

      expect(result, isFalse);
    });
  });

  test('proceedToConnectWithStripePage', () async {
    when(mockCommunityProvider.communityId).thenReturn('communityId');
    when(
      mockFirestoreAgreementsService
          .getAgreementForCommunityStream('communityId'),
    ).thenAnswer(
      (_) => Stream.fromIterable([mockPartnerAgreement]),
    );
    when(mockPartnerAgreement.id).thenReturn('agreementId');

    await presenter.proceedToConnectWithStripePage();

    verify(
      mockPaymentUtils.proceedToConnectWithStripePage(
        mockPartnerAgreement,
        'agreementId',
        mockCloudFunctionsService,
      ),
    ).called(1);
  });
}
