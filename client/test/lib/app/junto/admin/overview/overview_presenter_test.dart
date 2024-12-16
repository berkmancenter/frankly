import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/admin/overview/overview_model.dart';
import 'package:junto/app/junto/admin/overview/overview_presenter.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:mockito/mockito.dart';
import '../../../../../mocked_classes.mocks.dart';

void main() {
  final mockBuildContext = MockBuildContext();
  final mockView = MockOverviewView();
  final mockJuntoProvider = MockJuntoProvider();
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
      juntoProvider: mockJuntoProvider,
      responsiveLayoutService: mockResponsiveLayoutService,
      firestoreAgreementsService: mockFirestoreAgreementsService,
      paymentUtils: mockPaymentUtils,
      cloudFunctionsService: mockCloudFunctionsService,
    );
  });

  tearDown(() {
    reset(mockView);
    reset(mockJuntoProvider);
    reset(mockResponsiveLayoutService);
    reset(mockFirestoreAgreementsService);
    reset(mockPaymentUtils);
    reset(mockPartnerAgreement);
  });

  group('init', () {
    void executeTest(OnboardingStep onboardingStep) {
      test('$onboardingStep', () {
        when(mockJuntoProvider.getCurrentOnboardingStep()).thenReturn(onboardingStep);

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
        when(mockJuntoProvider.getCurrentOnboardingStep()).thenReturn(onboardingStep);

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
            expectedResult = 'Make it yours with custom colors, images, and logos';
            break;
          case OnboardingStep.createGuide:
            expectedResult =
                'What do you want to talk about? Choose a template and structure the event. ';
            break;
          case OnboardingStep.hostConversation:
            expectedResult = 'You can host or let members talk directly to each other. ';
            break;
          case OnboardingStep.inviteSomeone:
            expectedResult = 'Follow along for upcoming events, resources, and more.';
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

    test('different onboarding step as before and onboarding did not finish', () {
      model.expandedOnboardingStep = OnboardingStep.brandSpace;

      presenter.toggleExpansion(OnboardingStep.hostConversation);

      expect(model.expandedOnboardingStep, OnboardingStep.hostConversation);
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

      final result = presenter.isOnboardingStepExpanded(OnboardingStep.brandSpace);

      expect(result, isTrue);
    });

    test('false', () {
      model.expandedOnboardingStep = OnboardingStep.brandSpace;

      final result = presenter.isOnboardingStepExpanded(OnboardingStep.hostConversation);

      expect(result, isFalse);
    });
  });

  group('isOnboardingStepCompleted', () {
    test('true', () {
      when(mockJuntoProvider.isOnboardingStepCompleted(OnboardingStep.hostConversation))
          .thenReturn(true);

      final result = presenter.isOnboardingStepCompleted(OnboardingStep.hostConversation);

      expect(result, isTrue);
    });

    test('false', () {
      when(mockJuntoProvider.isOnboardingStepCompleted(OnboardingStep.hostConversation))
          .thenReturn(false);

      final result = presenter.isOnboardingStepCompleted(OnboardingStep.hostConversation);

      expect(result, isFalse);
    });
  });

  test('getCompletedStepCount', () {
    when(mockJuntoProvider.junto).thenReturn(Junto(
        id: '', onboardingSteps: [OnboardingStep.hostConversation, OnboardingStep.brandSpace]));

    final result = presenter.getCompletedStepCount();

    expect(result, 2);
  });

  test('getJunto', () {
    final junto = Junto(id: '');
    when(mockJuntoProvider.junto).thenReturn(junto);

    final result = presenter.getJunto();

    expect(result, junto);
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

  test('proceedToConnectWithStripePage', () async {
    when(mockJuntoProvider.juntoId).thenReturn('juntoId');
    when(mockFirestoreAgreementsService.getAgreementForJuntoStream('juntoId')).thenAnswer(
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
