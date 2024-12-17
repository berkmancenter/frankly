import 'dart:convert';

import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:intl/intl.dart';
import 'calendar_link_util.dart';
import 'timezone_utils.dart';
import 'utils.dart';
import 'package:data_models/firestore/announcement.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/event_message.dart';
import 'package:data_models/firestore/community.dart';
import 'package:data_models/firestore/template.dart';
import 'package:timezone/standalone.dart' as tz;

final privacyPolicyUrl =
    functions.config.get('app.privacy_policy_url') as String;
final mailingAddress = functions.config.get('app.mailing_address') as String;
final orgName = functions.config.get('app.legal_entity_name') as String;
final linkPrefix = functions.config.get('app.full_url') as String;
final appName = functions.config.get('app.name') as String;
final copyright = functions.config.get('app.copyright') as String;
final legalStatement = '$appName is operated by $orgName.';
final copyrightStatement = '© $copyright';

class EventWithTemplate {
  final Event event;
  final Template template;

  const EventWithTemplate(this.event, this.template);
}

String generateEmailEventInfo({
  required String actionTitle,
  required bool cancellation,
  required String eventTitle,
  required String eventDateDisplay,
  required String? eventImage,
  required String bannerImgUrl,
  required String communityId,
  required String? communityName,
  required String communityUrl,
  required String cancelUrl,
  required String detailsUrl,
  required String participantsText,
  required String header,
  required String calendarGoogleLink,
  required String calendarOffice365Link,
  required String calendarOutlookLink,
  required Event event,
  required admin_interop.UserRecord userRecord,
  required bool allowPrePost,
}) {
  const htmlEscape = HtmlEscape();
  final actionTitleSanitized = htmlEscape.convert(actionTitle);
  final eventTitleSanitized = htmlEscape.convert(eventTitle);
  final eventImageSanitized = htmlEscape.convert(eventImage ?? '');
  final communityNameSanitized = htmlEscape.convert(communityName ?? '');
  final settingsUrl =
      '$linkPrefix/settings?initialSection=notifications&communityId=$communityId';

  final imageHtml = isNullOrEmpty(bannerImgUrl)
      ? ''
      : '''
        <span class="title-community-image">
          <img width="48" src="${htmlEscape.convert(bannerImgUrl)}"/>
        </span>
      ''';

  final supplement = cancellation
      ? '''
      <hr/>
      <div class="section supplement-text">
          Still interested in joining an event? View other events in your space
          <a href="$communityUrl" class="text-button">here</a>.
      </div>
      '''
      : '''
      <div class="section">
          <div class="center">Add to calendar:</div>
          <div class="center">
            <a href="$calendarGoogleLink" style="color:#303B5F;"><b>Google</b></a>
            ·
            <a href="$calendarOffice365Link" style="color:#303B5F;"><b>Office 365</b></a>
            ·
            <a href="$calendarOutlookLink" style="color:#303B5F;"><b>Outlook</b></a>
          </div>
      </div>
      <hr/>
      <div class="section supplement-text">
          No-shows ruin the fun for everyone. If you can no longer attend,
          <a href="$cancelUrl" class="text-button">click here</a>
          to cancel and let the other participants know.
      </div>
      ''';

  String preEventSurveyCardHtml = '';
  final prePostCard = event.preEventCardData;
  if (allowPrePost && prePostCard != null && prePostCard.hasData) {
    const htmlEscape = HtmlEscape();
    final headlineSanitized = htmlEscape.convert(prePostCard.headline);
    final messageSanitized = htmlEscape.convert(prePostCard.message);
    final List<String> buttonSectionHtmlList = [];

    for (var urlInfo in prePostCard.prePostUrls) {
      final bool isButtonSectionShown = !isNullOrEmpty(urlInfo.surveyUrl);
      final buttonText = urlInfo.buttonText;
      final buttonTextSanitized = htmlEscape.convert(
        buttonText == null || buttonText.isEmpty ? 'Visit Link' : buttonText,
      );
      final surveyUri = prePostCard.getFinalisedUrl(
        userId: userRecord.uid,
        event: event,
        email: userRecord.email,
        urlInfo: urlInfo,
      );

      final buttonHtml = !isButtonSectionShown
          ? ''
          : '''
    <a href="$surveyUri">
            <div style="font-family: Helvetica, Arial, sans-serif;       
            background: #9BFBC2;
            color: #303B5F;
            padding-top: 12px;
            padding-bottom: 12px;
            padding-left: 18px;
            padding-right: 18px;             
            border-radius: 10px;
            align-items: center;
            width: 133px;
            text-align: center;
            font-style: normal;
            font-weight: 500;
            font-size: 16px;
            line-height: 150%;">$buttonTextSanitized
            </div>
    </a>''';

      buttonSectionHtmlList.add(buttonHtml);
    }

    final buttonSectionHtml = buttonSectionHtmlList.join('<br />');

    preEventSurveyCardHtml = '''
 <div style="max-width: 520px;
            border-radius: 25px;
            margin: auto;
            background: #303B5F;
            padding: 40px;">
  <p style="color:#9BFBC2;
			      font-family: Helvetica, Arial, sans-serif;
            font-size: 16px;
            font-weight: lighter;
            line-height: 24px;
            letter-spacing: 0.1em;
            text-transform: uppercase;"> If you haven't already done so... </p>
  <p style="color:#FFFFFF;         
			      font-family: Helvetica, Arial, sans-serif;
            font-size: 24px;
            font-weight: bold;
            font-size: 24px;
            line-height: 110%;">$headlineSanitized</p>
  <p style="color:#EBEDF1;
			      font-family: Helvetica, Arial, sans-serif;
            font-style: normal;
            font-size: 16px;
            font-size: 16px;
            line-height: 150%;">$messageSanitized</p>
  <br />
  <br />
  $buttonSectionHtml
</div>
      ''';
  }

  return '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width"/>
    <title>Email Title</title>
    <style type="text/css">
        body {
            font-size: 16px;
            font-family: Helvetica, Arial, sans-serif;
        }
        td {
            padding: 6px;
        }
        .email-body {
            max-width: 640px;
        }
        .title {
            color: #3d4868;
            font-size: 24px;
            text-align: center;
            margin: 20px;
        }
        .title-community-image {
            vertical-align: -16px;
            margin-right: 8px;
            height: 48px;
            width: 48px;
            display: inline-block;
            border-radius: 8px;
            overflow: hidden;
        }
        .title-community-name {
            font-weight: bold;
        }
        .title-separator {
            margin-left: 4px;
            margin-right: 4px;
            color: #9efac3;
            font-weight: bolder;
            font-size: 32px;
            vertical-align: -3px;
        }
        .title-label {
            display: inline-block;
        }
        .subtitle {
            font-size: 16px;
            text-align: center;
            margin-top: 24px;
            margin-bottom: 12px;
            font-weight: bold;
            color: #3d4868;
        }
        .header {
            margin-top: 24px;
            margin-bottom: 24px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            color: #3d4868;
        }
        .section {
            padding-bottom: 20px;
            max-width: 520px;
            margin-left: auto;
            margin-right: auto;
        }
        .center {
            text-align: center;
            margin: 5px;
        }
        .event-box {
            background: #f2f2f2;
            padding: 4px;
            margin: 8px 4px;
        }
        .event-info-cell {
            width: 100%;
        }
        .event-info {

        }
        .event-name {
            font-size: 16px;
            font-weight: bold;
        }
        .event-date {
            font-size: 14px;
        }
        .event-more {
        }
        .more-button {
            display: block;
            background: #3d4868;
            padding: 8px;
            border-radius: 8px;
            width: 96px;
            height: 20px;
            line-height: 20px;
            text-align: center;
            text-decoration: none;
        }
        .supplement-text {
            padding: 25px;
            font-weight: lighter;
        }
        .text-button {
            color: black;
            font-weight: bold;
            text-decoration: underline;
        }
        .footer {
            padding: 8px;
            background: #3d4868;
            text-align: center;
        }
        .footer-copyright {
            font-size: 14px;
            color: #ffffff;

        }
        .footer-copyright a:link{
            color:#a1abcf;
        }
    </style>
</head>
<body>
    <div class="email-body">
        <div class="title">
            $imageHtml
            <span class="title-community-name">$communityNameSanitized</span>
            <span class="title-separator">//</span>
            <span class="title-label">$actionTitleSanitized</span>
        </div>
        <hr/>
        <div class="header">$header</div>
        $preEventSurveyCardHtml
        <br/>
        <div class="section">
            <div class="event-box">
                <table>
                    <tr>
                        <td><img src="$eventImageSanitized" width="52"/></td>
                        <td class="event-info-cell">
                            <div class="event-info">
                                <div class="event-name">$eventTitleSanitized</div>
                                <div class="event-date">$eventDateDisplay</div>
                            </div>
                        </td>
                        <td>
                            <div class="event-more">
                                <a style="color: #9efac3; font-size: 14px;" href="$detailsUrl" class="more-button">
                                    Go To Event
                                </a>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        $supplement
        <div class="footer">
            <div class="footer-copyright">$legalStatement</div><br/>
            <div style="color:#ffffff; font-size: 12px;">$mailingAddress</div>
            <a style="color:#a1abcf; font-size: 12px;" href="$settingsUrl">Notification Settings</a><br/>
            <a style="color:#a1abcf; font-size: 12px;" href="$privacyPolicyUrl">Privacy Statement</a><br/><br/>
            <div style="color:#ffffff; font-size: 10px;">$copyrightStatement</div>
        </div>
    </div>
</body>
</html>
  ''';
}

String makeNewAnnouncementBody({
  required Community community,
  required String unsubscribeUrl,
  Announcement? announcement,
}) {
  const htmlEscape = HtmlEscape();
  final communityName = htmlEscape.convert(community.name ?? community.id);
  final title = htmlEscape.convert(announcement?.title ?? '');
  final message = htmlEscape.convert(announcement?.message ?? '');
  final creatorDisplayName =
      htmlEscape.convert(announcement?.creatorDisplayName ?? 'Admin');
  final announcementUrl = '$linkPrefix/space/${community.id}';
  final settingsUrl =
      '$linkPrefix/settings?initialSection=notifications&communityId=${community.id}';
  final imageHtml = isNullOrEmpty(community.profileImageUrl)
      ? ''
      : '''
        <span class="title-community-image">
          <img width="48" src="${htmlEscape.convert(community.profileImageUrl ?? '')}"/>
        </span>
      ''';
  return '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width"/>
    <title>Email Title</title>
    <style type="text/css">
        body {
            font-size: 16px;
            font-family: Helvetica, Arial, sans-serif;
        }
        td {
            padding: 6px;
        }
        .email-body {
            max-width: 640px;
        }
        .title {
            color: #3d4868;
            font-size: 24px;
            text-align: center;
            margin: 20px;
        }
        .title-community-image {
            vertical-align: -16px;
            margin-right: 8px;
            height: 48px;
            width: 48px;
            display: inline-block;
            border-radius: 8px;
            overflow: hidden;
        }
        .title-community-name {
            font-weight: bold;
        }
        .title-separator {
            margin-left: 4px;
            margin-right: 4px;
            color: #9efac3;
            font-weight: bolder;
            font-size: 32px;
            vertical-align: -3px;
        }
        .title-label {
            display: inline-block;
        }
        .subtitle {
            font-size: 16px;
            text-align: center;
            margin-top: 24px;
            margin-bottom: 12px;
            font-weight: bold;
            color: #3d4868;
        }
        .header {
            margin-top: 24px;
            margin-bottom: 24px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            color: #3d4868;
        }
        .section {
            padding-bottom: 20px;
            max-width: 520px;
            margin-left: auto;
            margin-right: auto;
        }
        .announce-box {
            background: #f2f2f2;
            padding: 10px;
            margin: 8px 4px;
        }
        .announce-title {
            font-weight: bold;
            text-align: center;
            margin: 10px;
        }
        .announce-message {
            text-align: center;
            margin: 10px;
        }
        .view-button {
            display: block;
            background: #3d4868;
            padding: 8px;
            border-radius: 8px;
            width: 156px;
            height: 30px;
            line-height: 30px;
            text-align: center;
            text-decoration: none;
            margin-left: auto;
            margin-right: auto;
        }
        .footer {
            padding: 8px;
            background: #3d4868;
            text-align: center;
        }
        .footer-copyright {
            font-size: 14px;
            color: #ffffff;
        }
        .footer-copyright a:link{
            color:#a1abcf;
        }
    </style>
</head>
<body>
    <div class="email-body">
        <div class="title">
            $imageHtml
            <span class="title-community-name">$communityName</span>
            <span class="title-separator">//</span>
            <span class="title-label">Announcement</span>
        </div>
        <hr/>
        <div class="header">$creatorDisplayName posted a new announcement:</div>
        <div class="section">
            <div class="announce-box">
                <div class="announce-title">
                    $title
                </div>
                <div class="announce-message">
                    $message
                </div>
            </div>
        </div>
        <div class="section">
            <a style="color: #9efac3; font-size: 14px; margin-bottom: 14px;" href="$announcementUrl" class="view-button">
                View Announcement
            </a>
        </div>
        <div class="footer">
            <div class="footer-copyright">$legalStatement</div><br/>
            <div style="color:#ffffff; font-size: 12px;">$mailingAddress</div>
            <a style="color:#a1abcf; font-size: 12px;" href="$settingsUrl">Notification Settings</a><br/>
            <a style="color:#a1abcf; font-size: 12px;" href="$privacyPolicyUrl">Privacy Statement</a><br/><br/>
            <div style="color:#ffffff; font-size: 10px;">$copyrightStatement</div>
        </div>
    </div>
</body>
</html>
  ''';
}

String makeNewEventMessageBody({
  required Community community,
  required Template template,
  required Event event,
  required EventMessage eventMessage,
  required String unsubscribeUrl,
}) {
  final calendarGoogleLink = calendarLinkUtil.getGoogleLink(
    community: community,
    template: template,
    event: event,
  );
  final calendarOffice365Link = calendarLinkUtil.getOffice365Link(
    community: community,
    template: template,
    event: event,
  );
  final calendarOutlookLink = calendarLinkUtil.getOutlookLink(
    community: community,
    template: template,
    event: event,
  );
  final url =
      '$linkPrefix/space/${community.id}/discuss/${event.templateId}/${event.id}';
  final cancelUrl = '$url?cancel=true';
  final settingsUrl =
      '$linkPrefix/settings?initialSection=notifications&communityId=${community.id}';

  String makeEventHtml(Template template, Event event) {
    const htmlEscape = HtmlEscape();
    final image = htmlEscape.convert(event.image ?? template.image ?? '');
    final title = htmlEscape.convert(event.title ?? template.title ?? '');

    final scheduledTimeUtc = event.scheduledTime?.toUtc();
    tz.Location scheduledLocation;
    try {
      scheduledLocation =
          timezoneUtils.getLocation(event.scheduledTimeZone ?? '');
    } catch (e) {
      print('Error getting scheduled location: $e. Using America/Los_Angeles');
      scheduledLocation = timezoneUtils.getLocation('America/Los_Angeles');
    }
    final timeZoneAbbreviation = scheduledLocation.currentTimeZone.abbr;
    final tz.TZDateTime scheduledTimeLocal =
        tz.TZDateTime.from(scheduledTimeUtc!, scheduledLocation);

    final weekday = DateFormat('EEEE').format(scheduledTimeLocal);
    final date = DateFormat('MMM dd, yyyy').format(scheduledTimeLocal);
    final time = DateFormat('h:mm aa').format(scheduledTimeLocal);

    return '''
      <div class="event-box">
          <table>
              <tr>
                  <td><img src="$image" width="52"/></td>
                  <td class="event-info-cell">
                      <div class="event-info">
                          <div class="event-name">$title</div>
                          <div class="event-date">$weekday, $date, at $time $timeZoneAbbreviation</div>
                      </div>
                  </td>
                  <td>
                      <div class="event-more">
                          <a href="$url" class="more-button view-button">Go to event</a>
                      </div>
                  </td>
              </tr>
          </table>
      </div>
    ''';
  }

  final communityName = htmlEscape.convert(community.name ?? '');
  final imageHtml = isNullOrEmpty(community.profileImageUrl)
      ? ''
      : '''
        <span class="title-community-image">
          <img width="48" src="${htmlEscape.convert(community.profileImageUrl ?? '')}"/>
        </span>
      ''';

  final templateEventHtml = makeEventHtml(template, event);

  return '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width"/>
    <title>Email Title</title>
    <style type="text/css">
        body {
            font-size: 16px;
            font-family: Helvetica, Arial, sans-serif;
        }
        td {
            padding: 6px;
        }
        .email-body {
            max-width: 640px;
        }
        .title {
            color: #3d4868;
            font-size: 24px;
            text-align: center;
            margin: 20px;
        }
        .title-community-image {
            vertical-align: -16px;
            margin-right: 8px;
            height: 48px;
            width: 48px;
            display: inline-block;
            border-radius: 8px;
            overflow: hidden;
        }
        .title-community-name {
            font-weight: bold;
        }
        .title-separator {
            margin-left: 4px;
            margin-right: 4px;
            color: #9efac3;
            font-weight: bolder;
            font-size: 32px;
            vertical-align: -3px;
        }
        .title-label {
            display: inline-block;
        }
        .template-event-info {
            padding-bottom: 20px;
            max-width: 520px;
            margin-left: auto;
            margin-right: auto;
        }
        .event-message-rect {
          padding-left: 25px;
          padding-top: 25px;
          padding-right: 25px;
          padding-bottom: 25px;
          max-width: 520px;
          margin-left: auto;
          margin-right: auto;     
          background: #F2F2F2;   
        }
        .event-message {
          font-style: normal;
          font-weight: normal;
          font-size: 16px;
          line-height: 24px;
          text-align: center;          
          color: #000000;
        }
        .event-box {
            background: #f2f2f2;
            padding: 4px;
            margin: 8px 4px;
        }
        .event-info-cell {
            width: 100%;
        }
        .event-name {
            font-size: 16px;
            font-weight: bold;
        }
        .event-date {
            font-size: 14px;
        }
        .more-button {
            color: #9efac3;
            font-size: 14px;
            display: block;
            background: #3d4868;
            padding: 8px;
            border-radius: 8px;
            width: 76px;
            text-align: center;
            text-decoration: none;
        }
        .new-announcement {
            font-size: 20px;
            line-height: 30px;
            text-align: center;
            margin-top: 24px;
            margin-bottom: 12px;
            font-weight: bold;
            color: #3d4868;        
        }
        .add-to-calendar {
            font-size: 14px;
            line-height: 21px;
            text-align: center;
            color: #000000;        
        } 
        .footer-disclaimer {
            margin-left: 35px;
            margin-right: 35px;
            max-width: 520px;        
            font-size: 12px;
            line-height: 18px;
            text-align: left;
            color: #000000;           
        }
        .footer {
            padding: 8px;
            background: #3d4868;
            text-align: center;
            max-width: 520px;
            margin-left: auto;
            margin-right: auto;   
        }
        .footer-copyright {
            font-size: 14px;
            line-height: 22px;
            color: #ffffff;
        }
        .footer-copyright a:link{
            color:#a1abcf;
        }   
        .notification-settings {
            font-size: 9px;
            line-height: 14px;
            color: #cccccc;
        }        
        .section {
            max-width: 520px;
            margin-left: auto;
            margin-right: auto;
        }
        .center {
            text-align: center;
            margin: 5px;
        }                   
    </style>
</head>
<body>
    <div class="email-body">
        <div class="title">
            $imageHtml
            <span class="title-community-name">$communityName</span>
            <span class="title-separator">//</span>
            <span class="title-label">Event Update</span>
        </div>
        <hr/>
        <div class="new-announcement">New Announcement for your Upcoming Event</div>
        <div class="template-event-info">$templateEventHtml</div>
        <div class="event-message-rect">
          <div class="event-message">“${eventMessage.message}”</div>
        </div>
        <br/>
        <div class="section">
          <div class="center">Add to calendar:</div>
          <div class="center">
            <a href="$calendarGoogleLink" style="color:#303B5F;"><b>Google</b></a>
            ·
            <a href="$calendarOffice365Link" style="color:#303B5F;"><b>Office 365</b></a>
            ·
            <a href="$calendarOutlookLink" style="color:#303B5F;"><b>Outlook</b></a>
        </div>
      </div>
        <br/>
        <hr/>
        <br/>
        <div class="footer-disclaimer">
          No-shows ruin the fun for everyone. If you can no longer attend, <span style="color: #000000;"><strong><a style="color: #000000;" href="$cancelUrl">click here to cancel</a></strong></span> and let the other participants know.
        </div>
        <br/>
        <div class="footer">
            <div class="footer-copyright">$legalStatement</div><br/>
            <div style="color:#ffffff; font-size: 12px;">$mailingAddress</div>
            <a style="color:#a1abcf; font-size: 12px;" href="$settingsUrl">Notification Settings</a><br/>
            <a style="color:#a1abcf; font-size: 12px;" href="$privacyPolicyUrl">Privacy Statement</a><br/><br/>
            <div style="color:#ffffff; font-size: 10px;">$copyrightStatement</div>
        </div>
    </div>
</body>
</html>
  ''';
}

String makeJoinApprovedBody({required Community community}) {
  const htmlEscape = HtmlEscape();
  final communityName = htmlEscape.convert(community.name ?? community.id);
  final imageSrc = htmlEscape.convert(community.profileImageUrl ?? '');
  final communityUrl = '$linkPrefix/space/${community.id}';
  final settingsUrl = '$linkPrefix/settings?notifications=${community.id}';

  return '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width"/>
    <title>Email Title</title>
    <style type="text/css"> /*////// RESET STYLES //////*/
    body, #bodyTable, #bodyCell {
        height: 100% !important;
        margin: 0;
        padding: 0;
        width: 100% !important;
    }

    table {
        border-collapse: collapse;
    }

    img, a img {
        border: 0;
        outline: none;
        text-decoration: none;
    }

    h1, h2, h3, h4, h5, h6 {
        margin: 0;
        padding: 0;
    }

    p {
        margin: 1em 0;
    }

    /*////// CLIENT-SPECIFIC STYLES //////*/
    .ReadMsgBody {
        width: 100%;
    }

    .ExternalClass {
        width: 100%;
    }

    /* Force Hotmail/Outlook.com to display emails at full width. */
    .ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div {
        line-height: 100%;
    }

    /* Force Hotmail/Outlook.com to display line heights normally. */
    table, td {
        mso-table-lspace: 0pt;
        mso-table-rspace: 0pt;
    }

    /* Remove spacing between tables in Outlook 2007 and up. */
    #outlook a {
        padding: 0;
    }

    /* Force Outlook 2007 and up to provide a "view in browser" message. */
    img {
        -ms-interpolation-mode: bicubic;
    }

    /* Force IE to smoothly render resized images. */
    body, table, td, p, a, li, blockquote {
        -ms-text-size-adjust: 100%;
        -webkit-text-size-adjust: 100%;
    }

    /* Prevent Windows- and Webkit-based mobile platforms from changing declared text sizes. */ /*////// FRAMEWORK STYLES //////*/
    .flexibleContainerCell {
        padding-top: 20px;
        padding-Right: 20px;
        padding-Left: 20px;
    }

    .flexibleImage {
        height: auto;
    }

    .bottomShim {
        padding-bottom: 20px;
    }

    .imageContent, .imageContentLast {
        padding-bottom: 20px;
    }

    .nestedContainerCell {
        padding-top: 20px;
        padding-Right: 20px;
        padding-Left: 20px;
    }

    /*////// GENERAL STYLES //////*/
    body, #bodyTable {
        background-color: #F5F5F5;
    }

    #bodyCell {
        padding-top: 40px;
        padding-bottom: 40px;
    }

    #emailBody {
        background-color: #FFFFFF;
        border: 1px solid #DDDDDD;
        border-collapse: separate;
        border-radius: 4px;
    }

    h1, h2, h3, h4, h5, h6 {
        color: #202020;
        font-family: Helvetica;
        font-size: 20px;
        line-height: 125%;
        text-align: Left;
    }

    .textContent, .textContentLast {
        color: #404040;
        font-family: Helvetica;
        font-size: 16px;
        line-height: 125%;
        text-align: Left;
        padding-bottom: 20px;
    }

    .textContent a, .textContentLast a {
        color: #303B5F;
        text-decoration: underline;
        font-weight: bold;
    }

    .nestedContainer {
        background-color: #E5E5E5;
        border: 1px solid #CCCCCC;
    }

    .emailButton {
        background-color: #303B5F;
        border-collapse: separate;
        border-radius: 10px;
    }

    .buttonContent {
        color: #9BFBC2;
        font-family: Helvetica;
        font-size: 16px;
        font-weight: bold;
        line-height: 100%;
        padding: 12px;
        text-align: center;
    }

    .buttonContent a {
        color: #9BFBC2;
        display: block;
        text-decoration: none;
    }

    .emailCalendar {
        background-color: #FFFFFF;
        border: 1px solid #CCCCCC;
    }

    .emailCalendarMonth {
        background-color: #2C9AB7;
        color: #FFFFFF;
        font-family: Helvetica, Arial, sans-serif;
        font-size: 16px;
        font-weight: bold;
        padding-top: 10px;
        padding-bottom: 10px;
        text-align: center;
    }

    .emailCalendarDay {
        color: #2C9AB7;
        font-family: Helvetica, Arial, sans-serif;
        font-size: 60px;
        font-weight: bold;
        line-height: 100%;
        padding-top: 20px;
        padding-bottom: 20px;
        text-align: center;
    }

    .footer {
            padding: 8px;
            background: #3d4868;
            text-align: center;
            max-width: 520px;
            margin-left: auto;
            margin-right: auto;   
    }
    .footer-copyright {
            font-size: 14px;
            line-height: 22px;
            color: #ffffff;
        }
    .footer-copyright a:link{
            color:#a1abcf;
    }   

    /*////// MOBILE STYLES //////*/
    @media only screen and (max-width: 480px) {
        /*////// CLIENT-SPECIFIC STYLES //////*/
        body {
            width: 100% !important;
            min-width: 100% !important;
        }

        /* Force iOS Mail to render the email at full width. */
        /*////// FRAMEWORK STYLES //////*/
        /* CSS selectors are written in attribute selector format to prevent Yahoo Mail from rendering media query styles on desktop. */
        table[id="emailBody"], table[class="flexibleContainer"] {
            width: 100% !important;
        }

        /* The following style rule makes any image classed with 'flexibleImage' fluid when the query activates. Make sure you add an inline max-width to those images to prevent them from blowing out. */
        img[class="flexibleImage"] {
            height: auto !important;
            width: 100% !important;
        }

        /* Make buttons in the email span the full width of their container, allowing for left- or right-handed ease of use. */
        td[class="buttonContent"] {
            padding: 0 !important;
        }

        td[class="buttonContent"] a {
            padding: 15px !important;
        }

        td[class="textContentLast"], td[class="imageContentLast"] {
            padding-top: 20px !important;
        }

        /*////// GENERAL STYLES //////*/
        td[id="bodyCell"] {
            padding-top: 10px !important;
            padding-Right: 10px !important;
            padding-Left: 10px !important;
        }
    } </style>
</head>
<body>
<center>
    <table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="bodyTable">
        <tr>
            <td align="center" valign="top" id="bodyCell">
                <table border="0" cellpadding="0" cellspacing="0" width="600" id="emailBody">
                    <tr>
                        <td align="center" valign="top">
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td align="center" valign="top">
                                        <table border="0" cellpadding="0" cellspacing="0" width="600"
                                               class="flexibleContainer">
                                            <tr>
                                                <td align="center" valign="top" width="600"
                                                    class="flexibleContainerCell" style="padding-bottom:20px;">
                                                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                        <tr>
                                                            <td valign="top" class="textContent"
                                                                style="text-align:center;font-size:22px;font-weight:bold;padding:5px;color:#404040;">
                                                                You've been accepted into:
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" valign="top">
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td align="center" valign="top">
                                        <table border="0" cellpadding="0" cellspacing="0" width="500"
                                               class="flexibleContainer">
                                            <tr>
                                                <td align="center" valign="top" width="500"
                                                    class="flexibleContainerCell"
                                                    style="background-color:#F5F5F5;padding:15px;border:2px solid #303B5F;">
                                                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                        <tr>
                                                            <td valign="top" class="textContent"
                                                                style="text-align:center;font-size:18px;font-weight:bold;padding-bottom:10px;">
                                                                $communityName
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top" class="textContent"
                                                                style="text-align:center;font-size:18px;font-weight:bold;padding-bottom:10px;">
                                                                <img src="$imageSrc" width="150"
                                                                     alt=""/></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" valign="top">
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td align="center" valign="top">
                                        <table border="0" cellpadding="0" cellspacing="0" width="600"
                                               class="flexibleContainer">
                                            <tr>
                                                <td align="center" valign="top" width="600"
                                                    class="flexibleContainerCell bottomShim"
                                                    style="padding-top:40px;padding-bottom:40px;">
                                                    <table border="0" cellpadding="0" cellspacing="0" width="220"
                                                           class="emailButton">
                                                        <tr>
                                                            <td align="center" valign="middle" class="buttonContent"><a
                                                                    href="$communityUrl"
                                                                    target="_blank">Open Now</a></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    
                </table> <!-- // EMAIL CONTAINER --> </td>
        </tr>
    </table>
</center>
 <div class="footer">
            <div class="footer-copyright">$legalStatement</div><br/>
            <div style="color:#ffffff; font-size: 12px;">$mailingAddress</div>
            <a style="color:#a1abcf; font-size: 12px;" href="$settingsUrl">Notification Settings</a><br/>
            <a style="color:#a1abcf; font-size: 12px;" href="$privacyPolicyUrl">Privacy Statement</a><br/><br/>
            <div style="color:#ffffff; font-size: 10px;">$copyrightStatement</div>
        </div>
</body>
</html>
  ''';
}

String makeEventDigestBody({
  required Community community,
  required List<EventWithTemplate> events,
  required String unsubscribeUrl,
}) {
  final settingsUrl =
      '$linkPrefix/settings?initialSection=notifications&communityId=${community.id}';

  String makeEventHtml(EventWithTemplate info) {
    const htmlEscape = HtmlEscape();
    final image =
        htmlEscape.convert(info.event.image ?? info.template.image ?? '');
    final title =
        htmlEscape.convert(info.event.title ?? info.template.title ?? '');
    final url =
        '$linkPrefix/space/${community.id}/discuss/${info.event.templateId}/${info.event.id}';

    final scheduledTimeUtc = info.event.scheduledTime?.toUtc();
    tz.Location scheduledLocation;
    try {
      scheduledLocation =
          timezoneUtils.getLocation(info.event.scheduledTimeZone ?? '');
    } catch (e) {
      print('Error getting scheduled location: $e. Using America/Los_Angeles');
      scheduledLocation = timezoneUtils.getLocation('America/Los_Angeles');
    }
    final timeZoneAbbreviation = scheduledLocation.currentTimeZone.abbr;
    final tz.TZDateTime scheduledTimeLocal =
        tz.TZDateTime.from(scheduledTimeUtc!, scheduledLocation);

    final weekday = DateFormat('EEEE').format(scheduledTimeLocal);
    final date = DateFormat('MMM dd, yyyy').format(scheduledTimeLocal);
    final time = DateFormat('h:mm aa').format(scheduledTimeLocal);

    return '''
      <div class="event-box">
          <table>
              <tr>
                  <td><img src="$image" width="52"/></td>
                  <td class="event-info-cell">
                      <div class="event-info">
                          <div class="event-name">$title</div>
                          <div class="event-date">$weekday, $date, at $time $timeZoneAbbreviation</div>
                      </div>
                  </td>
                  <td>
                      <div class="event-more">
                          <a style="color: #9efac3; font-size: 14px;" href="$url" class="more-button">See More</a>
                      </div>
                  </td>
              </tr>
          </table>
      </div>
    ''';
  }

  final communityName = htmlEscape.convert(community.name ?? '');
  final imageHtml = isNullOrEmpty(community.profileImageUrl)
      ? ''
      : '''
        <span class="title-community-image">
          <img width="48" src="${htmlEscape.convert(community.profileImageUrl ?? '')}"/>
        </span>
      ''';
  final eventsHtml = events.map((e) => makeEventHtml(e)).join('\n');

  return '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width"/>
    <title>Email Title</title>
    <style type="text/css">
        body {
            font-size: 16px;
            font-family: Helvetica, Arial, sans-serif;
        }
        td {
            padding: 6px;
        }
        .email-body {
            max-width: 640px;
        }
        .title {
            color: #3d4868;
            font-size: 24px;
            text-align: center;
            margin: 20px;
        }
        .title-community-image {
            vertical-align: -16px;
            margin-right: 8px;
            height: 48px;
            width: 48px;
            display: inline-block;
            border-radius: 8px;
            overflow: hidden;
        }
        .title-community-name {
            font-weight: bold;
        }
        .title-separator {
            margin-left: 4px;
            margin-right: 4px;
            color: #9efac3;
            font-weight: bolder;
            font-size: 32px;
            vertical-align: -3px;
        }
        .title-label {
            display: inline-block;
        }
        .subtitle {
            font-size: 16px;
            text-align: center;
            margin-top: 24px;
            margin-bottom: 12px;
            font-weight: bold;
            color: #3d4868;
        }
        .events {
            padding-bottom: 20px;
            max-width: 520px;
            margin-left: auto;
            margin-right: auto;
        }
        .event-box {
            background: #f2f2f2;
            padding: 4px;
            margin: 8px 4px;
        }
        .event-info-cell {
            width: 100%;
        }
        .event-info {

        }
        .event-name {
            font-size: 16px;
            font-weight: bold;
        }
        .event-date {
            font-size: 14px;
        }
        .event-more {
            color: #9efac3;
        }
        .more-button {
            display: block;
            background: #3d4868;
            padding: 8px;
            border-radius: 8px;
            width: 76px;
            text-align: center;
            text-decoration: none;
        }
        .footer {
            padding: 8px;
            background: #3d4868;
            text-align: center;
        }
        .footer-copyright {
            font-size: 14px;
            color: #ffffff;
        }
        .footer-copyright a:link{
            color:#a1abcf;
        }
    </style>
</head>
<body>
    <div class="email-body">
        <div class="title">
            $imageHtml
            <span class="title-community-name">$communityName</span>
            <span class="title-separator">//</span>
            <span class="title-label">Weekly Digest</span>
        </div>
        <hr/>
        <div class="subtitle">UPCOMING EVENTS</div>
        <div class="events">
            $eventsHtml
        </div>
        <div class="footer">
            <div class="footer-copyright">$legalStatement</div><br/>
            <div style="color:#ffffff; font-size: 12px;">$mailingAddress</div>
            <a style="color:#a1abcf; font-size: 12px;" href="$settingsUrl">Notification Settings</a><br/>
            <a style="color:#a1abcf; font-size: 12px;" href="$privacyPolicyUrl">Privacy Statement</a><br/><br/>
            <div style="color:#ffffff; font-size: 10px;">$copyrightStatement</div>
        </div>
    </div>
</body>
</html>
  ''';
}

String generateEventEndedContent({
  required Community community,
  required String header,
  required Event event,
  required admin_interop.UserRecord userRecord,
  required bool allowPrePost,
}) {
  final communityNameSanitized = htmlEscape.convert(community.name ?? '');
  final settingsUrl =
      '$linkPrefix/settings?initialSection=notifications&communityId=${community.id}';
  final communityUrl = '$linkPrefix/space/${event.communityId}';
  var bannerImgUrl = community.profileImageUrl ?? '';
  if (bannerImgUrl.contains('picsum')) {
    bannerImgUrl = bannerImgUrl.replaceAll('.webp', '.jpg');
  }

  final imageHtml = isNullOrEmpty(bannerImgUrl)
      ? ''
      : '''
        <span class="title-community-image">
          <img width="48" src="${htmlEscape.convert(bannerImgUrl)}"/>
        </span>
      ''';

  final moreEvents = '''
        <div class="rounded-card">
            <img style="display: inline-block; vertical-align: middle; padding: 10px 20px;" 
                  src="${htmlEscape.convert(community.profileImageUrl ?? '')}" width="100"
            /> 
            <div style="display: inline-block; vertical-align: middle; text-align: left;">
                <div style="color:#303B5F; font-weight: 900; font-size: 20px; padding-bottom: 6px; max-width: 280px;">
                    Check out more events from $communityNameSanitized
                </div> 
                <a class="button-community-inverse" href="$communityUrl">See upcoming events</a>
            </div>
        </div>
      ''';

  String postEventSurveyCardHtml = '';
  final postEventCard = event.postEventCardData;

  if (allowPrePost && postEventCard != null && postEventCard.hasData) {
    const htmlEscape = HtmlEscape();
    final headlineSanitized = htmlEscape.convert(postEventCard.headline);
    final messageSanitized = htmlEscape.convert(postEventCard.message);
    final List<String> buttonSectionHtmlList = [];

    for (var urlInfo in postEventCard.prePostUrls) {
      final bool isButtonSectionShown = !isNullOrEmpty(urlInfo.surveyUrl);
      final buttonText = urlInfo.buttonText;
      final buttonTextSanitized = htmlEscape.convert(
        buttonText == null || buttonText.isEmpty ? 'Visit Link' : buttonText,
      );
      final surveyUri = postEventCard.getFinalisedUrl(
        userId: userRecord.uid,
        event: event,
        email: userRecord.email,
        urlInfo: urlInfo,
      );
      final buttonHtml = !isButtonSectionShown
          ? ''
          : '''
        <a class="button-community" href="$surveyUri">
               $buttonTextSanitized
        </a>''';

      buttonSectionHtmlList.add(buttonHtml);
    }

    final buttonSectionHtml = buttonSectionHtmlList.join('<br />');
    postEventSurveyCardHtml = '''
     <div style="max-width: 520px;
                border-radius: 25px;
                margin: auto;
                background: #303B5F;
                padding: 40px;">
      <p style="color:#9BFBC2;
                font-family: Helvetica, Arial, sans-serif;
                font-size: 16px;
                font-weight: lighter;
                line-height: 24px;
                letter-spacing: 0.1em;
                text-transform: uppercase;">$appName</p>
      <p style="color:#FFFFFF;         
                font-family: Helvetica, Arial, sans-serif;
                font-size: 24px;
                font-weight: bold;
                font-size: 24px;
                line-height: 110%;">$headlineSanitized</p>
      <p style="color:#EBEDF1;
                font-family: Helvetica, Arial, sans-serif;
                font-style: normal;
                font-size: 16px;
                font-size: 16px;
                line-height: 150%;">$messageSanitized</p>
      <br />
      <br />
      $buttonSectionHtml
    </div>
      ''';
  }
  return '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width"/>
    <title>Email Title</title>
    <style type="text/css">
        body {
            font-size: 16px;
            font-family: Helvetica, Arial, sans-serif;
        }
        td {
            padding: 6px;
        }
        .email-body {
            max-width: 640px;
        }
        .title {
            color: #3d4868;
            font-size: 24px;
            text-align: center;
            margin: 20px;
        }
        .title-community-image {
            vertical-align: -16px;
            margin-right: 8px;
            height: 48px;
            width: 48px;
            display: inline-block;
            border-radius: 8px;
            overflow: hidden;
        }
        .title-community-name {
            font-weight: bold;
        }
        .title-separator {
            margin-left: 4px;
            margin-right: 4px;
            color: #9efac3;
            font-weight: bolder;
            font-size: 32px;
            vertical-align: -3px;
        }
        .title-label {
            display: inline-block;
        }
        .subtitle {
            font-size: 16px;
            text-align: center;
            margin-top: 24px;
            margin-bottom: 12px;
            font-weight: bold;
            color: #3d4868;
        }
        .header {
            margin-top: 24px;
            margin-bottom: 24px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            color: #3d4868;
        }
        .section {
            padding-bottom: 20px;
            max-width: 520px;
            margin-left: auto;
            margin-right: auto;
        }
        .center {
            text-align: center;
            margin: 5px;
        }
        .event-box {
            background: #f2f2f2;
            padding: 4px;
            margin: 8px 4px;
        }
        .event-info-cell {
            width: 100%;
        }
        .event-info {

        }
        .event-name {
            font-size: 16px;
            font-weight: bold;
        }
        .event-date {
            font-size: 14px;
        }
        .event-more {
        }
        .rounded-card {
            color: #ffffff;
            border-radius: 25px;
            background: #EBEDF1;
            max-width: 520px;
            padding: 40px;
            margin: auto;
            text-align: center;
        }
        .button-community {
            background-color: #9BFBC2;
            border: none;
            color: #303B5F;
            cursor: pointer;
            padding: 12px 18px;
            text-align: center;
            border-radius: 10px;
            text-decoration: none;
            font-size: 16px;
            margin: 4px 2px;
            display: inline-block;
        }
        .button-community-inverse {
            background-color: #303B5F;
            border: none;
            color: #9BFBC2;
            cursor: pointer;
            padding: 12px 18px;
            text-align: center;
            border-radius: 10px;
            text-decoration: none;
            font-size: 16px;
            margin: 4px 2px;
            display: inline-block;
        }
        .more-button {
            display: block;
            background: #3d4868;
            padding: 8px;
            border-radius: 8px;
            width: 96px;
            height: 20px;
            line-height: 20px;
            text-align: center;
            text-decoration: none;
        }
        .supplement-text {
            padding: 25px;
            font-weight: lighter;
        }
        .text-button {
            color: black;
            font-weight: bold;
            text-decoration: underline;
        }
        .footer {
            padding: 8px;
            background: #3d4868;
            text-align: center;
        }
        .footer-copyright {
            font-size: 14px;
            color: #ffffff;
        }
        .footer-copyright a:link{
            color:#a1abcf;
        }
    </style>
</head>
<body>
    <div class="email-body">
        <div class="title">
            $imageHtml
            <span class="title-community-name">$communityNameSanitized</span>
            <span class="title-separator">//</span>
            <span class="title-label">$appName</span>
        </div>
        <hr/>
        <div class="header">$header</div>
        $postEventSurveyCardHtml
        <br/>
          $moreEvents
        <br/>
       
        <div class="footer">
            <div class="footer-copyright">$legalStatement</div><br/>
            <div style="color:#ffffff; font-size: 12px;">$mailingAddress</div>
            <a style="color:#a1abcf; font-size: 12px;" href="$settingsUrl">Notification Settings</a><br/>
            <a style="color:#a1abcf; font-size: 12px;" href="$privacyPolicyUrl">Privacy Statement</a><br/><br/>
            <div style="color:#ffffff; font-size: 10px;">$copyrightStatement</div>
        </div>
    </div>
</body>
</html>
  ''';
}
