import * as functions from 'firebase-functions';
import { firestore, firestoreUtils } from './infra/firestore_utils';
import { calendarLinkUtil } from './calendar_link_util';
import { Community, Event, Template } from '../types';
import { TemplateUtils } from './template_utils';

export class ShareLink {
  readonly functionName = 'ShareLink';

  private get _appName(): string {
    return functions.config().app?.name as string;
  }

  private _getRedirect(requestedUri: string): string {
    if (requestedUri.includes('/share/community/')) {
      return requestedUri.replace('/share/community/', '/space/');
    } else if (requestedUri.includes('/share/')) {
      return requestedUri.replace('/share/', '/');
    }
    return requestedUri;
  }

  private _getAppPath(requestedUri: string): string {
    const parsed = new URL(requestedUri);
    return parsed.pathname.split('/').slice(2).join('/');
  }

  private async _getHtmlContent(requestedUri: string, isLinkedIn = false): Promise<string> {
    const redirect = this._getRedirect(requestedUri);
    const appPath = this._getAppPath(requestedUri);

    let title = `${this._appName} - Real Deliberations, Meaningful Communities`;
    let image = functions.config().app?.banner_image_url as string;
    let description = 'Deliberations with real people in real time, for any interest.';

    const eventMatch = appPath.match(/(?:space|community)\/([^/]+)\/discuss\/([^/]+)\/([^/]+)/);
    const communityMatch = appPath.match(/(?:space|community)\/([^/]+)/);

    if (eventMatch) {
      const communityId = eventMatch[1];
      const templateId = eventMatch[2];
      const eventId = eventMatch[3];

      const communityDoc = await firestore.doc(`community/${communityId}`).get();
      const community = { ...(firestoreUtils.fromFirestoreJson(communityDoc.data() ?? {}) as unknown as Community), id: communityDoc.id };

      const templateDoc = await firestore.doc(`community/${communityId}/templates/${templateId}`).get();
      const template = TemplateUtils.templateFromSnapshot(templateDoc);

      const eventDoc = await firestore.doc(`community/${communityId}/templates/${templateId}/events/${eventId}`).get();
      const event = { ...(firestoreUtils.fromFirestoreJson(eventDoc.data() ?? {}) as unknown as Event), id: eventDoc.id };

      const scheduledTimeUtc = event.scheduledTime;
      const tz = event.scheduledTimeZone ?? 'America/Los_Angeles';
      const timeZoneAbbr = new Intl.DateTimeFormat('en-US', { timeZone: tz, timeZoneName: 'short' })
        .formatToParts(scheduledTimeUtc ?? new Date())
        .find((p) => p.type === 'timeZoneName')?.value ?? tz;

      const date = scheduledTimeUtc
        ? new Intl.DateTimeFormat('en-US', { timeZone: tz, weekday: 'short', month: 'short', day: 'numeric' }).format(scheduledTimeUtc)
        : '';
      const time = scheduledTimeUtc
        ? new Intl.DateTimeFormat('en-US', { timeZone: tz, hour: 'numeric', minute: '2-digit' }).format(scheduledTimeUtc)
        : '';

      title = `Join my event on ${event.title ?? template.title}!`;
      description = `${this._appName} - ${date} ${time} ${timeZoneAbbr} - Join ${community.name} on ${this._appName}!`;
      image = event.image ?? template.image ?? community.bannerImageUrl ?? '';
    } else if (communityMatch) {
      const communityId = communityMatch[1];
      const communityDoc = await firestore.doc(`community/${communityId}`).get();
      const community = { ...(communityDoc.data() as Community), id: communityDoc.id };

      title = `${community.name} on ${this._appName}`;
      description = community.description ?? description;
      image = community.bannerImageUrl ?? '';
    }

    if (isLinkedIn && image.includes('picsum.photos') && image.endsWith('.webp')) {
      image = image.slice(0, -5);
    }

    console.log(image);
    return `
      <html>
      <head>
        <meta charset="UTF-8">
        <meta content="IE=Edge" http-equiv="X-UA-Compatible">
        <meta name="description" content="${description}">
        <meta property="og:title" content="${title}"/>
        <meta property="og:description" content="${description}"/>
        <meta property="og:url" content="${requestedUri}"/>
        <meta property="og:image" content="${image}"/>
        <meta name="image" property="og:image" content="${image}">
        <meta name="twitter:title" content="${title}">
        <meta name="twitter:description" content="${description}">
        <meta name="twitter:image" content="${image}">
        <meta name="twitter:card" content="summary_large_image">
        <title>${title}</title>
      </head>
      <body>
        <p><a href="${redirect}">Click here</a> to continue!</p>
      </body>
      </html>
    `;
  }

  async expressAction(req: functions.https.Request, res: import('express').Response): Promise<void> {
    try {
      const requestedUri = req.url;
      console.log(requestedUri);

      const userAgent = (req.headers['user-agent'] ?? '').toLowerCase();
      if (
        userAgent.includes('facebookexternalhit') ||
        userAgent.includes('facebot') ||
        userAgent.includes('twitterbot') ||
        userAgent.includes('linkedinbot')
      ) {
        res.setHeader('Cache-Control', 'no-cache');
        res.send(await this._getHtmlContent(requestedUri, userAgent.includes('linkedinbot')));
      } else {
        res.redirect(this._getRedirect(requestedUri));
      }
    } catch (e) {
      console.error('Error during action', e);
      res.status(500).send(String(e));
    }
  }

  register(): functions.HttpsFunction {
    return functions
      .runWith({ timeoutSeconds: 60, memory: '1GB', minInstances: 0 })
      .https.onRequest((req, res) => this.expressAction(req, res));
  }
}
