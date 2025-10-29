import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'calendar_link_lib.dart' as cl;
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/templates/template.dart';

final calendarLinkUtil = CalendarLinkUtil();

class CalendarLinkUtil {
  cl.CalendarLinkLib? _lib;

  cl.CalendarLinkLib getLib() => _lib ??= cl.requireCalendarLink();

  cl.Event _getEvent({
    required Community community,
    required Template template,
    required Event event,
    admin_interop.UserRecord? organizer,
  }) {
    final domain = functions.config.get('app.domain') as String;
    final eventTitle = event.title ?? template.title;
    final time = (event.scheduledTime ?? DateTime.now()).toUtc();
    final duration = Duration(minutes: event.durationInMinutes);
    final calendarEvent = cl.Event()
      ..title = '$eventTitle - ${community.name}'
      ..start = time.toIso8601String()
      ..end = time.add(duration).toIso8601String()
      ..organizer = 'mailto:${organizer?.email ?? ''}'
      ..description =
          'https://$domain/space/${event.communityId}/discuss/${event.templateId}/${event.id}';
    return calendarEvent;
  }

  String getGoogleLink({
    required Community community,
    required Template template,
    required Event event,
  }) {
    return getLib().google(
      _getEvent(
        community: community,
        template: template,
        event: event,
      ),
    );
  }

  String getOffice365Link({
    required Community community,
    required Template template,
    required Event event,
  }) {
    return getLib().office365(
      _getEvent(
        community: community,
        template: template,
        event: event,
      ),
    );
  }

  String getOutlookLink({
    required Community community,
    required Template template,
    required Event event,
  }) {
    // Manually construct the Outlook link since the calendar-link library's
    // outlook() method does has a bug where it does not translate the
    // time to the string that Outlook expects when it is converting to a user's local time zone
    // See: https://github.com/AnandChowdhary/calendar-link/issues/523
    
    var eventDetails = _getEvent(
      community: community,
      template: template,
      event: event,
    );
    final details = <String, String>{
      'path': '/calendar/action/compose',
      'rru': 'addevent',
      'startdt': eventDetails.start,
      'enddt': eventDetails.end,
      'subject': eventDetails.title,
      'body': eventDetails.description,
      'location': eventDetails.description,
      'allday': 'false',
    };

    final queryString = details.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',)
        .join('&');
    return 'https://outlook.live.com/calendar/0/action/compose?$queryString';
  }

  String getICS({
    required Community community,
    required Template template,
    required Event event,
    admin_interop.UserRecord? organizer,
  }) {
    // return just the ICS content
    // see https://github.com/AnandChowdhary/calendar-link/issues/208#issuecomment-691675931
    final ics = getLib().ics(
      _getEvent(
        community: community,
        template: template,
        event: event,
        organizer: organizer,
      ),
    );
    return Uri.decodeComponent(ics.split('charset=utf8,')[1]);
  }
}
