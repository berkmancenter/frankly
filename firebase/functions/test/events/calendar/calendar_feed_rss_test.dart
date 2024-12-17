import 'dart:io';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/calendar/calendar_feed_rss.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:functions/utils/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';

void main() {
  String communityId = '';
  const userId = 'fakeAuthId';
  const templateId = '9654988';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);

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

  test('RSS calendar feed generated', () async {
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

    final calFeed = CalendarFeedRss();

    await calFeed.expressAction(mockRequest);

    const expectedData1 =
        '<?xml version="1.0"?><rss version="2.0" xmlns:Frankly="https://www.app.frankly.org/xmlns" xmlns:media="http://search.yahoo.com/mrss/" xmlns:atom="http://www.w3.org/2005/Atom"><channel><title>Testing Community</title><description></description>';

    const expectedData2 = '<item><title>Event</title>';

    expect(writtenData, contains(expectedData1));
    expect(writtenData, contains(expectedData2));
  });
}

class MockExpressHttpRequest extends Mock implements ExpressHttpRequest {}

class MockHttpResponse extends Mock implements HttpResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}
