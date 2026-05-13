@JS()
library agora_api;

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:js/js.dart';
import 'package:data_models/recording/recording_session.dart';
import 'package:data_models/utils/utils.dart';
import 'package:data_models/utils/utils_web.dart';
import 'package:node_interop/node.dart';
import 'package:node_http/node_http.dart' as http;
import 'dart:convert' as convert;
import '../../utils/infra/firestore_utils.dart';

AgoraTokenModule get agoraModule =>
    _agoraModule ??= require('agora-token') as AgoraTokenModule;
AgoraTokenModule? _agoraModule;

final _agoraAppId = functions.config.get('agora.app_id') as String;
int _recordingUid = 456;

final _agoraRestKey = functions.config.get('agora.rest_key') as String;
final _agoraRestSecret = functions.config.get('agora.rest_secret') as String;
final _agoraAppCertificate =
    functions.config.get('agora.app_certificate') as String;

final _agoraStorageBucketName =
    functions.config.get('agora.storage_bucket_name') as String;
final _agoraStorageAccessKey =
    functions.config.get('agora.storage_access_key') as String;
final _agoraStorageSecretKey =
    functions.config.get('agora.storage_secret_key') as String;

class AgoraUtils {
  String createToken({required int uid, required String roomId}) {
    return agoraModule.RtcTokenBuilder.buildTokenWithUid(
      _agoraAppId,
      _agoraAppCertificate,
      roomId,
      uid,
      1 /** Publisher */,
      60 * 10,
    );
  }

  Future<void> recordRoom({
    required String roomId,
    required String sessionId,
    required String eventId,
    required String communityId,
    required RecordingRoomType roomType,
    String? breakoutSessionId,
    String? chatPath,
    List<String> participantIds = const [],
  }) async {
    final sessionRef =
        firestore.collection(RecordingSession.kCollection).document(sessionId);
    final gcsPrefix =
        '$eventId/${breakoutSessionId ?? 'main'}/$roomId/$sessionId';

    // Write session document before any Agora calls so callers can recover on failure.
    await sessionRef.setData(DocumentData.fromMap(
      firestoreUtils.toFirestoreJson(
        RecordingSession(
          sessionId: sessionId,
          communityId: communityId,
          eventId: eventId,
          roomId: roomId,
          roomType: roomType,
          status: RecordingSessionStatus.starting,
          gcsPrefix: gcsPrefix,
          chatPath: chatPath,
          participantIds: participantIds,
          breakoutSessionId: breakoutSessionId,
        ).toJson(),
      ),
    ),);

    print(
        'recording_start: sessionId=$sessionId roomId=$roomId eventId=$eventId roomType=${roomType.name} breakoutSessionId=$breakoutSessionId',);

    String resourceId;
    try {
      resourceId = await _acquireResourceId(roomId: roomId);
      print(
          'recording_acquired: sessionId=$sessionId roomId=$roomId resourceId=$resourceId',);
    } catch (e) {
      print('Agora acquire failed for room $roomId: $e');
      await sessionRef.updateData(UpdateData.fromMap(
        firestoreUtils.toFirestoreJson({
          RecordingSession.kFieldStatus: RecordingSessionStatus.failed.name,
          'errorMessage': e.toString(),
        }),
      ),);
      return;
    }

    await sessionRef
        .updateData(UpdateData.fromMap({'agoraResourceId': resourceId}));

    try {
      final prefixSegments = [
        eventId,
        breakoutSessionId ?? 'main',
        roomId,
        sessionId,
      ];
      final sid = await _startRecording(
        roomId: roomId,
        resourceId: resourceId,
        fileNamePrefixSegments: prefixSegments,
      );
      print(
          'recording_started: sessionId=$sessionId roomId=$roomId resourceId=$resourceId sid=$sid gcsPrefix=$gcsPrefix',);
      await sessionRef.updateData(UpdateData.fromMap({
        'agoraSid': sid,
        RecordingSession.kFieldStatus: RecordingSessionStatus.recording.name,
      }),);
    } catch (e) {
      print('Agora start failed for room $roomId: $e');
      await sessionRef.updateData(UpdateData.fromMap(
        firestoreUtils.toFirestoreJson({
          RecordingSession.kFieldStatus: RecordingSessionStatus.failed.name,
          'errorMessage': e.toString(),
        }),
      ),);
    }
  }

  Future<void> stopRoom({required String sessionId}) async {
    final sessionRef =
        firestore.collection(RecordingSession.kCollection).document(sessionId);

    final snapshot = await sessionRef.get();
    if (!snapshot.exists) {
      print('Session $sessionId not found, skipping stop');
      return;
    }

    final session = RecordingSession.fromJson(
      firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
    );

    if (session.status == RecordingSessionStatus.stopped ||
        session.status == RecordingSessionStatus.failed) {
      print('Session $sessionId already in terminal state, skipping stop');
      return;
    }

    if (session.agoraResourceId != null && session.agoraSid != null) {
      try {
        final result = await http.post(
          Uri.parse(
            'https://api.agora.io/v1/apps/$_agoraAppId/cloud_recording'
            '/resourceid/${session.agoraResourceId}'
            '/sid/${session.agoraSid}/mode/mix/stop',
          ),
          headers: _getAuthHeaders(),
          body: convert.json.encode({
            'cname': session.roomId,
            'uid': _recordingUid.toString(),
            'clientRequest': {},
          }),
        );
        print('Stop response (${result.statusCode}): ${result.body}');
        if (result.statusCode < 200 || result.statusCode > 299) {
          print('Agora stop returned non-2xx for session $sessionId');
        }
      } catch (e) {
        print('Error calling Agora stop for session $sessionId: $e');
      }
    }

    await sessionRef.updateData(UpdateData.fromMap(
      firestoreUtils.toFirestoreJson({
        RecordingSession.kFieldStatus: RecordingSessionStatus.stopped.name,
        'stoppedAt': serverTimestampValue,
      }),
    ),);
  }

  Map<String, String> _getAuthHeaders() {
    final plainCredential = '$_agoraRestKey:$_agoraRestSecret';
    final authorizationField =
        'Basic ${convert.base64.encode(convert.utf8.encode(plainCredential))}';

    return {
      'Authorization': authorizationField,
      'Content-Type': 'application/json',
    };
  }

  Future<String> _acquireResourceId({required String roomId}) async {
    final body = convert.json.encode({
      'cname': roomId,
      'uid': _recordingUid.toString(),
      'clientRequest': {},
    });

    final result = await http.post(
      Uri.parse(
        'https://api.agora.io/v1/apps/$_agoraAppId/cloud_recording/acquire',
      ),
      headers: _getAuthHeaders(),
      body: body,
    );

    print('Acquire response (${result.statusCode}): ${result.body}');
    if (result.statusCode < 200 || result.statusCode > 299) {
      throw HttpsError(
          HttpsError.internal, 'Acquire failed: ${result.body}', null,);
    }
    return convert.jsonDecode(result.body)['resourceId'] as String;
  }

  Future<String> _startRecording({
    required String roomId,
    required String resourceId,
    required List<String> fileNamePrefixSegments,
  }) async {
    final token = createToken(uid: _recordingUid, roomId: roomId);
    final request = {
      'cname': roomId,
      'uid': _recordingUid.toString(),
      'clientRequest': {
        'token': token,
        'recordingConfig': {
          'maxIdleTime': 300,
          'transcodingConfig': {
            'height': 360,
            'width': 640,
            'bitrate': 500,
            'fps': 15,
            'mixedVideoLayout': 1,
            'backgroundColor': '#000000',
          },
        },
        'recordingFileConfig': {
          'avFileType': ['hls', 'mp4'],
        },
        'storageConfig': {
          // Google Cloud
          'vendor': 6,
          // Has no effect in Google cloud but is required
          'region': 0,
          'bucket': _agoraStorageBucketName,
          'accessKey': _agoraStorageAccessKey,
          'secretKey': _agoraStorageSecretKey,
          'fileNamePrefix': fileNamePrefixSegments,
        },
      },
    };

    final result = await http.post(
      Uri.parse(
        'https://api.agora.io/v1/apps/$_agoraAppId/cloud_recording/resourceid/$resourceId/mode/mix/start',
      ),
      headers: _getAuthHeaders(),
      body: convert.json.encode(request),
    );

    print('Start response (${result.statusCode}): ${result.body}');

    if (result.statusCode < 200 || result.statusCode > 299) {
      throw HttpsError(
          HttpsError.internal, 'Start failed: ${result.body}', null,);
    }

    return convert.jsonDecode(result.body)['sid'] as String;
  }

  Future<void> kickParticipant({
    required String roomId,
    required String userId,
  }) async {
    final result = await http.post(
      Uri.parse('https://api.agora.io/dev/v1/kicking-rule'),
      headers: _getAuthHeaders(),
      body: convert.json.encode(
        {
          'appid': _agoraAppId,
          'cname': roomId,
          'uid': uidToInt(userId),
          'time': 1440,
          'privileges': ['join_channel'],
        },
      ),
    );

    print('Result body: ${result.body}');

    if (result.statusCode < 200 || result.statusCode > 299) {
      print('Error result: ${result.statusCode}');
      throw HttpsError(HttpsError.internal, 'Error kicking user', null);
    }
  }
}

@JS()
@anonymous
abstract class AgoraTokenModule {
  //ignore: non_constant_identifier_names
  RtcTokenBuilderClient get RtcTokenBuilder;
}

@JS()
@anonymous
abstract class RtcTokenBuilderClient {
  external String buildTokenWithUid(
    String appId,
    String appCertificate,
    String channelName,
    int uid,
    int role,
    int tokenExpire,
  );
}
