import { AbstractCalendarFeed } from './abstract_calendar_feed';
import { icsUtil } from '../../utils/ics_util';

export class CalendarFeedIcs extends AbstractCalendarFeed {
  readonly functionName = 'CalendarFeedIcs';

  async generateData({ community }: { community: Record<string, unknown> }): Promise<string> {
    return icsUtil.getIcsForUpcomingEvents({ community: community as any });
  }

  getContentType(): string {
    return 'text/calendar';
  }
}
