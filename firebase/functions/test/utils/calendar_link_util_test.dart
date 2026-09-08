import 'package:data_models/community/community.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/utils/calendar_link_util.dart';
import 'package:test/test.dart';

void main() {
  final community = Community(id: 'community', name: 'Calendar & Community');
  const template = Template(id: 'template', title: 'Template');
  final event = Event(
    id: 'event',
    status: EventStatus.active,
    communityId: community.id,
    templateId: template.id,
    collectionPath: 'community/community/templates/template/events',
    creatorId: 'organizer',
    title: 'Discussion & questions',
    scheduledTime: DateTime.utc(2026, 10, 1, 14),
    durationInMinutes: 60,
  );
  final util = CalendarLinkUtil();
  final eventUrl = 'https://${functions.config.get('app.domain')}'
      '/space/community/discuss/template/event';

  for (final entry in {
    'Google Calendar': util.getGoogleLink,
    'Office 365': util.getOffice365Link,
    'Outlook': util.getOutlookLink,
  }.entries) {
    test('${entry.key} includes the event URL as location', () {
      final link = entry.value(
        community: community,
        template: template,
        event: event,
      );
      final query = Uri.parse(link).queryParameters;
      expect(query['location'], eventUrl);
      expect(
        query[entry.key == 'Google Calendar' ? 'details' : 'body'],
        eventUrl,
      );
      expect(
        query[entry.key == 'Google Calendar' ? 'text' : 'subject'],
        'Discussion & questions - Calendar & Community',
      );
    });
  }

  test('ICS includes the event URL as location and preserves description', () {
    final ics = util.getICS(
      community: community,
      template: template,
      event: event,
    );
    // RFC 5545 permits long properties to fold onto continuation lines.
    final unfolded = ics.replaceAll(RegExp(r'\r?\n[ \t]'), '');
    expect(unfolded, contains('LOCATION:$eventUrl'));
    expect(unfolded, contains('DESCRIPTION:$eventUrl'));
    expect(unfolded, contains('DTSTART:20261001T140000Z'));
    expect(unfolded, contains('DTEND:20261001T150000Z'));
  });
}
