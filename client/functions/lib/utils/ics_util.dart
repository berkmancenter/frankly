@JS()
library ics;

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
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
  Future<String> getIcsForUpcomingEvents({required Junto junto}) async {
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

    final prodDomain = functions.config.get('app.prod_domain') as String;
    final devDomain = functions.config.get('app.dev_domain') as String;
    final domain = isDev ? devDomain : prodDomain;

    final events =
        discussions.where((event) => event.scheduledTime != null).map((event) {
      final scheduledTime = event.scheduledTime!.toUtc();
      return IcsEvent(
        title: event.title ?? 'Discussion',
        url:
            'https://$domain/space/${junto.displayId}/discuss/${event.topicId}/${event.id}',
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

    if (events.isEmpty) {
      return emptyIcs;
    } else {
      final ics = requireIcsLib();
      final result = ics.createEvents(events);

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
