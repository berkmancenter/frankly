@TestOn('browser')
library;

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:csv/csv.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/user_input/chat_suggestion_data.dart';
import 'package:data_models/user_input/poll_data.dart';
import 'package:data_models/user_input/word_cloud_data.dart';
import 'package:flutter_test/flutter_test.dart';

class _Community extends Fake implements CommunityProvider {}

void main() {
  setUp(() {
    js.context.callMethod('eval', [
      r'''
      window.originalCsvClick = HTMLAnchorElement.prototype.click;
      HTMLAnchorElement.prototype.click = function() {
        window.csvHref = this.href; window.csvName = this.download;
      };
    '''
    ]);
  });
  tearDown(() {
    js.context.callMethod('eval', [
      r'''
      HTMLAnchorElement.prototype.click = window.originalCsvClick;
      delete window.originalCsvClick; delete window.csvHref; delete window.csvName;
    '''
    ]);
  });
  for (final mixed in [false, true]) {
    test('exports ${mixed ? 'mixed' : 'word-cloud-only'} prompt responses',
        () async {
      final time = DateTime.utc(2026, 9, 8, 12);
      final provider = EventProvider(
        communityProvider: _Community(),
        templateId: 'template',
        eventId: 'event',
      );
      await provider.generatePollsSuggestionsDataCsv(
        eventId: 'event',
        agendaItems: [AgendaItem(id: 'suggestion', title: 'Ideas')],
        suggestionData: mixed
            ? [
                ChatSuggestionData(
                  agendaItemId: 'suggestion',
                  createdDate: time,
                  message: 'Suggestion',
                  creatorId: 'user',
                ),
              ]
            : [],
        pollData: mixed
            ? [
                PollData(
                  answeredDate: time,
                  pollQuestion: 'Vote?',
                  pollResponse: 'Yes',
                  userId: 'user',
                ),
              ]
            : [],
        wordCloudData: [
          WordCloudData(
            userId: 'user',
            agendaItemId: 'one',
            roomId: 'event',
            prompt: 'What matters?',
            message: 'Hello, "世界" 🌍\nCafé',
            createdDate: time,
          ),
          WordCloudData(
            userId: 'user',
            agendaItemId: 'one',
            roomId: 'waiting-room',
            prompt: 'What matters?',
            message: '=1+1',
            createdDate: time,
          ),
          const WordCloudData(
            userId: 'other',
            agendaItemId: 'two',
            roomId: 'room',
            prompt: 'Next steps?',
            message: 'Legacy',
          ),
        ],
        breakoutRooms: [
          BreakoutRoom(
            roomId: 'room',
            roomName: '2',
            orderingPriority: 2,
            creatorId: 'admin',
          ),
        ],
      );
      expect(js.context['csvName'], 'prompt-responses-event.csv');
      final bytes =
          Uri.parse(js.context['csvHref'] as String).data!.contentAsBytes();
      expect(bytes.take(3), [0xef, 0xbb, 0xbf]);
      final rows = const CsvToListConverter(shouldParseNumbers: false)
          .convert(utf8.decode(bytes));
      expect(rows.first, [
        'Type',
        'Time',
        'User ID',
        'Prompt',
        'Response',
        'Room',
        'Upvotes',
        'Downvotes',
        'Deleted',
      ]);
      expect(rows.length, mixed ? 6 : 4);
      final words = rows.where((r) => r.first == 'Wordcloud').toList();
      expect(words, hasLength(3));
      expect(words[0][4], 'Hello, "世界" 🌍\nCafé');
      expect(words[1][4], "'=1+1");
      expect(words.map((r) => r[5]), ['Main room', 'Waiting room', '2']);
      expect(words[2][1], '');
      expect(words[2][3], 'Next steps?');
      expect(words.every((r) => r[6] == '0'), isTrue);
      if (mixed) {
        expect(rows.map((r) => r.first), containsAll(['Poll', 'Suggestion']));
      }
    });
  }
}
