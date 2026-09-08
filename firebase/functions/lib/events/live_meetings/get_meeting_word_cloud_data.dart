import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/user_input/word_cloud_data.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/infra/firestore_utils.dart';

class GetMeetingWordCloudData
    extends OnCallMethod<GetMeetingWordCloudDataRequest> {
  GetMeetingWordCloudData()
      : super(
          'GetMeetingWordCloudData',
          (json) => GetMeetingWordCloudDataRequest.fromJson(json),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetMeetingWordCloudDataRequest request,
    CallableContext context,
  ) async {
    if (context.authUid == null) {
      throw HttpsError(HttpsError.unauthenticated, 'Sign in required.', null);
    }
    final match =
        RegExp(r'^community/([^/]+)/templates/([^/]+)/events/([^/]+)$')
            .firstMatch(request.eventPath);
    if (match == null) {
      throw HttpsError(HttpsError.invalidArgument, 'Path malformed.', null);
    }
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: Event.fromJson,
    );
    final membershipDoc = await firestore
        .document(
          'memberships/${context.authUid}/community-membership/${match.group(1)}',
        )
        .get();
    final membership = membershipDoc.exists
        ? Membership.fromJson(
            firestoreUtils.fromFirestoreJson(membershipDoc.data.toMap()),
          )
        : null;
    // Match the existing poll/suggestion export access policy.
    if (membership?.isAdmin != true && event.creatorId != context.authUid) {
      throw HttpsError(
        HttpsError.permissionDenied,
        'Export not permitted.',
        null,
      );
    }
    final mainPath = '${request.eventPath}/live-meetings/${match.group(3)}';
    final paths = <String>[mainPath];
    final sessions =
        await firestore.collection('$mainPath/breakout-room-sessions').get();
    for (final session in sessions.documents) {
      final rooms = await firestore
          .collection('${session.reference.path}/breakout-rooms')
          .get();
      paths.addAll(
        rooms.documents.map(
          (room) => '${room.reference.path}/live-meetings/${room.documentID}',
        ),
      );
    }
    final entries = <WordCloudData>[];
    for (final path in paths) {
      final participants = await firestore
          .collectionGroup('participant-details')
          .where(
            ParticipantAgendaItemDetails.kFieldMeetingId,
            isEqualTo: path.split('/').last,
          )
          .get();
      for (final doc in participants.documents) {
        // Room IDs alone are not an authorization boundary. Restrict results
        // to the exact meeting path even if another event reuses an ID.
        final prefix = '$path/participant-agenda-item-details/';
        if (!doc.reference.path.startsWith(prefix)) continue;
        final suffix = doc.reference.path.substring(prefix.length).split('/');
        if (suffix.length != 3 || suffix[1] != 'participant-details') continue;
        final agendaItemId = suffix.first;
        final details = ParticipantAgendaItemDetails.fromJson(
          firestoreUtils.fromFirestoreJson(doc.data.toMap()),
        );
        final agendaItems =
            event.agendaItems.where((a) => a.id == agendaItemId);
        final prompt =
            agendaItems.isEmpty ? '' : agendaItems.first.content ?? '';
        for (final word in details.wordCloudResponses) {
          final saved =
              details.wordCloudEntries.where((e) => e.message == word);
          entries.add(
            saved.isNotEmpty
                ? saved.first.copyWith(
                    userId: doc.documentID,
                    agendaItemId: agendaItemId,
                    roomId: path.split('/').last,
                  )
                : WordCloudData(
                    userId: doc.documentID, agendaItemId: agendaItemId,
                    roomId: path.split('/').last, prompt: prompt, message: word,
                    // Older responses have no per-entry timestamp.
                  ),
          );
        }
      }
    }
    return GetMeetingWordCloudDataResponse(entries: entries).toJson();
  }
}
