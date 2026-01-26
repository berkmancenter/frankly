import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

enum OutputMode { storage, download }

class CombineClient {
  final String baseUrl;
  final http.Client _httpClient;

  CombineClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<CombineResult> combine({
    required String bucket,
    required String m3u8Path,
    required OutputMode outputMode,
    String? outputBucket,
    String? outputPath,
    String? downloadPath,
  }) async {
    final uri = Uri.parse('$baseUrl/combine');

    final body = <String, dynamic>{
      'bucket': bucket,
      'm3u8Path': m3u8Path,
      'outputMode': outputMode.name,
    };

    if (outputMode == OutputMode.storage) {
      if (outputBucket == null || outputPath == null) {
        throw ArgumentError(
          'outputBucket and outputPath are required for storage mode',
        );
      }
      body['outputBucket'] = outputBucket;
      body['outputPath'] = outputPath;
    }

    final response = await _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      if (outputMode == OutputMode.download) {
        // Save the MP4 file locally
        final savePath = downloadPath ?? 'output.mp4';
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);

        return CombineResult(
          success: true,
          localPath: savePath,
        );
      } else {
        // Parse JSON response for storage mode
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return CombineResult(
          success: json['success'] as bool,
          outputUrl: json['outputUrl'] as String?,
          durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
        );
      }
    } else {
      String? error;
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        error = json['error'] as String?;
      } catch (_) {
        error = response.body;
      }
      return CombineResult(
        success: false,
        error: error ?? 'Unknown error (status: ${response.statusCode})',
      );
    }
  }

  Future<bool> healthCheck() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await _httpClient.get(uri);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void close() {
    _httpClient.close();
  }
}

class CombineResult {
  final bool success;
  final String? outputUrl;
  final String? localPath;
  final double? durationSeconds;
  final String? error;

  CombineResult({
    required this.success,
    this.outputUrl,
    this.localPath,
    this.durationSeconds,
    this.error,
  });

  @override
  String toString() {
    if (success) {
      final buffer = StringBuffer('Success!');
      if (outputUrl != null) {
        buffer.write('\n  Output URL: $outputUrl');
      }
      if (localPath != null) {
        buffer.write('\n  Downloaded to: $localPath');
      }
      if (durationSeconds != null) {
        buffer.write('\n  Duration: ${durationSeconds!.toStringAsFixed(2)}s');
      }
      return buffer.toString();
    } else {
      return 'Failed: $error';
    }
  }
}
