import 'dart:async';
import 'dart:io';

import 'package:junto_functions/functions/on_request/abstract_calendar_feed.dart';
import 'package:junto_functions/utils/rss_util.dart';
import 'package:junto_models/firestore/junto.dart';

/// Generate and return an RSS feed of upcoming discussions for a given space. This function expects
/// the space id to be present as the second request path parameter, as in '/space/[space_id]/rss'.
class CalendarFeedRss extends AbstractCalendarFeed {
  @override
  final String functionName = 'CalendarFeedRss';

  @override
  Future<String> generateData({required Junto junto}) {
    return rssUtil.getRssForUpcomingEvents(junto: junto);
  }

  @override
  ContentType getContentType() {
    return ContentType('application', 'xml');
  }
}
