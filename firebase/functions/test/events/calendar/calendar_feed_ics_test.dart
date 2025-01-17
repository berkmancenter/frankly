import 'dart:io';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/calendar/calendar_feed_ics.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';

void main() {
  String communityId = '';
  const userId = 'fakeAuthId';
  const templateId = '9654988';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  setupTestFixture();

  setUp(() async {
    final testCommunity = Community(
      id: '2921159966669',
      name: 'Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final communityResult = await communityTestUtils.createCommunity(
      community: testCommunity,
      userId: userId,
    );
    communityId = communityResult['communityId'];
  });

  test('ICS calendar feed generated', () async {
    const eventId = '123411000ff2837';
    var event = Event(
      id: eventId,
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      isPublic: true,
      scheduledTime: DateTime.now().add(const Duration(hours: 24)),
      agendaItems: [
        AgendaItem(
          id: '55005',
          title: "Role call",
          content: "Shout out if you're here",
        ),
      ],
    );
    event = await eventTestUtils.createEvent(
      event: event,
      userId: userId,
    );

    registerFallbackValue(event);
    final mockRequest = MockExpressHttpRequest();
    final mockResponse = MockHttpResponse();
    final mockHeaders = MockHttpHeaders();

    when(() => mockRequest.response).thenReturn(mockResponse);
    when(() => mockRequest.requestedUri).thenReturn(
      Uri(scheme: 'https', host: 'myapp.org', path: 'space/$communityId/cal'),
    );
    when(() => mockResponse.headers).thenReturn(mockHeaders);
    String? writtenData;
    when(() => mockResponse.write(any())).thenAnswer((invocation) {
      writtenData = invocation.positionalArguments.first as String;
    });

    when(
      () => mockResponse.close(),
    ).thenAnswer((_) async {});

    final calFeed = CalendarFeedIcs();

    await calFeed.expressAction(mockRequest);

    const expectedData = '''BEGIN:VCALENDAR\r
VERSION:2.0\r
CALSCALE:GREGORIAN\r
PRODID:Frankly\r
METHOD:PUBLISH\r
X-PUBLISHED-TTL:PT1H\r
BEGIN:VEVENT\r
UID:$eventId\r
SUMMARY:Event\r''';

    expect(writtenData, contains(expectedData));
  });
}

class MockExpressHttpRequest extends Mock implements ExpressHttpRequest {}

class MockHttpResponse extends Mock implements HttpResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}
