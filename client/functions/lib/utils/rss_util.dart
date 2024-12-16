import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:intl/intl.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/timezone_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:xml/xml.dart';

final rssUtil = RssUtil();

class RssUtil {
  /// Return an RSS string containing future events for a given community
  Future<String> getRssForUpcomingEvents({required Junto junto}) async {
    List<Discussion> discussions = (await firestore
            .collectionGroup('discussions')
            .where(Discussion.kFieldJuntoId, isEqualTo: junto.id)
            .where(Discussion.kFieldIsPublic, isEqualTo: true)
            .where(Discussion.kFieldStatus,
                isEqualTo:
                    EnumToString.convertToString(DiscussionStatus.active))
            .where(Discussion.kFieldScheduledTime,
                isGreaterThanOrEqualTo: DateTime.now())
            .orderBy(Discussion.kFieldScheduledTime)
            .get())
        .documents
        .map((doc) => Discussion.fromJson(
            firestoreUtils.fromFirestoreJson(doc.data.toMap())))
        .toList();

    final participantCountEntries =
        await Future.wait(discussions.map((event) async {
      final count = event.useParticipantCountEstimate
          ? max(event.participantCountEstimate ?? 1, 1)
          : await _getFullParticipantCount(event);
      return MapEntry(event.id, count);
    }));
    final participantCounts = Map.fromEntries(participantCountEntries);

    final prodDomain = functions.config.get('app.prod_domain') as String;
    final devDomain = functions.config.get('app.dev_domain') as String;
    final domain = isDev ? devDomain : prodDomain;
    final link = 'https://$domain/space/${junto.displayId}';
    final xmlnsUrl = functions.config.get('xmlns.url') as String;
    final xmlnsMediaUrl = functions.config.get('xmlns.media_url') as String;

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('rss', attributes: {
      'version': '2.0',
      'xmlns:frankly': xmlnsUrl,
      'xmlns:media': xmlnsMediaUrl,
      'xmlns:atom': "http://www.w3.org/2005/Atom",
    }, nest: () {
      builder.element('channel', nest: () {
        builder.element('title', nest: () {
          builder.text(junto.name ?? '');
        });
        builder.element('description', nest: () {
          builder.text(junto.description ?? '');
        });
        builder.element('link', nest: () {
          builder.text(link);
        });
        builder.element('atom:link', nest: () {
          builder.attribute('href', '$link/rss');
          builder.attribute('rel', 'self');
          builder.attribute('type', "application/rss+xml");
        });
        final image = junto.profileImageUrl;
        if (image != null) {
          builder.element('image', nest: () {
            builder.element('url', nest: () {
              builder.text(image);
            });
            builder.element('title', nest: () {
              builder.text(junto.name ?? '');
            });
            builder.element('link', nest: () {
              builder.text(link);
            });
          });
        }
        _rssForDiscussions(
          builder: builder,
          junto: junto,
          discussions: discussions,
          domain: domain,
          participantCounts: participantCounts,
        );
      });
    });

    return builder.buildDocument().toXmlString();
  }

  /// Generate RSS for a list of discussion objects
  Future<void> _rssForDiscussions({
    required XmlBuilder builder,
    required Junto junto,
    required List<Discussion> discussions,
    required String domain,
    required Map<String, int> participantCounts,
  }) async {
    for (var event in discussions) {
      final participantCount = participantCounts[event.id] ?? 0;

      final scheduledTimeUtc = event.scheduledTime?.toUtc();
      tz.Location scheduledLocation;
      try {
        scheduledLocation =
            timezoneUtils.getLocation(event.scheduledTimeZone ?? '');
      } catch (e) {
        print(
            'Error getting scheduled location: $e. Using America/Los_Angeles');
        scheduledLocation = timezoneUtils.getLocation('America/Los_Angeles');
      }
      final timeZoneAbbreviation = scheduledLocation.currentTimeZone.abbr;
      final tz.TZDateTime scheduledTimeLocal =
          tz.TZDateTime.from(scheduledTimeUtc!, scheduledLocation);

      final weekday = DateFormat('EEEE').format(scheduledTimeLocal);
      final date = DateFormat('MMM dd, yyyy').format(scheduledTimeLocal);
      final time = DateFormat('h:mm aa').format(scheduledTimeLocal);

      final timeText = '$weekday, $date, at $time $timeZoneAbbreviation';
      final description = event.description ?? '';
      final image = event.image;
      final durationText = '${event.durationInMinutes} minutes';
      final link =
          'https://$domain/space/${junto.displayId}/discuss/${event.topicId}/${event.id}';

      var participantCountText = '';
      if (participantCount == 1) {
        participantCountText = '1 participant';
      } else {
        participantCountText = '$participantCount participants';
      }

      final descriptionParticipantText =
          (participantCount > 0) ? ' ($participantCountText)' : '';

      builder.element('item', nest: () {
        builder.element('title', nest: () {
          builder.text(event.title ?? 'Discussion');
        });
        builder.element('link', nest: () {
          builder.text(link);
        });
        builder.element('description', nest: () {
          builder.text(
              '$timeText ($durationText): $description$descriptionParticipantText');
        });
        builder.element('guid', nest: () {
          builder.attribute('isPermaLink', 'false');
          builder.text(event.id);
        });
        if (image != null) {
          builder.element('media:thumbnail', nest: () {
            builder.attribute('url', image);
          });
        }
        builder.element('frankly:time', nest: () {
          builder.text(timeText);
        });
        builder.element('frankly:duration', nest: () {
          builder.text(durationText);
        });
        builder.element('frankly:description', nest: () {
          builder.text(description);
        });
        builder.element('frankly:attendance', nest: () {
          builder.text(participantCountText);
        });
      });
    }
  }

  Future<int> _getFullParticipantCount(Discussion discussion) async {
    final participants = await firestore
        .collection(
            '${discussion.collectionPath}/${discussion.id}/discussion-participants')
        .get();
    return participants.documents
        .map((e) => Participant.fromJson(
            firestoreUtils.fromFirestoreJson(e.data.toMap())))
        .where((participant) => participant.status == ParticipantStatus.active)
        .length;
  }
}
