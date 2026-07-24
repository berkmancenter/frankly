@JS()
library agora_stt_api;

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:js/js.dart';
import 'package:node_http/node_http.dart' as http;
import 'dart:convert' as convert;

import 'agora_api.dart';

final _agoraAppId = functions.config.get('agora.app_id') as String;
final _agoraRestKey = functions.config.get('agora.rest_key') as String;
final _agoraRestSecret = functions.config.get('agora.rest_secret') as String;

final _agoraStorageBucketName =
    functions.config.get('agora.storage_bucket_name') as String;
final _agoraStorageAccessKey =
    functions.config.get('agora.storage_access_key') as String;
final _agoraStorageSecretKey =
    functions.config.get('agora.storage_secret_key') as String;

/// Bot UIDs for STT agents. subBot subscribes to audio, pubBot publishes
/// captions back to channel (required by API even if unused).
const int sttSubBotUid = 457;
const int sttPubBotUid = 458;

class AgoraSttApi {
  final AgoraUtils _agoraUtils;

  AgoraSttApi({AgoraUtils? agoraUtils})
      : _agoraUtils = agoraUtils ?? AgoraUtils();

  Map<String, String> _getAuthHeaders() {
    final plainCredential = '$_agoraRestKey:$_agoraRestSecret';
    final authorizationField =
        'Basic ${convert.base64.encode(convert.utf8.encode(plainCredential))}';
    return {
      'Authorization': authorizationField,
      'Content-Type': 'application/json',
    };
  }

  /// Starts an STT agent on the given channel. Returns the agent ID.
  Future<String> startTranscription({
    required String channelName,
    required String language,
  }) async {
    final subBotToken =
        _agoraUtils.createToken(uid: sttSubBotUid, roomId: channelName);
    final pubBotToken =
        _agoraUtils.createToken(uid: sttPubBotUid, roomId: channelName);

    final body = convert.json.encode({
      "name": channelName,
      "languages": [language],
      "maxIdleTime": 300,
      "rtcConfig": {
        "channelName": channelName,
        "subBotUid": sttSubBotUid.toString(),
        "subBotToken": subBotToken,
        "pubBotUid": sttPubBotUid.toString(),
        "pubBotToken": pubBotToken,
      },
      "captionConfig": {
        "storage": {
          "vendor": 6,
          "region": 0,
          "bucket": _agoraStorageBucketName,
          "accessKey": _agoraStorageAccessKey,
          "secretKey": _agoraStorageSecretKey,
          "fileNamePrefix": [channelName, "transcripts"],
        },
      },
    });

    final result = await http.post(
      Uri.parse(
        'https://api.agora.io/api/speech-to-text/v1/projects/$_agoraAppId/join',
      ),
      headers: _getAuthHeaders(),
      body: body,
    );

    if (result.statusCode < 200 || result.statusCode > 299) {
      print('STT start failed (${result.statusCode}): ${result.body}');
      throw HttpsError(
          HttpsError.internal, 'STT start failed: ${result.body}', null,);
    }

    final decoded = convert.jsonDecode(result.body);
    final agentId = decoded['agent_id'] as String;
    print('STT agent started for channel $channelName: $agentId');
    return agentId;
  }

  /// Queries the status of a running STT agent.
  Future<String> queryTranscription({required String agentId}) async {
    final result = await http.get(
      Uri.parse(
        'https://api.agora.io/api/speech-to-text/v1/projects/$_agoraAppId/agents/$agentId',
      ),
      headers: _getAuthHeaders(),
    );

    if (result.statusCode < 200 || result.statusCode > 299) {
      print('STT query failed (${result.statusCode}): ${result.body}');
      throw HttpsError(
          HttpsError.internal, 'STT query failed: ${result.body}', null,);
    }

    final decoded = convert.jsonDecode(result.body);
    return decoded['status'] as String;
  }

  /// Stops a running STT agent.
  Future<void> stopTranscription({required String agentId}) async {
    final result = await http.post(
      Uri.parse(
        'https://api.agora.io/api/speech-to-text/v1/projects/$_agoraAppId/agents/$agentId/leave',
      ),
      headers: _getAuthHeaders(),
      body: '',
    );

    if (result.statusCode < 200 || result.statusCode > 299) {
      print('STT stop failed (${result.statusCode}): ${result.body}');
      throw HttpsError(
          HttpsError.internal, 'STT stop failed: ${result.body}', null,);
    }

    print('STT agent stopped: $agentId');
  }
}
