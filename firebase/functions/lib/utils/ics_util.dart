@JS()
library ics;

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'firestore_utils.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';
import 'package:node_interop/node.dart';
import 'package:js/js.dart';

final _icsProdId = functions.config.get('ics.prod_id') as String;

IcsLib requireIcsLib() {
  return require('ics') as IcsLib;
}

@JS()
@anonymous
abstract class IcsLib {
  external IcsResult createEvents(List<IcsEvent> events);
}

@JS()
@anonymous
abstract class IcsResult {
  external ErrorResult? get error;
  external String? get value;
}

@JS()
@anonymous
abstract class ErrorResult {
  external List<dynamic>? get errors;
}

@JS()
@anonymous
class IcsEvent {
  external List<int> get start;
  external String get startInputType;
  external IcsDuration get duration;
  external String title;
  external String url;
  external String uid;
  external String productId;

  external factory IcsEvent({
    List<dynamic> start,
    String startInputType,
    IcsDuration duration,
    String title,
    String url,
    String uid,
    String productId,
  });
}

@JS()
@anonymous
class IcsDuration {
  external int get minutes;

  external factory IcsDuration({
    int minutes,
  });
}

final emptyIcs = '''BEGIN:VCALENDAR
VERSION:2.0
CALSCALE:GREGORIAN
PRODID:$_icsProdId
METHOD:PUBLISH
X-PUBLISHED-TTL:PT1H
END:VCALENDAR
''';

final icsUtil = IcsUtil();

class IcsUtil {
  /// Return an ICS string containing future events for a given community
  Future<String> getIcsForUpcomingEvents({required Community community}) async {
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

    final domain = functions.config.get('app.domain') as String;

    final scheduledEvents =
        events.where((event) => event.scheduledTime != null).map((event) {
      final scheduledTime = event.scheduledTime!.toUtc();
      return IcsEvent(
        title: event.title ?? 'Event',
        url:
            'https://$domain/space/${community.displayId}/discuss/${event.templateId}/${event.id}',
        uid: event.id,
        startInputType: 'utc',
        start: [
          scheduledTime.year,
          scheduledTime.month,
          scheduledTime.day,
          scheduledTime.hour,
          scheduledTime.minute,
        ],
        duration: IcsDuration(minutes: 60),
        productId: _icsProdId,
      );
    }).toList();

    if (scheduledEvents.isEmpty) {
      return emptyIcs;
    } else {
      final ics = requireIcsLib();
      final result = ics.createEvents(scheduledEvents);

      final error = result.error;
      final value = result.value;
      if (error != null) {
        print(error.errors);
        throw Exception('Could not generate feed');
      }
      if (value == null) {
        throw Exception('Could not generate feed');
      }
      return value;
    }
  }
}
