import 'package:flutter_test/flutter_test.dart';
import 'package:client/app/community/admin/overview/overview_model.dart';
import 'package:client/app/community/admin/overview/overview_presenter.dart';
import 'package:data_models/community/community.dart';
import 'package:mockito/mockito.dart';
import '../../../../../mocked_classes.mocks.dart';

void main() {
  final mockBuildContext = MockBuildContext();
  final mockView = MockOverviewView();
  final mockCommunityProvider = MockCommunityProvider();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockFirestoreAgreementsService = MockFirestoreAgreementsService();
  final mockPaymentUtils = MockPaymentUtils();
  final mockPartnerAgreement = MockPartnerAgreement();
  final mockCloudFunctionsService = MockCloudFunctionsService();

  late OverviewModel model;
  late OverviewPresenter presenter;

  setUp(() {
    model = OverviewModel();
    presenter = OverviewPresenter(
      mockBuildContext,
      mockView,
      model,
      communityProvider: mockCommunityProvider,
      responsiveLayoutService: mockResponsiveLayoutService,
      firestoreAgreementsService: mockFirestoreAgreementsService,
      paymentUtils: mockPaymentUtils,
      cloudFunctionsService: mockCloudFunctionsService,
    );
  });

  tearDown(() {
    reset(mockView);
    reset(mockCommunityProvider);
    reset(mockResponsiveLayoutService);
    reset(mockFirestoreAgreementsService);
    reset(mockPaymentUtils);
    reset(mockPartnerAgreement);
  });

  group('init', () {
    void executeTest(OnboardingStep onboardingStep) {
      test('$onboardingStep', () {
        when(mockCommunityProvider.getCurrentOnboardingStep())
            .thenReturn(onboardingStep);

        presenter.init();

        expect(model.expandedOnboardingStep, onboardingStep);
        verify(mockView.updateView()).called(1);
      });
    }

    for (var onboardingStep in OnboardingStep.values) {
      executeTest(onboardingStep);
    }
  });

  group('getCurrentOnboardingStep', () {
    void executeTest(OnboardingStep onboardingStep) {
      test('$onboardingStep', () {
        when(mockCommunityProvider.getCurrentOnboardingStep())
            .thenReturn(onboardingStep);

        final result = presenter.getCurrentOnboardingStep();

        expect(result, onboardingStep);
      });
    }

    for (var onboardingStep in OnboardingStep.values) {
      executeTest(onboardingStep);
    }
  });

  group('getSubtitle', () {
    void executeTest(OnboardingStep onboardingStep) {
      test('$onboardingStep', () {
        final result = presenter.getSubtitle(onboardingStep);

        final String expectedResult;
        switch (onboardingStep) {
          case OnboardingStep.brandSpace:
            expectedResult =
                'Make it yours with custom colors, images, and logos';
            break;
          case OnboardingStep.createGuide:
            expectedResult =
                'What do you want to talk about? Choose a template and structure the event. ';
            break;
          case OnboardingStep.hostEvent:
            expectedResult =
                'You can host or let members talk directly to each other. ';
            break;
          case OnboardingStep.inviteSomeone:
            expectedResult =
                'Follow along for upcoming events, resources, and more.';
            break;
          case OnboardingStep.createStripeAccount:
            expectedResult = 'Enable donations for your community.';
            break;
        }

        expect(result, expectedResult);
      });
    }

    for (var onboardingStep in OnboardingStep.values) {
      executeTest(onboardingStep);
    }
  });

  group('toggleExpansion', () {
    test('same onboarding step as before and onboarding did not finish', () {
      model.expandedOnboardingStep = OnboardingStep.brandSpace;

      presenter.toggleExpansion(OnboardingStep.brandSpace);

      expect(model.expandedOnboardingStep, isNull);
      verify(mockView.updateView()).called(1);
    });

    test('different onboarding step as before and onboarding did not finish',
        () {
      model.expandedOnboardingStep = OnboardingStep.brandSpace;

      presenter.toggleExpansion(OnboardingStep.hostEvent);

      expect(model.expandedOnboardingStep, OnboardingStep.hostEvent);
      verify(mockView.updateView()).called(1);
    });

    test('onboarding did finish', () {
      model.expandedOnboardingStep = OnboardingStep.brandSpace;

      presenter.toggleExpansion(null);

      expect(model.expandedOnboardingStep, isNull);
      verify(mockView.updateView()).called(1);
    });
  });

  group('isOnboardingStepExpanded', () {
    test('true', () {
      model.expandedOnboardingStep = OnboardingStep.brandSpace;

      final result =
          presenter.isOnboardingStepExpanded(OnboardingStep.brandSpace);

      expect(result, isTrue);
    });

    test('false', () {
      model.expandedOnboardingStep = OnboardingStep.brandSpace;

      final result =
          presenter.isOnboardingStepExpanded(OnboardingStep.hostEvent);

      expect(result, isFalse);
    });
  });

  group('isOnboardingStepCompleted', () {
    test('true', () {
      when(
        mockCommunityProvider
            .isOnboardingStepCompleted(OnboardingStep.hostEvent),
      ).thenReturn(true);

      final result =
          presenter.isOnboardingStepCompleted(OnboardingStep.hostEvent);

      expect(result, isTrue);
    });

    test('false', () {
      when(
        mockCommunityProvider
            .isOnboardingStepCompleted(OnboardingStep.hostEvent),
      ).thenReturn(false);

      final result =
          presenter.isOnboardingStepCompleted(OnboardingStep.hostEvent);

      expect(result, isFalse);
    });
  });

  test('getCompletedStepCount', () {
    when(mockCommunityProvider.community).thenReturn(
      Community(
        id: '',
        onboardingSteps: [
          OnboardingStep.hostEvent,
          OnboardingStep.brandSpace,
        ],
      ),
    );

    final result = presenter.getCompletedStepCount();

    expect(result, 2);
  });

  test('getCommunity', () {
    final community = Community(id: '');
    when(mockCommunityProvider.community).thenReturn(community);

    final result = presenter.getCommunity();

    expect(result, community);
  });

  group('isMobile', () {
    test('true', () {
      when(mockResponsiveLayoutService.isMobile(mockBuildContext))
          .thenReturn(true);

      final result = presenter.isMobile(mockBuildContext);

      expect(result, isTrue);
    });

    test('false', () {
      when(mockResponsiveLayoutService.isMobile(mockBuildContext))
          .thenReturn(false);

      final result = presenter.isMobile(mockBuildContext);

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
