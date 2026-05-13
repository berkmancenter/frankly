import { AbstractCalendarFeed } from './abstract_calendar_feed';
import { rssUtil } from './rss_util';

export class CalendarFeedRss extends AbstractCalendarFeed {
  readonly functionName = 'CalendarFeedRss';

  async generateData({ community }: { community: Record<string, unknown> }): Promise<string> {
    return rssUtil.getRssForUpcomingEvents({ community });
  }

  getContentType(): string {
    return 'application/xml';
  }
}
