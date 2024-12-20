import 'dart:convert' as convert;
import 'dart:convert';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_http/node_http.dart' as http;

final muxApi = MuxApi();

class MuxApi {
  static final _muxTokenId = functions.config.get('mux.token_id') as String;
  static final _muxSecret = functions.config.get('mux.secret') as String;

  static String get _auth => '$_muxTokenId:$_muxSecret';

  final Map<String, String> _headers = {
    'Authorization': 'Basic ${base64.encode(_auth.codeUnits)}',
    'Content-Type': 'application/json',
  };

  Future<dynamic> createLiveStream() async {
    final response = await http.post(
      Uri.parse('https://api.mux.com/video/v1/live-streams'),
      headers: _headers,
      body: convert.json.encode(
        {
          'playback_policy': 'public',
          'reduced_latency': true,
          'new_asset_settings': {
            'playback_policy': 'public',
          },
        },
      ),
    );

    _verifyResponse(response);

    return convert.json.decode(response.body)['data'];
  }

  void _verifyResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode > 299) {
      print('Error during mux call:');
      print(response.statusCode);
      print(response.body);
      throw Exception(response.body);
    }
  }
}
