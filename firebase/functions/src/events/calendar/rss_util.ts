import * as functions from 'firebase-functions';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';

export const rssUtil = {
  async getRssForUpcomingEvents({ community }: { community: Record<string, unknown> }): Promise<string> {
    const now = new Date();
    const eventsQuery = await firestore
      .collectionGroup('events')
      .where('communityId', '==', (community as any).id)
      .where('isPublic', '==', true)
      .where('status', '==', 'active')
      .where('scheduledTime', '>=', now)
      .orderBy('scheduledTime')
      .get();

    const events = eventsQuery.docs.map((doc) =>
      firestoreUtils.fromFirestoreJson(doc.data()) as unknown as Record<string, unknown>
    );

    const domain = functions.config().app?.domain ?? '';
    const appName = functions.config().app?.name ?? 'frankly';
    const communityDisplayId = (community as any).displayIds?.[0] ?? (community as any).id;
    const link = `https://${domain}/space/${communityDisplayId}`;

    const items = events.map((event: any) => {
      const title = event.title ?? event.name ?? '';
      const description = event.description ?? '';
      const scheduledTime = event.scheduledTime instanceof Date ? event.scheduledTime : new Date(event.scheduledTime);
      const pubDate = scheduledTime.toUTCString();
      const eventLink = `https://${domain}/space/${communityDisplayId}/event/${event.id}`;
      return `<item>
        <title><![CDATA[${title}]]></title>
        <description><![CDATA[${description}]]></description>
        <link>${eventLink}</link>
        <pubDate>${pubDate}</pubDate>
        <guid>${eventLink}</guid>
      </item>`;
    });

    return `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title><![CDATA[${(community as any).name ?? ''}]]></title>
    <description><![CDATA[${(community as any).description ?? ''}]]></description>
    <link>${link}</link>
    <atom:link href="${link}" rel="self" type="application/rss+xml" />
    ${items.join('\n    ')}
  </channel>
</rss>`;
  },
};
