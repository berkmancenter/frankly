@TestOn('browser')
library;

import 'dart:convert';
// This browser-only test intercepts the native anchor used for downloads.
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:csv/csv.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/user_input/chat_suggestion_data.dart';
import 'package:data_models/user_input/emotion.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnusedCommunityProvider implements CommunityProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('chat download identifies UTF-8 and preserves emoji and CSV cells',
      () async {
    // Capture the real download without navigating away from the test runner.
    js.context.callMethod('eval', [
      r'''
      window.originalChatCsvClick = HTMLAnchorElement.prototype.click;
      HTMLAnchorElement.prototype.click = function () {
        window.chatCsvDownloadHref = this.href;
        window.chatCsvDownloadName = this.download;
      };
    '''
    ]);
    addTearDown(() {
      js.context.callMethod('eval', [
        r'''
        HTMLAnchorElement.prototype.click = window.originalChatCsvClick;
        delete window.originalChatCsvClick;
        delete window.chatCsvDownloadHref;
        delete window.chatCsvDownloadName;
      '''
      ]);
    });

    final provider = EventProvider(
      communityProvider: _UnusedCommunityProvider(),
      templateId: 'template',
      eventId: 'event',
    );
    final date = DateTime.utc(2026, 9, 8, 12);
    const message = 'Hello, "世界" 👩🏽‍💻\nCafé';
    await provider.generateChatDataCsv(
      response: GetMeetingChatsSuggestionsDataResponse(
        chatsSuggestionsList: [
          ChatSuggestionData(
            createdDate: date,
            creatorId: 'user',
            message: message,
            roomId: 'event',
            deleted: false,
          ),
          for (final emotion in EmotionType.values)
            ChatSuggestionData(
              createdDate: date,
              emotionType: emotion,
              roomId: 'waiting-room',
              deleted: false,
            ),
          ChatSuggestionData(
            createdDate: date,
            message: '=1+1',
            deleted: true,
          ),
          ChatSuggestionData(
            createdDate: date,
            type: ChatSuggestionType.suggestion,
            message: 'Not a chat message',
          ),
        ],
      ),
      eventId: 'event',
      breakoutRooms: [],
    );

    expect(js.context['chatCsvDownloadName'], 'chat-data-event.csv');
    final uri = Uri.parse(js.context['chatCsvDownloadHref'] as String);
    final bytes = uri.data!.contentAsBytes();
    expect(
      bytes.take(3).toList(),
      [0xef, 0xbb, 0xbf],
      reason: 'Excel needs the UTF-8 BOM when opening the downloaded CSV.',
    );
    final rows = const CsvToListConverter(shouldParseNumbers: false)
        .convert(utf8.decode(bytes));
    expect(rows.first, ['Time', 'User ID', 'Message', 'Room', 'Deleted']);
    expect(rows.length, 10);
    expect(rows[1][2], message);
    expect(rows[1][3], 'Main room');
    expect(
      rows.sublist(2, 9).map((row) => row[2]).toList(),
      ['👍', '❤️', '💯', '‼️', '➕', '😂', '😍'],
    );
    expect(rows.sublist(2, 9).every((row) => row[3] == 'Waiting room'), isTrue);
    expect(rows.last[2], "'=1+1");
    expect(rows.last[4], 'true');
  });
}
