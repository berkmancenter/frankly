import 'dart:async';
import 'dart:io';

import 'abstract_calendar_feed.dart';
import '../../utils/ics_util.dart';
import 'package:data_models/firestore/community.dart';

/// Generate and return an ICS feed of upcoming events for a given space. This function expects
/// the space id to be present as the second request path parameter, as in '/space/[space_id]/ics'.
class CalendarFeedIcs extends AbstractCalendarFeed {
  @override
  final String functionName = 'CalendarFeedIcs';

  @override
  Future<String> generateData({required Community community}) {
    return icsUtil.getIcsForUpcomingEvents(community: community);
  }

  @override
  ContentType getContentType() {
    return ContentType('text', 'calendar');
  }
}
