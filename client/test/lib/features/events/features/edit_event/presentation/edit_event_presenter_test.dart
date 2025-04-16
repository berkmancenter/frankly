import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/edit_event/data/models/edit_event_model.dart';
import 'package:client/features/events/features/edit_event/presentation/edit_event_presenter.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/community/community.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockContext = MockBuildContext();
  final mockView = MockEditEventView();
  final mockEventPageProvider = MockEventPageProvider();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockFirestoreEventService = MockFirestoreEventService();
  final mockEventProvider = MockEventProvider();
  final mockFirestoreDatabase = MockFirestoreDatabase();
  final mockCommunityProvider = MockCommunityProvider();
  final mockCommunityPermissionsProvider = MockCommunityPermissionsProvider();
  final mockEditEventPresenterHelper = MockEditEventPresenterHelper();
  final mockAppDrawerProvider = MockAppDrawerProvider();

  late EditEventModel model;
  late EditEventPresenter presenter;

  setUp(() {
    model = EditEventModel();
    presenter = EditEventPresenter(
      mockContext,
      mockView,
      model,
      editEventPresenterHelper: mockEditEventPresenterHelper,
      appDrawerProvider: mockAppDrawerProvider,
      eventPageProvider: mockEventPageProvider,
      responsiveLayoutService: mockResponsiveLayoutService,
      firestoreEventService: mockFirestoreEventService,
      firestoreDatabase: mockFirestoreDatabase,
      communityProvider: mockCommunityProvider,
      communityPermissionsProvider: mockCommunityPermissionsProvider,
    );
  });

  tearDown(() {
    reset(mockView);
    reset(mockEditEventPresenterHelper);
    reset(mockAppDrawerProvider);
    reset(mockEventPageProvider);
    reset(mockResponsiveLayoutService);
    reset(mockFirestoreEventService);
    reset(mockEventProvider);
    reset(mockFirestoreDatabase);
    reset(mockCommunityProvider);
  });

  Event getEvent() {
    return Event(
      id: 'id',
      status: EventStatus.active,
      collectionPath: 'collectionPath',
      communityId: 'communityId',
      templateId: 'templateId',
      creatorId: 'creatorId',
    );
  }

  test('init', () {
    final event = getEvent();
    when(mockEventPageProvider.eventProvider).thenReturn(mockEventProvider);
    when(mockEventProvider.event).thenReturn(event);

    presenter.init();

    expect(model.event, event);
    expect(model.initialEvent, event);
    verify(mockView.updateView()).called(1);
  });

  test('updateEventType', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final event = getEvent();
    model.event = event;

    presenter.updateEventType(EventType.hosted);

    expect(
      event.copyWith(nullableEventType: EventType.hosted).toJson(),
      model.event.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  group('getEventTypeTitle', () {
    void executeTest(EventType eventType) {
      test('$eventType', () {
        final String result;
        switch (eventType) {
          case EventType.hosted:
            result = 'Hosted';
            break;
          case EventType.hostless:
            result = 'Hostless';
            break;
          case EventType.livestream:
            result = 'Livestream';
            break;
        }

        expect(presenter.getEventTypeTitle(eventType), result);
      });
    }

    for (var eventType in EventType.values) {
      executeTest(eventType);
    }
  });

  test('updateTitle', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final event = getEvent();
    model.event = event;

    presenter.updateTitle('title');

    expect(
      event.copyWith(title: 'title').toJson(),
      model.event.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateDescription', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final event = getEvent();
    model.event = event;

    presenter.updateDescription('description');

    expect(
      event.copyWith(description: 'description').toJson(),
      model.event.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateIsPublic', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final event = getEvent();
    model.event = event;

    presenter.updateIsPublic(true);

    expect(
      event.copyWith(isPublic: true).toJson(),
      model.event.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateDate', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final dateTime = DateTime(2020, 1, 2, 3, 4);
    final event = getEvent().copyWith(scheduledTime: dateTime);
    model.event = event;

    presenter.updateDate(DateTime(2010, 10, 11, 12));

    expect(
      event.copyWith(scheduledTime: DateTime(2010, 10, 11, 3, 4)).toJson(),
      model.event.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateTime', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final dateTime = DateTime(2020, 1, 2, 3, 4);
    final event = getEvent().copyWith(scheduledTime: dateTime);
    model.event = event;

    presenter.updateTime(TimeOfDay(hour: 16, minute: 20));

    expect(
      event.copyWith(scheduledTime: DateTime(2020, 1, 2, 16, 20)).toJson(),
      model.event.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateIsFeatured', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    model.isFeatured = false;

    presenter.updateIsFeatured(true);

    expect(model.isFeatured, isTrue);
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateMaxParticipants', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final event = getEvent();
    model.event = event;

    presenter.updateMaxParticipants(15);

    expect(
      event.copyWith(maxParticipants: 15).toJson(),
      model.event.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateEventDuration', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final event = getEvent();
    model.event = event;

    presenter.updateEventDuration(Duration(minutes: 120));

    expect(
      event.copyWith(durationInMinutes: 120).toJson(),
      model.event.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('isMobile', () {
    when(mockResponsiveLayoutService.isMobile(mockContext)).thenReturn(true);

    final result = presenter.isMobile(mockContext);

    expect(result, isTrue);
  });

  group('isPlatformSelectionFeatureEnabled', () {
    test('true', () {
      final settings = CommunitySettings(enablePlatformSelection: true);
      when(mockCommunityProvider.settings).thenReturn(settings);
      expect(presenter.isPlatformSelectionFeatureEnabled(), isTrue);
    });

    test('false', () {
      final settings = CommunitySettings(enablePlatformSelection: false);
      when(mockCommunityProvider.settings).thenReturn(settings);
      expect(presenter.isPlatformSelectionFeatureEnabled(), isFalse);
    });
  });

  group('saveChanges', () {
    test('validation error', () async {
      final community = Community(id: 'communityId');
      when(mockCommunityProvider.community).thenReturn(community);
      model.event = getEvent();
      when(mockEditEventPresenterHelper.areChangesValid(model.event))
          .thenReturn('error');

      await presenter.saveChanges();

      verify(mockView.showMessage('error', toastType: ToastType.failed))
          .called(1);
      verify(mockAppDrawerProvider.hideConfirmChangesDialogLayer()).called(1);
      verifyNoMoreInteractions(mockView);
    });

    test('success', () async {
      final community = Community(id: 'communityId');
      when(mockCommunityProvider.community).thenReturn(community);
      final event = getEvent().copyWith(
        title: 'title',
        description: 'description',
        collectionPath: 'collectionPath',
        id: 'eventId',
      );
      model.event = event;
      when(mockEditEventPresenterHelper.areChangesValid(model.event))
          .thenReturn(null);
      when(mockCommunityPermissionsProvider.canFeatureItems).thenReturn(true);
      model.isFeatured = true;

      await presenter.saveChanges();

      verifyNever(mockView.showMessage(any, toastType: ToastType.failed));
      verify(
        mockFirestoreDatabase.updateFeaturedItem(
          communityId: 'communityId',
          documentId: 'eventId',
          featured: anyNamed('featured'),
          isFeatured: true,
        ),
      ).called(1);

      verify(
        mockFirestoreEventService.updateEvent(
          event: event,
          keys: [
            Event.kFieldEventType,
            Event.kFieldTitle,
            Event.kFieldImage,
            Event.kFieldDescription,
            Event.kFieldIsPublic,
            Event.kFieldScheduledTime,
            Event.kFieldMaxParticipants,
            Event.kDurationInMinutes,
          ],
        ),
      ).called(1);
      verify(mockView.closeDrawer()).called(1);
    });
  });

  group('isFeatured', () {
    test('true', () {
      final featuredItems = [
        Featured(documentPath: 'docPath1'),
        Featured(documentPath: 'collectionPath/eventId'),
        Featured(documentPath: 'docPath2'),
      ];
      final event = getEvent().copyWith(
        collectionPath: 'collectionPath',
        id: 'eventId',
      );
      model.event = event;

      final result = presenter.isFeatured(featuredItems);

      expect(result, isTrue);
    });

    test('false with null list', () {
      final event = getEvent().copyWith(
        collectionPath: 'collectionPath',
        id: 'eventId',
      );
      model.event = event;

      final result = presenter.isFeatured(null);

      expect(result, isFalse);
    });

    test('false, no matches', () {
      final featuredItems = [
        Featured(documentPath: 'docPath1'),
        Featured(documentPath: 'docPath2'),
        Featured(documentPath: 'docPath3'),
      ];
      final event = getEvent().copyWith(
        collectionPath: 'collectionPath',
        id: 'eventId',
      );
      model.event = event;

      final result = presenter.isFeatured(featuredItems);

      expect(result, isFalse);
    });
  });

  test('getFeaturedStream', () {
    final BehaviorSubjectWrapper<List<Featured>> stream =
        BehaviorSubjectWrapper(Stream.empty());
    when(mockCommunityProvider.community).thenReturn(Community(id: 'id'));
    when(mockFirestoreDatabase.getCommunityFeaturedItems('id'))
        .thenAnswer((_) => stream);

    final result = presenter.getFeaturedStream();

    expect(result, stream);
  });

  test('getEventDocumentPath', () {
    final event = getEvent().copyWith(
      collectionPath: 'collectionPath',
      id: 'eventId',
    );
    model.event = event;

    final result = presenter.getEventDocumentPath();

    expect(result, 'collectionPath/eventId');
  });

  test('updateImage', () {
    when(mockEditEventPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final event = getEvent();
    model.event = event;

    presenter.updateImage('url');

    expect(
      event.copyWith(image: 'url').toJson(),
      model.event.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  group('cancelEvent', () {
    test('true', () async {
      when(mockEventPageProvider.cancelEvent()).thenAnswer((_) async => true);

      await presenter.cancelEvent();

      verify(mockView.closeDrawer()).called(1);
    });

    test('false', () async {
      when(mockEventPageProvider.cancelEvent()).thenAnswer((_) async => false);

      await presenter.cancelEvent();

      verifyNever(mockView.closeDrawer());
    });
  });

  group('wereChangesMade', () {
    test('true', () async {
      when(mockEditEventPresenterHelper.wereChangesMade(model))
          .thenReturn(true);
      expect(presenter.wereChangesMade(), isTrue);
    });

    test('false', () async {
      when(mockEditEventPresenterHelper.wereChangesMade(model))
          .thenReturn(false);
      expect(presenter.wereChangesMade(), isFalse);
    });
  });

  test('showConfirmChangesDialog', () {
    presenter.showConfirmChangesDialog();
    verify(mockAppDrawerProvider.showConfirmChangesDialogLayer()).called(1);
  });

  group('canBuildParticipantCountSection', () {
    void executeTest(EventType eventType) {
      test('$eventType', () {
        model.event = getEvent().copyWith(nullableEventType: eventType);
        final result = presenter.canBuildParticipantCountSection();

        switch (eventType) {
          case EventType.hosted:
            expect(result, isTrue);
            break;
          case EventType.hostless:
          case EventType.livestream:
            expect(result, isFalse);
            break;
        }
      });
    }

    for (var eventType in EventType.values) {
      executeTest(eventType);
    }
  });
}
