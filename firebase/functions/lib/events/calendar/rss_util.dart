import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:intl/intl.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/timezone_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:xml/xml.dart';

final rssUtil = RssUtil();

class RssUtil {
  /// Return an RSS string containing future events for a given community
  Future<String> getRssForUpcomingEvents({required Community community}) async {
    List<Event> events = (await firestore
            .collectionGroup('events')
            .where(Event.kFieldCommunityId, isEqualTo: community.id)
            .where(Event.kFieldIsPublic, isEqualTo: true)
            .where(
              Event.kFieldStatus,
              isEqualTo: EnumToString.convertToString(EventStatus.active),
            )
            .where(
              Event.kFieldScheduledTime,
              isGreaterThanOrEqualTo: DateTime.now(),
            )
            .orderBy(Event.kFieldScheduledTime)
            .get())
        .documents
        .map(
          (doc) => Event.fromJson(
            firestoreUtils.fromFirestoreJson(doc.data.toMap()),
          ),
        )
        .toList();

    final participantCountEntries = await Future.wait(
      events.map((event) async {
        final count = event.useParticipantCountEstimate
            ? max(event.participantCountEstimate ?? 1, 1)
            : await _getFullParticipantCount(event);
        return MapEntry(event.id, count);
      }),
    );
    final participantCounts = Map.fromEntries(participantCountEntries);

    final domain = functions.config.get('app.domain') as String;
    final appName = functions.config.get('app.name') as String;
    final link = 'https://$domain/space/${community.displayId}';
    final xmlnsUrl = functions.config.get('xmlns.url') as String;
    final xmlnsMediaUrl = functions.config.get('xmlns.media_url') as String;

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element(
      'rss',
      attributes: {
        'version': '2.0',
        'xmlns:$appName': xmlnsUrl,
        'xmlns:media': xmlnsMediaUrl,
        'xmlns:atom': "http://www.w3.org/2005/Atom",
      },
      nest: () {
        builder.element(
          'channel',
          nest: () {
            builder.element(
              'title',
              nest: () {
                builder.text(community.name ?? '');
              },
            );
            builder.element(
              'description',
              nest: () {
                builder.text(community.description ?? '');
              },
            );
            builder.element(
              'link',
              nest: () {
                builder.text(link);
              },
            );
            builder.element(
              'atom:link',
              nest: () {
                builder.attribute('href', '$link/rss');
                builder.attribute('rel', 'self');
                builder.attribute('type', "application/rss+xml");
              },
            );
            final image = community.profileImageUrl;
            if (image != null) {
              builder.element(
                'image',
                nest: () {
                  builder.element(
                    'url',
                    nest: () {
                      builder.text(image);
                    },
                  );
                  builder.element(
                    'title',
                    nest: () {
                      builder.text(community.name ?? '');
                    },
                  );
                  builder.element(
                    'link',
                    nest: () {
                      builder.text(link);
                    },
                  );
                },
              );
            }
            _rssForEvents(
              builder: builder,
              community: community,
              events: events,
              domain: domain,
              participantCounts: participantCounts,
            );
          },
        );
      },
    );

    return builder.buildDocument().toXmlString();
  }

  /// Generate RSS for a list of event objects
  Future<void> _rssForEvents({
    required XmlBuilder builder,
    required Community community,
    required List<Event> events,
    required String domain,
    required Map<String, int> participantCounts,
  }) async {
    for (var event in events) {
      final participantCount = participantCounts[event.id] ?? 0;

      final scheduledTimeUtc = event.scheduledTime?.toUtc();
      tz.Location scheduledLocation;
      try {
        scheduledLocation =
            timezoneUtils.getLocation(event.scheduledTimeZone ?? '');
      } catch (e) {
        print(
          'Error getting scheduled location: $e. Using America/Los_Angeles',
        );
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
          'https://$domain/space/${community.displayId}/discuss/${event.templateId}/${event.id}';
      final appName = functions.config.get('app.name') as String;

      var participantCountText = '';
      if (participantCount == 1) {
        participantCountText = '1 participant';
      } else {
        participantCountText = '$participantCount participants';
      }

      final descriptionParticipantText =
          (participantCount > 0) ? ' ($participantCountText)' : '';

      builder.element(
        'item',
        nest: () {
          builder.element(
            'title',
            nest: () {
              builder.text(event.title ?? 'Event');
            },
          );
          builder.element(
            'link',
            nest: () {
              builder.text(link);
            },
          );
          builder.element(
            'description',
            nest: () {
              builder.text(
                '$timeText ($durationText): $description$descriptionParticipantText',
              );
            },
          );
          builder.element(
            'guid',
            nest: () {
              builder.attribute('isPermaLink', 'false');
              builder.text(event.id);
            },
          );
          if (image != null) {
            builder.element(
              'media:thumbnail',
              nest: () {
                builder.attribute('url', image);
              },
            );
          }
          builder.element(
            '$appName:time',
            nest: () {
              builder.text(timeText);
            },
          );
          builder.element(
            '$appName:duration',
            nest: () {
              builder.text(durationText);
            },
          );
          builder.element(
            '$appName:description',
            nest: () {
              builder.text(description);
            },
          );
          builder.element(
            '$appName:attendance',
            nest: () {
              builder.text(participantCountText);
            },
          );
        },
      );
    }
  }

  Future<int> _getFullParticipantCount(Event event) async {
    final participants = await firestore
        .collection(
          '${event.collectionPath}/${event.id}/event-participants',
        )
        .get();
    return participants.documents
        .map(
          (e) => Participant.fromJson(
            firestoreUtils.fromFirestoreJson(e.data.toMap()),
          ),
        )
        .where((participant) => participant.status == ParticipantStatus.active)
        .length;
  }
}
