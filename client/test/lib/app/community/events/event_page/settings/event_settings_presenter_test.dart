import 'package:flutter_test/flutter_test.dart';
import 'package:client/app/community/events/event_page/event_settings/event_settings_drawer.dart';
import 'package:client/app/community/events/event_page/event_settings/event_settings_model.dart';
import 'package:client/app/community/events/event_page/event_settings/event_settings_presenter.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:mockito/mockito.dart';
import '../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockContext = MockBuildContext();
  final mockView = MockEventSettingsView();
  final mockAppDrawerProvider = MockAppDrawerProvider();
  final mockCommunityProvider = MockCommunityProvider();
  final mockFirestoreDatabase = MockFirestoreDatabase();
  final mockEventProvider = MockEventProvider();
  final mockTemplatePageProvider = MockTemplatePageProvider();
  final mockEventSettingsPresenterHelper = MockEventSettingsPresenterHelper();
  final mockEvent = MockEvent();
  final mockTemplate = MockTemplate();

  late EventSettingsModel model;
  late EventSettingsPresenter presenter;

  EventSettings defaultSettings() {
    return EventSettings.defaultSettings;
  }

  EventSettings modifiedSettings() {
    return EventSettings.defaultSettings.copyWith(chat: false);
  }

  group('event page', () {
    setUp(() {
      model = EventSettingsModel(EventSettingsDrawerType.event);
      presenter = EventSettingsPresenter(
        mockContext,
        mockView,
        model,
        eventSettingsPresenterHelper: mockEventSettingsPresenterHelper,
        appDrawerProvider: mockAppDrawerProvider,
        communityProvider: mockCommunityProvider,
        firestoreDatabase: mockFirestoreDatabase,
        eventProvider: mockEventProvider,
      );
    });

    tearDown(() {
      reset(mockView);
      reset(mockEventSettingsPresenterHelper);
      reset(mockAppDrawerProvider);
      reset(mockCommunityProvider);
      reset(mockFirestoreDatabase);
      reset(mockEventProvider);
      reset(mockEvent);
      reset(mockTemplate);
    });

    test('init', () {
      when(mockCommunityProvider.eventSettings).thenReturn(defaultSettings());
      when(mockEventProvider.event).thenReturn(mockEvent);
      when(mockEvent.eventSettings).thenReturn(modifiedSettings());
      when(mockEvent.templateId).thenReturn('templateId');
      when(mockEventProvider.template).thenReturn(mockTemplate);
      when(mockTemplate.eventSettings).thenReturn(defaultSettings());

      presenter.init();

      expect(model.initialEventSettings, modifiedSettings());
      expect(model.eventSettings, modifiedSettings());
      expect(model.defaultSettings, defaultSettings());
      verify(mockView.updateView()).called(1);
    });

    test('isSettingNotDefaultIndicatorShown', () {
      model.defaultSettings = defaultSettings();
      model.eventSettings = modifiedSettings();
      bool isChatNotDefaultShown = presenter
          .isSettingNotDefaultIndicatorShown((settings) => settings.chat);
      bool isTalkingTimerNotDefaultShown =
          presenter.isSettingNotDefaultIndicatorShown(
        (settings) => settings.talkingTimer,
      );

      expect(isChatNotDefaultShown, isTrue);
      expect(isTalkingTimerNotDefaultShown, isFalse);
    });

    test('updateSetting', () {
      when(mockEventSettingsPresenterHelper.wereChangesMade(model))
          .thenReturn(true);
      model.eventSettings = defaultSettings();

      presenter.updateSetting(EventSettings.kFieldTalkingTimer, true);

      expect(model.eventSettings.talkingTimer, isTrue);
      verify(mockView.updateView()).called(1);
    });

    test('saveSettings', () {
      model.eventSettings = defaultSettings();

      presenter.saveSettings();

      verify(
        mockEventProvider.updateEventSettings(model.eventSettings),
      ).called(1);
    });

    test('restoreDefaultSettings', () {
      model.defaultSettings = defaultSettings();
      model.eventSettings = modifiedSettings();
      when(mockEventSettingsPresenterHelper.wereChangesMade(model))
          .thenReturn(true);

      presenter.restoreDefaultSettings();

      expect(model.eventSettings, defaultSettings());
      verify(mockView.updateView()).called(1);
    });

    test('showConfirmChangesDialog', () {
      presenter.showConfirmChangesDialog();
      verify(mockAppDrawerProvider.showConfirmChangesDialogLayer()).called(1);
    });

    test('wereChangesMade', () {
      when(mockEventSettingsPresenterHelper.wereChangesMade(model))
          .thenReturn(true);
      final wereChangesMade = presenter.wereChangesMade();
      expect(wereChangesMade, isTrue);
      verify(mockEventSettingsPresenterHelper.wereChangesMade(model)).called(1);
    });

    test('getTitle', () {
      final title = presenter.getTitle();
      expect(title == 'Event Settings', isTrue);
    });

    test('getFloatingChatToggleValue', () {
      model.eventSettings = defaultSettings().copyWith(
        chat: false,
        showChatMessagesInRealTime: true,
      );
      expect(presenter.getFloatingChatToggleValue(), isFalse);
      model.eventSettings = defaultSettings().copyWith(
        chat: true,
        showChatMessagesInRealTime: false,
      );
      expect(presenter.getFloatingChatToggleValue(), isFalse);
      model.eventSettings = defaultSettings().copyWith(
        chat: true,
        showChatMessagesInRealTime: true,
      );
      expect(presenter.getFloatingChatToggleValue(), isTrue);
    });
  });

  group('template page', () {
    setUp(() {
      model = EventSettingsModel(EventSettingsDrawerType.template);
      presenter = EventSettingsPresenter(
        mockContext,
        mockView,
        model,
        eventSettingsPresenterHelper: mockEventSettingsPresenterHelper,
        appDrawerProvider: mockAppDrawerProvider,
        communityProvider: mockCommunityProvider,
        firestoreDatabase: mockFirestoreDatabase,
        templatePageProvider: mockTemplatePageProvider,
      );
    });

    tearDown(() {
      reset(mockView);
      reset(mockEventSettingsPresenterHelper);
      reset(mockAppDrawerProvider);
      reset(mockCommunityProvider);
      reset(mockFirestoreDatabase);
      reset(mockTemplatePageProvider);
    });

    test('init', () {
      when(mockCommunityProvider.eventSettings).thenReturn(defaultSettings());
      when(mockTemplatePageProvider.template).thenReturn(mockTemplate);
      when(mockTemplate.eventSettings).thenReturn(modifiedSettings());

      presenter.init();

      expect(model.initialEventSettings, modifiedSettings());
      expect(model.eventSettings, modifiedSettings());
      expect(model.defaultSettings, defaultSettings());
      verify(mockView.updateView()).called(1);
    });

    test(
      'saveSettings',
      () async {
        const defaultTemplate = Template(
          creatorId: 'templateCreator',
          collectionPath: 'templateCollection',
          id: 'templateId',
        );
        when(mockTemplatePageProvider.template).thenReturn(defaultTemplate);
        when(mockCommunityProvider.communityId).thenReturn('communityId');
        model.eventSettings = modifiedSettings();

        await presenter.saveSettings();

        verify(
          mockFirestoreDatabase.updateTemplate(
            communityId: 'communityId',
            template: defaultTemplate,
            keys: [Template.kFieldEventSettings],
          ),
        ).called(1);
      },
      skip: 'TODO(kris): fix save event settings on template test',
    );

    test('getTitle', () {
      final title = presenter.getTitle();
      expect(title == 'Template Settings', isTrue);
    });
  });
}
