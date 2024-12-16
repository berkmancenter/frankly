import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:junto/common_widgets/navbar/nav_bar/nav_bar_model.dart';
import 'package:junto/common_widgets/navbar/nav_bar/nav_bar_presenter.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:mockito/mockito.dart';
import '../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockContext = MockBuildContext();
  final mockView = MockNavBarView();
  final mockCommunityPermissionsProvider = MockCommunityPermissionsProvider();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockUserService = MockUserService();
  final mockJuntoProvider = MockJuntoProvider();
  final mockSharedPreferencesService = MockSharedPreferencesService();
  final mockGlobalKey = MockGlobalKey();
  final mockRenderBox = MockRenderBox();
  final mockPaymentUtils = MockPaymentUtils();
  final mockCloudFunctionsService = MockCloudFunctionsService();
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
      juntoProvider: mockJuntoProvider,
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
    reset(mockJuntoProvider);
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
      when(mockSharedPreferencesService.isOnboardingOverviewTooltipShown()).thenReturn(true);

      presenter.init();

      expect(model.isOnboardingTooltipShown, isTrue);
      verify(mockView.updateView()).called(1);
    });

    test('false', () {
      when(mockSharedPreferencesService.isOnboardingOverviewTooltipShown()).thenReturn(false);

      presenter.init();

      expect(model.isOnboardingTooltipShown, isFalse);
      verify(mockView.updateView()).called(1);
    });
  });

  group('isJuntoLocation', () {}, skip: 'cannot test due to global usage');

  group('isJuntoHomePage', () {}, skip: 'cannot test due to global usage');

  group('canViewCommunityLinks', () {
    test('provider is null', () {},
        skip: 'current framework does not work well with nullable provider/service');

    test('true', () {
      when(mockCommunityPermissionsProvider.canViewCommunityLinks).thenReturn(true);

      final result = presenter.canViewCommunityLinks();

      expect(result, isTrue);
    });

    test('false', () {
      when(mockCommunityPermissionsProvider.canViewCommunityLinks).thenReturn(false);

      final result = presenter.canViewCommunityLinks();

      expect(result, isFalse);
    });
  });

  group('showBottomNavBar', () {
    test('true', () {
      when(mockResponsiveLayoutService.showBottomNavBar(mockContext)).thenReturn(true);

      final result = presenter.showBottomNavBar(mockContext);

      expect(result, isTrue);
    });

    test('false', () {
      when(mockResponsiveLayoutService.showBottomNavBar(mockContext)).thenReturn(false);

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
    test('provider is null', () {
      presenter = NavBarPresenter(mockContext, mockView, model, juntoProvider: null);

      final result = presenter.getCurrentOnboardingStep();

      expect(result, isNull);
    }, skip: 'current framework does not work well with nullable provider/service');

    test('success', () {
      final onboardingStep =
          OnboardingStep.values[Random().nextInt(OnboardingStep.values.length - 1)];
      when(mockJuntoProvider.getCurrentOnboardingStep()).thenReturn(onboardingStep);

      final result = presenter.getCurrentOnboardingStep();

      expect(result, onboardingStep);
    });
  });

  test('closeOnboardingTooltip', () async {
    model.isOnboardingTooltipShown = true;
    when(
      mockSharedPreferencesService.updateOnboardingOverviewTooltipVisibility(false),
    ).thenAnswer((_) async => true);

    presenter.closeOnboardingTooltip();

    verify(mockSharedPreferencesService.updateOnboardingOverviewTooltipVisibility(false)).called(1);
    expect(model.isOnboardingTooltipShown, isFalse);
    verify(mockView.updateView()).called(1);
  });

  group('getCompletedStepCount', () {
    test('provider is null', () {},
        skip: 'current framework does not work well with nullable provider/service');

    test('success', () {
      final junto = Junto(
        id: '',
        onboardingSteps: [OnboardingStep.brandSpace, OnboardingStep.hostConversation],
      );
      when(mockJuntoProvider.junto).thenReturn(junto);

      final result = presenter.getCompletedStepCount();

      expect(result, 2);
    });
  });

  test('getJunto', () {
    final junto = Junto(id: 'id');
    when(mockJuntoProvider.junto).thenReturn(junto);

    final result = presenter.getJunto();

    expect(result, junto);
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
      when(mockRenderBox.localToGlobal(Offset.zero)).thenReturn(Offset(0.123, 2.34));
      when(mockGlobalKey.currentContext).thenReturn(mockContext);
      when(mockContext.findRenderObject()).thenReturn(mockRenderBox);

      presenter.updateAdminButtonXPosition();

      expect(model.adminButtonXPosition, 0.123);
    });
  });

  group('isAdminButtonVisible', () {},
      skip: 'current framework does not work well with nullable provider/service');

  group('isOnboardingOverviewEnabled', () {
    test('true', () {
      when(mockJuntoProvider.junto).thenReturn(Junto(id: 'id', isOnboardingOverviewEnabled: true));

      final result = presenter.isOnboardingOverviewEnabled();

      expect(result, isTrue);
    });

    test('false', () {
      when(mockJuntoProvider.junto).thenReturn(Junto(id: 'id', isOnboardingOverviewEnabled: false));

      final result = presenter.isOnboardingOverviewEnabled();

      expect(result, isFalse);
    });
  });

  test('proceedToConnectWithStripePage', () async {
    when(mockJuntoProvider.juntoId).thenReturn('juntoId');
    when(mockFirestoreAgreementsService.getAgreementForJuntoStream('juntoId')).thenAnswer(
      (_) => Stream.fromIterable([mockPartnerAgreement]),
    );
    when(mockPartnerAgreement.id).thenReturn('agreementId');

    await presenter.proceedToConnectWithStripePage();

    verify(
      mockPaymentUtils.proceedToConnectWithStripePage(
          mockPartnerAgreement, 'agreementId', mockCloudFunctionsService),
    ).called(1);
  });
}
