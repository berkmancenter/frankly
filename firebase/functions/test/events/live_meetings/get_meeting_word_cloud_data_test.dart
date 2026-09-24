import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/user_input/word_cloud_data.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart' as admin;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/get_meeting_word_cloud_data.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:test/test.dart';

void main() {
  const path = 'community/wordcloud-export/templates/template/events/event';
  const main = '$path/live-meetings/event';
  const room = '$main/breakout-room-sessions/session/breakout-rooms/room';
  final time = DateTime.utc(2026, 9, 8, 12);
  final method = GetMeetingWordCloudData();
  Future<void> write(String path, Map<String, dynamic> data) =>
      firestore.document(path).setData(
            admin.DocumentData.fromMap(
              firestoreUtils.toFirestoreJson(data),
            ),
          );
  Future<GetMeetingWordCloudDataResponse> get(
    String? user, [
    String eventPath = path,
  ]) async =>
      GetMeetingWordCloudDataResponse.fromJson(
        await method.action(
          GetMeetingWordCloudDataRequest(eventPath: eventPath),
          CallableContext(user, null, null),
        ),
      );

  setUpAll(() async {
    setFirebaseAppFactory(() => admin.FirebaseAdmin.instance.initializeApp()!);
    await write(
      path,
      Event(
        id: 'event',
        status: EventStatus.active,
        creatorId: 'creator',
        communityId: 'wordcloud-export',
        templateId: 'template',
        collectionPath: 'community/wordcloud-export/templates/template/events',
        scheduledTime: time,
        agendaItems: [
          AgendaItem(
            id: 'legacy',
            content: 'Older prompt',
            nullableType: AgendaItemType.wordCloud,
          ),
        ],
      ).toJson(),
    );
    await write(main, {
      'events': [
        {'event': 'finishMeeting'},
      ],
    });
    await write('memberships/admin/community-membership/wordcloud-export', {
      'userId': 'admin',
      'communityId': 'wordcloud-export',
      'status': 'admin',
    });
    await write('memberships/member/community-membership/wordcloud-export', {
      'userId': 'member',
      'communityId': 'wordcloud-export',
      'status': 'member',
    });
    await write(
      '$main/participant-agenda-item-details/removed/participant-details/user',
      ParticipantAgendaItemDetails(
        userId: 'user',
        meetingId: 'event',
        agendaItemId: 'removed',
        wordCloudResponses: ['Trust', '世界 🌍'],
        wordCloudEntries: [
          for (final word in ['Trust', '世界 🌍'])
            WordCloudData(
              userId: 'user',
              agendaItemId: 'removed',
              roomId: 'event',
              prompt: 'What matters?',
              message: word,
              createdDate: time,
            ),
        ],
      ).toJson(),
    );
    await write(
      '$main/participant-agenda-item-details/legacy/participant-details/user',
      ParticipantAgendaItemDetails(
        userId: 'user',
        meetingId: 'event',
        agendaItemId: 'legacy',
        wordCloudResponses: ['Legacy'],
      ).toJson(),
    );
    await write('$main/breakout-room-sessions/session', {'id': 'session'});
    await write(room, {'roomId': 'room'});
    await write(
      '$room/live-meetings/room/participant-agenda-item-details/cloud/participant-details/other',
      ParticipantAgendaItemDetails(
        userId: 'other',
        meetingId: 'room',
        agendaItemId: 'cloud',
        wordCloudResponses: ['Listening'],
        wordCloudEntries: [
          WordCloudData(
            userId: 'other',
            agendaItemId: 'cloud',
            roomId: 'room',
            prompt: 'Next steps?',
            message: 'Listening',
            createdDate: time.add(const Duration(minutes: 1)),
          ),
        ],
      ).toJson(),
    );
    await write(
      'community/other/templates/template/events/other/live-meetings/event/participant-agenda-item-details/cloud/participant-details/intruder',
      ParticipantAgendaItemDetails(
        userId: 'intruder',
        meetingId: 'event',
        wordCloudResponses: ['Must not leak'],
      ).toJson(),
    );
  });

  test('admin exports each entry, including breakouts and removed prompts',
      () async {
    final entries = (await get('admin')).entries;
    expect(entries, hasLength(4));
    expect(entries.where((e) => e.agendaItemId == 'removed'), hasLength(2));
    final word = entries.firstWhere((e) => e.message == '世界 🌍');
    expect(word.prompt, 'What matters?');
    expect(word.createdDate, time);
    expect(word.upvotes, 0);
    expect(entries.firstWhere((e) => e.message == 'Listening').roomId, 'room');
    final legacy = entries.firstWhere((e) => e.message == 'Legacy');
    expect(legacy.prompt, 'Older prompt');
    expect(legacy.createdDate, isNull);
    expect(entries.any((e) => e.message == 'Must not leak'), isFalse);
  });
  test('event creator retains existing export access without membership',
      () async {
    expect((await get('creator')).entries, hasLength(4));
  });
  test('accepts a slash-prefixed event path', () async {
    expect((await get('admin', '/$path')).entries, hasLength(4));
  });
  for (final user in ['member', 'outsider', null]) {
    test('denies export to $user', () async {
      await expectLater(get(user), throwsA(isA<HttpsError>()));
    });
  }
  test('rejects paths with extra segments', () async {
    await expectLater(get('admin', '$path/extra'), throwsA(isA<HttpsError>()));
  });
}
