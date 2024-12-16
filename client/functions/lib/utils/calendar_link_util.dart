import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/interop/calendar_link_lib.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';

final calendarLinkUtil = CalendarLinkUtil();
final prodDomain = functions.config.get('app.prod_domain') as String;
final devDomain = functions.config.get('app.dev_domain') as String;

class CalendarLinkUtil {
  CalendarLinkLib? _lib;

  CalendarLinkLib getLib() => _lib ??= requireCalendarLink();

  Event _getEvent({
    required Junto junto,
    required Topic topic,
    required Discussion discussion,
    admin_interop.UserRecord? organizer,
  }) {
    final domain = isDev ? devDomain : prodDomain;
    final discussionTitle = discussion.title ?? topic.title;
    final time = (discussion.scheduledTime ?? DateTime.now()).toUtc();
    final duration = Duration(minutes: discussion.durationInMinutes);
    final event = Event()
      ..title = '$discussionTitle - ${junto.name}'
      ..start = time.toIso8601String()
      ..end = time.add(duration).toIso8601String()
      ..organizer = 'mailto:${organizer?.email ?? ''}'
      ..description =
          'https://$domain/space/${discussion.juntoId}/discuss/${discussion.topicId}/${discussion.id}';
    return event;
  }

  String getGoogleLink({
    required Junto junto,
    required Topic topic,
    required Discussion discussion,
  }) {
    return getLib().google(_getEvent(
      junto: junto,
      topic: topic,
      discussion: discussion,
    ));
  }

  String getOffice365Link({
    required Junto junto,
    required Topic topic,
    required Discussion discussion,
  }) {
    return getLib().office365(_getEvent(
      junto: junto,
      topic: topic,
      discussion: discussion,
    ));
  }

  String getOutlookLink({
    required Junto junto,
    required Topic topic,
    required Discussion discussion,
  }) {
    return getLib().outlook(_getEvent(
      junto: junto,
      topic: topic,
      discussion: discussion,
    ));
  }

  String getICS({
    required Junto junto,
    required Topic topic,
    required Discussion discussion,
    admin_interop.UserRecord? organizer,
  }) {
    // return just the ICS content
    // see https://github.com/AnandChowdhary/calendar-link/issues/208#issuecomment-691675931
    final ics = getLib().ics(_getEvent(
      junto: junto,
      topic: topic,
      discussion: discussion,
      organizer: organizer,
    ));
    return Uri.decodeComponent(ics.split('charset=utf8,')[1]);
  }
}
