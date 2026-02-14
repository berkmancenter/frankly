import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import '../models/combine_request.dart';
import '../models/combine_response.dart';
import '../services/ffmpeg_service.dart';
import '../services/m3u8_parser.dart';
import '../services/storage_service.dart';

class CombineHandler {
  final StorageService _storageService;
  final M3u8Parser _m3u8Parser;
  final FfmpegService _ffmpegService;

  CombineHandler({
    StorageService? storageService,
    M3u8Parser? m3u8Parser,
    FfmpegService? ffmpegService,
  })  : _storageService = storageService ?? StorageService(),
        _m3u8Parser = m3u8Parser ?? M3u8Parser(),
        _ffmpegService = ffmpegService ?? FfmpegService();

  Future<Response> handle(Request request) async {
    // Only accept POST requests
    if (request.method != 'POST') {
      return Response(
        405,
        body: jsonEncode({'error': 'Method not allowed'}),
        headers: {'content-type': 'application/json'},
      );
    }

    try {
      // Parse request body
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final combineRequest = CombineRequest.fromJson(json);

      // Process the request
      final response = await _process(combineRequest);

      if (response.success && combineRequest.outputMode == OutputMode.download) {
        // For download mode, stream the file
        final outputPath = response.outputUrl!;
        final file = File(outputPath);
        final bytes = await file.readAsBytes();

        // Clean up temp file
        await file.delete();

        return Response.ok(
          bytes,
          headers: {
            'content-type': 'video/mp4',
            'content-disposition': 'attachment; filename="output.mp4"',
          },
        );
      }

      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'content-type': 'application/json'},
      );
    } on FormatException catch (e) {
      return Response.badRequest(
        body: jsonEncode(CombineResponse.failure('Invalid request: $e').toJson()),
        headers: {'content-type': 'application/json'},
      );
    } on ArgumentError catch (e) {
      return Response.badRequest(
        body: jsonEncode(CombineResponse.failure(e.message).toJson()),
        headers: {'content-type': 'application/json'},
      );
    } catch (e, stack) {
      print('Error processing request: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode(CombineResponse.failure('Internal error: $e').toJson()),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<CombineResponse> _process(CombineRequest request) async {
    final stopwatch = Stopwatch()..start();

    // Create temp directory for processing
    final tempDir = await Directory.systemTemp.createTemp('m3u8_combine_');

    try {
      // 1. Download and parse M3U8 file
      print('Downloading M3U8: ${request.bucket}/${request.m3u8Path}');
      final m3u8Content = await _storageService.downloadFile(
        request.bucket,
        request.m3u8Path,
      );
      final m3u8String = utf8.decode(m3u8Content);

      // 2. Parse M3U8 to get segment list
      print('Parsing M3U8...');
      final playlist = _m3u8Parser.parse(
        m3u8String,
        basePath: request.m3u8Path,
      );
      print('Found ${playlist.segments.length} segments');

      // 3. Download all TS segments
      print('Downloading segments...');
      final localSegmentPaths = <String>[];

      for (var i = 0; i < playlist.segments.length; i++) {
        final segment = playlist.segments[i];
        final localPath = '${tempDir.path}/segment_${i.toString().padLeft(5, '0')}.ts';

        print('  Downloading segment ${i + 1}/${playlist.segments.length}: ${segment.uri}');
        await _storageService.downloadToFile(
          request.bucket,
          segment.uri,
          localPath,
        );
        localSegmentPaths.add(localPath);
      }

      // 4. Combine segments using ffmpeg
      print('Combining segments with ffmpeg...');
      final outputMp4Path = '${tempDir.path}/output.mp4';
      await _ffmpegService.combineToMp4(
        inputFiles: localSegmentPaths,
        outputPath: outputMp4Path,
      );

      // Get actual duration from output file
      final actualDuration = await _ffmpegService.getDuration(outputMp4Path);

      stopwatch.stop();

      // 5. Handle output based on mode
      if (request.outputMode == OutputMode.storage) {
        // Upload to Cloud Storage
        print('Uploading to ${request.outputBucket}/${request.outputPath}...');
        await _storageService.uploadFromFile(
          request.outputBucket!,
          request.outputPath!,
          outputMp4Path,
          contentType: 'video/mp4',
        );

        final url = await _storageService.getSignedUrl(
          request.outputBucket!,
          request.outputPath!,
        );

        // Clean up temp directory
        await tempDir.delete(recursive: true);

        return CombineResponse.success(
          outputUrl: url,
          durationSeconds: actualDuration ?? playlist.totalDuration,
        );
      } else {
        // Download mode - return the local path for streaming
        // Note: caller is responsible for cleanup
        return CombineResponse.success(
          outputUrl: outputMp4Path,
          durationSeconds: actualDuration ?? playlist.totalDuration,
        );
      }
    } catch (e) {
      // Clean up on error
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
      rethrow;
    }
  }
}
