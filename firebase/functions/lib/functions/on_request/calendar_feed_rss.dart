import 'dart:async';
import 'dart:io';

import 'package:functions/functions/on_request/abstract_calendar_feed.dart';
import 'package:functions/utils/rss_util.dart';
import 'package:data_models/firestore/community.dart';

/// Generate and return an RSS feed of upcoming events for a given space. This function expects
/// the space id to be present as the second request path parameter, as in '/space/[space_id]/rss'.
class CalendarFeedRss extends AbstractCalendarFeed {
  @override
  final String functionName = 'CalendarFeedRss';

  @override
  Future<String> generateData({required Community community}) {
    return rssUtil.getRssForUpcomingEvents(community: community);
  }

  @override
  ContentType getContentType() {
    return ContentType('application', 'xml');
  }
}
