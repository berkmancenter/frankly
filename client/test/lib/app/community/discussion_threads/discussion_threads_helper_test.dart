import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/discussion_threads/data/services/discussion_threads_helper.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockLoggingService = MockLoggingService();
  final mockMediaHelperService = MockMediaHelperService();
  final mockDiscussionThread = MockDiscussionThread();

  final discussionThreadsHelper = DiscussionThreadsHelper();

  tearDown(() {
    reset(mockMediaHelperService);
    reset(mockDiscussionThread);
  });

  group('addNewDiscussionThread', () {
    test('content is empty', () async {
      final result = await discussionThreadsHelper.addNewDiscussionThread(
        discussionThreadContent: ' ',
        userId: 'userId',
        pickedImageUrl: 'pickedImageUrl',
        documentId: 'documentId',
        mediaHelperService: mockMediaHelperService,
        onError: (error) => mockLoggingService.log(error),
      );

      expect(result, isNull);
      verify(mockLoggingService.log('Content cannot be empty'));
    });

    test('pickedImagePath is empty', () async {
      final result = await discussionThreadsHelper.addNewDiscussionThread(
        discussionThreadContent: 'discussionThreadContent',
        userId: 'userId',
        documentId: 'documentId',
        mediaHelperService: mockMediaHelperService,
        onError: (error) => mockLoggingService.log(error),
      );

      expect(
        result!.toJson(),
        DiscussionThread(
          id: 'documentId',
          creatorId: 'userId',
          content: 'discussionThreadContent',
        ).toJson(),
      );
    });

    test('pickedImagePath is not empty', () async {
      final result = await discussionThreadsHelper.addNewDiscussionThread(
        discussionThreadContent: 'discussionThreadContent',
        userId: 'userId',
        pickedImageUrl: 'pickedImageUrl',
        documentId: 'documentId',
        mediaHelperService: mockMediaHelperService,
        onError: (error) => mockLoggingService.log(error),
      );

      expect(
        result!.toJson(),
        DiscussionThread(
          id: 'documentId',
          creatorId: 'userId',
          content: 'discussionThreadContent',
          imageUrl: 'pickedImageUrl',
        ).toJson(),
      );
    });
  });

  group('updateDiscussionThread', () {
    test('discussion thread is null', () async {
      final result = await discussionThreadsHelper.updateDiscussionThread(
        existingDiscussionThread: null,
        discussionThreadContent: '',
        pickedImageUrl: 'pickedImageUrl',
        generalHelperService: mockMediaHelperService,
        onError: (error) => mockLoggingService.log(error),
      );

      expect(result, isNull);
      verifyNever(mockLoggingService.log(any));
    });

    test('content is empty', () async {
      final result = await discussionThreadsHelper.updateDiscussionThread(
        existingDiscussionThread: mockDiscussionThread,
        discussionThreadContent: ' ',
        pickedImageUrl: 'pickedImageUrl',
        generalHelperService: mockMediaHelperService,
        onError: (error) => mockLoggingService.log(error),
      );

      expect(result, isNull);
      verify(mockLoggingService.log('Content cannot be empty')).called(1);
    });

    test('pickedImagePath is empty', () async {
      final DiscussionThread discussionThread = DiscussionThread(
        id: 'id',
        creatorId: 'userId',
        content: 'old content',
        imageUrl: 'old image url',
      );

      final result = await discussionThreadsHelper.updateDiscussionThread(
        existingDiscussionThread: discussionThread,
        discussionThreadContent: 'new content',
        generalHelperService: mockMediaHelperService,
        onError: (error) => mockLoggingService.log(error),
      );

      expect(
        result!.toJson(),
        DiscussionThread(
          id: 'id',
          creatorId: 'userId',
          content: 'new content',
          imageUrl: 'old image url',
        ).toJson(),
      );
    });

    test('pickedImagePath is not empty', () async {
      final DiscussionThread discussionThread = DiscussionThread(
        id: 'id',
        creatorId: 'userId',
        content: 'old content',
        imageUrl: 'old image url',
      );

      final result = await discussionThreadsHelper.updateDiscussionThread(
        existingDiscussionThread: discussionThread,
        discussionThreadContent: 'new content',
        pickedImageUrl: 'pickedImageUrl',
        generalHelperService: mockMediaHelperService,
        onError: (error) => mockLoggingService.log(error),
      );

      expect(
        result!.toJson(),
        DiscussionThread(
          id: 'id',
          creatorId: 'userId',
          content: 'new content',
          imageUrl: 'pickedImageUrl',
        ).toJson(),
      );
    });
  });
}
