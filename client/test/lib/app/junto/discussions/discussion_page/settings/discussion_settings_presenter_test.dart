import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_drawer.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_presenter.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:mockito/mockito.dart';
import '../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockContext = MockBuildContext();
  final mockView = MockDiscussionSettingsView();
  final mockAppDrawerProvider = MockAppDrawerProvider();
  final mockJuntoProvider = MockJuntoProvider();
  final mockFirestoreDatabase = MockFirestoreDatabase();
  final mockDiscussionProvider = MockDiscussionProvider();
  final mockTopicPageProvider = MockTopicPageProvider();
  final mockDiscussionSettingsPresenterHelper = MockDiscussionSettingsPresenterHelper();
  final mockDiscussion = MockDiscussion();
  final mockTopic = MockTopic();

  late DiscussionSettingsModel model;
  late DiscussionSettingsPresenter presenter;

  DiscussionSettings defaultSettings() {
    return DiscussionSettings.defaultSettings;
  }

  DiscussionSettings modifiedSettings() {
    return DiscussionSettings.defaultSettings.copyWith(chat: false);
  }

  group('discussion page', () {
    setUp(() {
      model = DiscussionSettingsModel(DiscussionSettingsDrawerType.discussion);
      presenter = DiscussionSettingsPresenter(
        mockContext,
        mockView,
        model,
        discussionSettingsPresenterHelper: mockDiscussionSettingsPresenterHelper,
        appDrawerProvider: mockAppDrawerProvider,
        juntoProvider: mockJuntoProvider,
        firestoreDatabase: mockFirestoreDatabase,
        discussionProvider: mockDiscussionProvider,
      );
    });

    tearDown(() {
      reset(mockView);
      reset(mockDiscussionSettingsPresenterHelper);
      reset(mockAppDrawerProvider);
      reset(mockJuntoProvider);
      reset(mockFirestoreDatabase);
      reset(mockDiscussionProvider);
      reset(mockDiscussion);
      reset(mockTopic);
    });

    test('init', () {
      when(mockJuntoProvider.discussionSettings).thenReturn(defaultSettings());
      when(mockDiscussionProvider.discussion).thenReturn(mockDiscussion);
      when(mockDiscussion.discussionSettings).thenReturn(modifiedSettings());
      when(mockDiscussion.topicId).thenReturn('topicId');
      when(mockDiscussionProvider.topic).thenReturn(mockTopic);
      when(mockTopic.discussionSettings).thenReturn(defaultSettings());

      presenter.init();

      expect(model.initialDiscussionSettings, modifiedSettings());
      expect(model.discussionSettings, modifiedSettings());
      expect(model.defaultSettings, defaultSettings());
      verify(mockView.updateView()).called(1);
    });

    test('isSettingNotDefaultIndicatorShown', () {
      model.defaultSettings = defaultSettings();
      model.discussionSettings = modifiedSettings();
      bool isChatNotDefaultShown =
          presenter.isSettingNotDefaultIndicatorShown((settings) => settings.chat);
      bool isTalkingTimerNotDefaultShown =
          presenter.isSettingNotDefaultIndicatorShown((settings) => settings.talkingTimer);

      expect(isChatNotDefaultShown, isTrue);
      expect(isTalkingTimerNotDefaultShown, isFalse);
    });

    test('updateSetting', () {
      when(mockDiscussionSettingsPresenterHelper.wereChangesMade(model)).thenReturn(true);
      model.discussionSettings = defaultSettings();

      presenter.updateSetting(DiscussionSettings.kFieldTalkingTimer, true);

      expect(model.discussionSettings.talkingTimer, isTrue);
      verify(mockView.updateView()).called(1);
    });

    test('saveSettings', () {
      model.discussionSettings = defaultSettings();

      presenter.saveSettings();

      verify(mockDiscussionProvider.updateDiscussionSettings(model.discussionSettings)).called(1);
    });

    test('restoreDefaultSettings', () {
      model.defaultSettings = defaultSettings();
      model.discussionSettings = modifiedSettings();
      when(mockDiscussionSettingsPresenterHelper.wereChangesMade(model)).thenReturn(true);

      presenter.restoreDefaultSettings();

      expect(model.discussionSettings, defaultSettings());
      verify(mockView.updateView()).called(1);
    });

    test('showConfirmChangesDialog', () {
      presenter.showConfirmChangesDialog();
      verify(mockAppDrawerProvider.showConfirmChangesDialogLayer()).called(1);
    });

    test('wereChangesMade', () {
      when(mockDiscussionSettingsPresenterHelper.wereChangesMade(model)).thenReturn(true);
      final wereChangesMade = presenter.wereChangesMade();
      expect(wereChangesMade, isTrue);
      verify(mockDiscussionSettingsPresenterHelper.wereChangesMade(model)).called(1);
    });

    test('getTitle', () {
      final title = presenter.getTitle();
      expect(title == 'Event Settings', isTrue);
    });

    test('getFloatingChatToggleValue', () {
      model.discussionSettings = defaultSettings().copyWith(
        chat: false,
        showChatMessagesInRealTime: true,
      );
      expect(presenter.getFloatingChatToggleValue(), isFalse);
      model.discussionSettings = defaultSettings().copyWith(
        chat: true,
        showChatMessagesInRealTime: false,
      );
      expect(presenter.getFloatingChatToggleValue(), isFalse);
      model.discussionSettings = defaultSettings().copyWith(
        chat: true,
        showChatMessagesInRealTime: true,
      );
      expect(presenter.getFloatingChatToggleValue(), isTrue);
    });
  });

  group('topic page', () {
    setUp(() {
      model = DiscussionSettingsModel(DiscussionSettingsDrawerType.topic);
      presenter = DiscussionSettingsPresenter(
        mockContext,
        mockView,
        model,
        discussionSettingsPresenterHelper: mockDiscussionSettingsPresenterHelper,
        appDrawerProvider: mockAppDrawerProvider,
        juntoProvider: mockJuntoProvider,
        firestoreDatabase: mockFirestoreDatabase,
        topicPageProvider: mockTopicPageProvider,
      );
    });

    tearDown(() {
      reset(mockView);
      reset(mockDiscussionSettingsPresenterHelper);
      reset(mockAppDrawerProvider);
      reset(mockJuntoProvider);
      reset(mockFirestoreDatabase);
      reset(mockTopicPageProvider);
    });

    test('init', () {
      when(mockJuntoProvider.discussionSettings).thenReturn(defaultSettings());
      when(mockTopicPageProvider.topic).thenReturn(mockTopic);
      when(mockTopic.discussionSettings).thenReturn(modifiedSettings());

      presenter.init();

      expect(model.initialDiscussionSettings, modifiedSettings());
      expect(model.discussionSettings, modifiedSettings());
      expect(model.defaultSettings, defaultSettings());
      verify(mockView.updateView()).called(1);
    });

    test('saveSettings', () async {
      const defaultTopic = Topic(
        creatorId: 'topicCreator',
        collectionPath: 'topicCollection',
        id: 'topicId',
      );
      when(mockTopicPageProvider.topic).thenReturn(defaultTopic);
      when(mockJuntoProvider.juntoId).thenReturn('juntoId');
      model.discussionSettings = modifiedSettings();

      await presenter.saveSettings();

      verify(mockFirestoreDatabase.updateTopic(
        juntoId: 'juntoId',
        topic: defaultTopic,
        keys: [Topic.kFieldDiscussionSettings],
      )).called(1);
    }, skip: 'TODO(kris): fix save discussion settings on topic test');

    test('getTitle', () {
      final title = presenter.getTitle();
      expect(title == 'Template Settings', isTrue);
    });
  });
}
