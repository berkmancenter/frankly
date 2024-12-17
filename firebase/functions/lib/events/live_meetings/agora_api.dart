@JS()
library agora_api;

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:js/js.dart';
import 'package:data_models/utils.dart';
import 'package:node_interop/node.dart';
import 'package:node_http/node_http.dart' as http;
import 'dart:convert' as convert;

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

  Future<void> recordRoom({required String roomId}) async {
    // Get a resource ID
    final resourceId = await _acquireResourceId(roomId: roomId);
    print('Acquired resource ID: $resourceId');

    try {
      await _startRecording(roomId: roomId, resourceId: resourceId);
    } catch (e) {
      print("Error in starting recording for room $roomId");
      print(e);
    }
  }

  Map<String, String> _getAuthHeaders() {
    final plainCredential = '$_agoraRestKey:$_agoraRestSecret';
    final authorizationField =
        'Basic ${convert.base64.encode(convert.utf8.encode(plainCredential))}';

    print('Authorization field: $authorizationField');

    return {
      'Authorization': authorizationField,
      'Content-Type': 'application/json',
    };
  }

  Future<String> _acquireResourceId({required String roomId}) async {
    final body = convert.json.encode({
      "cname": roomId,
      "uid": _recordingUid.toString(),
      "clientRequest": {},
    });

    print("Sending with body: $body");

    final result = await http.post(
      Uri.parse(
        'https://api.agora.io/v1/apps/$_agoraAppId/cloud_recording/acquire',
      ),
      headers: _getAuthHeaders(),
      body: body,
    );

    return convert.jsonDecode(result.body)["resourceId"];
  }

  Future<String> _startRecording({
    required String roomId,
    required String resourceId,
  }) async {
    final token = createToken(uid: _recordingUid, roomId: roomId);
    final request = {
      "cname": roomId,
      "uid": _recordingUid.toString(),
      "clientRequest": {
        "token": token,
        "recordingConfig": {
          "transcodingConfig": {
            "height": 360,
            "width": 640,
            "bitrate": 500,
            "fps": 15,
            "mixedVideoLayout": 1,
            "backgroundColor": "#000000",
          },
        },
        "recordingFileConfig": {
          "avFileType": ["hls", "mp4"],
        },
        "storageConfig": {
          // Google Cloud
          "vendor": 6,
          // Has no effect in Google cloud but it is required
          "region": 0,
          "bucket": _agoraStorageBucketName,
          "accessKey": _agoraStorageAccessKey,
          "secretKey": _agoraStorageSecretKey,
          "fileNamePrefix": [roomId],
        },
      },
    };

    print('Sending with request: $request');
    final result = await http.post(
      Uri.parse(
        'https://api.agora.io/v1/apps/$_agoraAppId/cloud_recording/resourceid/$resourceId/mode/mix/start',
      ),
      headers: _getAuthHeaders(),
      body: convert.json.encode(request),
    );

    print('Result body: ${result.body}');

    if (result.statusCode < 200 || result.statusCode > 299) {
      print('Error result: ${result.statusCode}');
      throw HttpsError(HttpsError.internal, 'Error starting recording', null);
    }

    await _queryRecordingState(
      resourceId: resourceId,
      sid: convert.jsonDecode(result.body)['sid'],
    );

    return result.body;
  }

  Future<void> _queryRecordingState({
    required String sid,
    required String resourceId,
  }) async {
    final result = await http.get(
      Uri.parse(
        'https://api.agora.io/v1/apps/$_agoraAppId/cloud_recording/resourceid/$resourceId/sid/$sid/mode/mix/query',
      ),
      headers: _getAuthHeaders(),
    );

    print('Recording state: ${result.body}');
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
          "appId": _agoraAppId,
          "cname": roomId,
          "uid": uidToInt(userId),
          "time": 1440,
          "privileges": ["join_channel"],
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
