import * as functions from 'firebase-functions';
import { auth } from 'firebase-admin';
import { Community, Event, Template, Participant, Announcement, EventMessage, EventEmailType } from '../types';
import { isNullOrEmpty } from './utils';
import { calendarLinkUtil } from './calendar_link_util';
import { timezoneUtils } from './timezone_utils';

const getConfig = (key: string): string => {
  const parts = key.split('.');
  let val: unknown = functions.config();
  for (const p of parts) {
    val = (val as Record<string, unknown>)?.[p];
  }
  return (val as string) ?? '';
};

const privacyPolicyUrl = () => getConfig('app.privacy_policy_url');
const mailingAddress = () => getConfig('app.mailing_address');
const orgName = () => getConfig('app.legal_entity_name');
const linkPrefix = () => getConfig('app.full_url');
const appName = () => getConfig('app.name');
const copyright = () => getConfig('app.copyright');
const legalStatement = () => `${appName()} is operated by ${orgName()}.`;
const copyrightStatement = () => `© ${copyright()}`;

function htmlEscape(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

export function generateEmailEventInfo({
  actionTitle,
  cancellation,
  eventTitle,
  eventDateDisplay,
  eventImage,
  bannerImgUrl,
  communityId,
  communityName,
  communityUrl,
  cancelUrl,
  detailsUrl,
  participantsText,
  header,
  calendarGoogleLink,
  calendarOffice365Link,
  calendarOutlookLink,
  event,
  userRecord,
  allowPrePost,
}: {
  actionTitle: string;
  cancellation: boolean;
  eventTitle: string;
  eventDateDisplay: string;
  eventImage?: string;
  bannerImgUrl: string;
  communityId: string;
  communityName?: string;
  communityUrl: string;
  cancelUrl: string;
  detailsUrl: string;
  participantsText: string;
  header: string;
  calendarGoogleLink: string;
  calendarOffice365Link: string;
  calendarOutlookLink: string;
  event: Event;
  userRecord: auth.UserRecord;
  allowPrePost: boolean;
}): string {
  const settingsUrl = `${linkPrefix()}/settings?initialSection=notifications&communityId=${communityId}`;
  const actionTitleSanitized = htmlEscape(actionTitle);
  const eventTitleSanitized = htmlEscape(eventTitle);
  const eventImageSanitized = htmlEscape(eventImage ?? '');
  const communityNameSanitized = htmlEscape(communityName ?? '');
  const imageHtml = isNullOrEmpty(bannerImgUrl) ? '' :
    `<span class="title-community-image"><img width="48" src="${htmlEscape(bannerImgUrl)}"/></span>`;

  const supplement = cancellation ? `
    <div class="section"><div class="center">This event has been cancelled.</div></div>` : `
    <div class="section">
      <div class="center">Add to calendar:</div>
      <div class="center">
        <a href="${calendarGoogleLink}" style="color:#313030;"><b>Google</b></a>
        ·
        <a href="${calendarOffice365Link}" style="color:#313030;"><b>Office 365</b></a>
        ·
        <a href="${calendarOutlookLink}" style="color:#313030;"><b>Outlook</b></a>
      </div>
    </div>`;

  return `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html><head><meta charset="UTF-8"/><title>Email</title></head>
<body>
  <div style="max-width:640px;font-family:Helvetica,Arial,sans-serif;">
    <div style="text-align:center;font-size:24px;color:#313030;margin:20px;">
      ${imageHtml}
      <span style="font-weight:bold;">${communityNameSanitized}</span>
      <span style="margin:0 4px;color:#d7d3d3;font-size:32px;">//</span>
      <span>${actionTitleSanitized}</span>
    </div>
    <hr/>
    <div style="text-align:center;font-size:18px;font-weight:bold;color:#313030;margin:24px 0;">${header}</div>
    <div style="max-width:520px;margin:auto;background:#f1edec;padding:8px;">
      <table><tr>
        <td><img src="${eventImageSanitized}" width="52"/></td>
        <td style="width:100%;">
          <div style="font-size:16px;font-weight:bold;">${eventTitleSanitized}</div>
          <div style="font-size:14px;">${htmlEscape(eventDateDisplay)}</div>
        </td>
        <td><a style="color:#d7d3d3;font-size:14px;background:#313030;padding:8px;border-radius:8px;text-decoration:none;" href="${detailsUrl}">Go To Event</a></td>
      </tr></table>
    </div>
    ${supplement}
    <div style="padding:8px;background:#313030;text-align:center;">
      <div style="font-size:14px;color:#fff;">${legalStatement()}</div><br/>
      <div style="color:#fff;font-size:12px;">${mailingAddress()}</div>
      <a style="color:#8e9192;font-size:12px;" href="${settingsUrl}">Notification Settings</a><br/>
      <a style="color:#8e9192;font-size:12px;" href="${privacyPolicyUrl()}">Privacy Statement</a><br/><br/>
      <div style="color:#fff;font-size:10px;">${copyrightStatement()}</div>
    </div>
  </div>
</body></html>`;
}

export function generateEventEndedContent({
  community,
  header,
  event,
  userRecord,
  allowPrePost,
}: {
  community: Community;
  header: string;
  event: Event;
  userRecord: auth.UserRecord;
  allowPrePost: boolean;
}): string {
  const communityNameSanitized = htmlEscape(community.name ?? '');
  const settingsUrl = `${linkPrefix()}/settings?initialSection=notifications&communityId=${community.id}`;
  const communityUrl = `${linkPrefix()}/space/${event.communityId}`;
  let bannerImgUrl = community.profileImageUrl ?? '';
  if (bannerImgUrl.includes('picsum')) bannerImgUrl = bannerImgUrl.replace('.webp', '.jpg');

  const imageHtml = isNullOrEmpty(bannerImgUrl) ? '' :
    `<span style="display:inline-block;width:48px;height:48px;border-radius:8px;overflow:hidden;"><img width="48" src="${htmlEscape(bannerImgUrl)}"/></span>`;

  return `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html><head><meta charset="UTF-8"/></head>
<body style="font-family:Helvetica,Arial,sans-serif;">
  <div style="max-width:640px;">
    <div style="text-align:center;font-size:24px;color:#313030;margin:20px;">
      ${imageHtml}
      <span style="font-weight:bold;">${communityNameSanitized}</span>
    </div>
    <hr/>
    <div style="text-align:center;font-size:18px;font-weight:bold;color:#313030;margin:24px 0;">${header}</div>
    <div style="max-width:520px;margin:auto;text-align:center;padding:20px;">
      <a style="color:#d7d3d3;background:#313030;padding:12px 20px;border-radius:8px;text-decoration:none;" href="${communityUrl}">See More Events</a>
    </div>
    <div style="padding:8px;background:#313030;text-align:center;">
      <div style="font-size:14px;color:#fff;">${legalStatement()}</div><br/>
      <div style="color:#fff;font-size:12px;">${mailingAddress()}</div>
      <a style="color:#8e9192;font-size:12px;" href="${settingsUrl}">Notification Settings</a><br/>
      <a style="color:#8e9192;font-size:12px;" href="${privacyPolicyUrl()}">Privacy Statement</a><br/><br/>
      <div style="color:#fff;font-size:10px;">${copyrightStatement()}</div>
    </div>
  </div>
</body></html>`;
}

export function makeNewAnnouncementBody({
  community,
  unsubscribeUrl,
  announcement,
}: {
  community: Community;
  unsubscribeUrl: string;
  announcement?: Announcement;
}): string {
  const communityName = htmlEscape(community.name ?? community.id ?? '');
  const title = htmlEscape(announcement?.title ?? '');
  const message = htmlEscape((announcement?.message as string) ?? '');
  const creatorDisplayName = htmlEscape((announcement?.creatorDisplayName as string) ?? 'Admin');
  const announcementUrl = `${linkPrefix()}/space/${community.id}`;
  const settingsUrl = `${linkPrefix()}/settings?initialSection=notifications&communityId=${community.id}`;
  const imageHtml = isNullOrEmpty(community.profileImageUrl) ? '' :
    `<span style="display:inline-block;width:48px;height:48px;border-radius:8px;"><img width="48" src="${htmlEscape(community.profileImageUrl ?? '')}"/></span>`;

  return `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html><head><meta charset="UTF-8"/></head>
<body style="font-family:Helvetica,Arial,sans-serif;">
  <div style="max-width:640px;">
    <div style="text-align:center;font-size:24px;margin:20px;">
      ${imageHtml}
      <span style="font-weight:bold;">${communityName}</span>
      <span style="color:#d7d3d3;">//</span>
      <span>Announcement</span>
    </div>
    <hr/>
    <div style="text-align:center;font-size:18px;font-weight:bold;color:#313030;margin:24px 0;">${creatorDisplayName} posted a new announcement:</div>
    <div style="background:#f1edec;padding:10px;margin:8px 4px;text-align:center;">
      <div style="font-weight:bold;margin:10px;">${title}</div>
      <div style="margin:10px;">${message}</div>
    </div>
    <div style="text-align:center;padding:20px;">
      <a style="color:#d7d3d3;background:#313030;padding:8px 20px;border-radius:8px;text-decoration:none;" href="${announcementUrl}">View Announcement</a>
    </div>
    <div style="padding:8px;background:#313030;text-align:center;">
      <div style="font-size:14px;color:#fff;">${legalStatement()}</div><br/>
      <div style="color:#fff;font-size:12px;">${mailingAddress()}</div>
      <a style="color:#8e9192;font-size:12px;" href="${settingsUrl}">Notification Settings</a><br/>
      <a style="color:#8e9192;font-size:12px;" href="${privacyPolicyUrl()}">Privacy Statement</a><br/><br/>
      <div style="color:#fff;font-size:10px;">${copyrightStatement()}</div>
    </div>
  </div>
</body></html>`;
}

export function makeNewEventMessageBody({
  community,
  template,
  event,
  eventMessage,
  unsubscribeUrl,
}: {
  community: Community;
  template: Template;
  event: Event;
  eventMessage: EventMessage;
  unsubscribeUrl: string;
}): string {
  const communityName = htmlEscape(community.name ?? '');
  const imageHtml = isNullOrEmpty(community.profileImageUrl) ? '' :
    `<span style="display:inline-block;width:48px;height:48px;border-radius:8px;"><img width="48" src="${htmlEscape(community.profileImageUrl ?? '')}"/></span>`;
  const url = `${linkPrefix()}/space/${community.id}/discuss/${event.templateId}/${event.id}`;
  const cancelUrl = `${url}?cancel=true`;
  const settingsUrl = `${linkPrefix()}/settings?initialSection=notifications&communityId=${community.id}`;
  const calendarGoogleLink = calendarLinkUtil.getGoogleLink({ community, template, event });
  const calendarOffice365Link = calendarLinkUtil.getOffice365Link({ community, template, event });
  const calendarOutlookLink = calendarLinkUtil.getOutlookLink({ community, template, event });

  const eventImage = htmlEscape(event.image ?? template.image ?? '');
  const eventTitle = htmlEscape(event.title ?? template.title ?? '');

  return `<!DOCTYPE html><html><head><meta charset="UTF-8"/></head>
<body style="font-family:Helvetica,Arial,sans-serif;">
  <div style="max-width:640px;">
    <div style="text-align:center;font-size:24px;margin:20px;">
      ${imageHtml}
      <span style="font-weight:bold;">${communityName}</span>
      <span style="color:#d7d3d3;">//</span>
      <span>Event Update</span>
    </div>
    <hr/>
    <div style="text-align:center;font-size:20px;font-weight:bold;margin:24px 0;">New Announcement for your Upcoming Event</div>
    <div style="background:#f1edec;padding:4px;margin:8px 4px;">
      <table><tr>
        <td><img src="${eventImage}" width="52"/></td>
        <td style="width:100%;"><div style="font-weight:bold;">${eventTitle}</div></td>
        <td><a style="color:#d7d3d3;background:#313030;padding:8px;border-radius:8px;font-size:14px;text-decoration:none;" href="${url}">Go to event</a></td>
      </tr></table>
    </div>
    <div style="background:#f1edec;padding:25px;text-align:center;max-width:520px;margin:auto;">
      <div style="font-size:16px;color:#313030;">"${htmlEscape((eventMessage.message as string) ?? '')}"</div>
    </div>
    <div style="text-align:center;margin:10px;">
      Add to calendar:
      <a href="${calendarGoogleLink}" style="color:#313030;"><b>Google</b></a> ·
      <a href="${calendarOffice365Link}" style="color:#313030;"><b>Office 365</b></a> ·
      <a href="${calendarOutlookLink}" style="color:#313030;"><b>Outlook</b></a>
    </div>
    <hr/>
    <div style="margin:10px;">
      If you can no longer attend, <a href="${cancelUrl}" style="color:#313030;font-weight:bold;">click here to cancel</a>.
    </div>
    <div style="padding:8px;background:#313030;text-align:center;">
      <div style="font-size:14px;color:#fff;">${legalStatement()}</div><br/>
      <div style="color:#fff;font-size:12px;">${mailingAddress()}</div>
      <a style="color:#8e9192;font-size:12px;" href="${settingsUrl}">Notification Settings</a><br/>
      <a style="color:#8e9192;font-size:12px;" href="${privacyPolicyUrl()}">Privacy Statement</a><br/>
      <div style="color:#fff;font-size:10px;">${copyrightStatement()}</div>
    </div>
  </div>
</body></html>`;
}
