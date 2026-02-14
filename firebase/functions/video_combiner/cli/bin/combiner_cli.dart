import 'dart:io';

import 'package:args/args.dart';

import 'package:combiner_cli/src/client.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'url',
      abbr: 'u',
      help: 'The base URL of the combiner function',
      defaultsTo: 'http://localhost:8080',
    )
    ..addOption(
      'bucket',
      abbr: 'b',
      help: 'The Cloud Storage bucket containing the M3U8 file',
      mandatory: true,
    )
    ..addOption(
      'm3u8',
      abbr: 'm',
      help: 'The path to the M3U8 file within the bucket',
      mandatory: true,
    )
    ..addOption(
      'output-mode',
      abbr: 'o',
      help: 'Output mode: "storage" or "download"',
      allowed: ['storage', 'download'],
      defaultsTo: 'storage',
    )
    ..addOption(
      'output-bucket',
      help: 'The Cloud Storage bucket for the output (storage mode)',
    )
    ..addOption(
      'output-path',
      help: 'The path for the output MP4 in the bucket (storage mode)',
    )
    ..addOption(
      'download-path',
      abbr: 'd',
      help: 'Local path to save the downloaded MP4 (download mode)',
      defaultsTo: 'output.mp4',
    )
    ..addFlag(
      'health',
      help: 'Check the health of the function endpoint',
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message',
      negatable: false,
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printUsage(parser);
      return;
    }

    final url = results['url'] as String;
    final client = CombineClient(baseUrl: url);

    try {
      if (results['health'] as bool) {
        stdout.write('Checking health of $url... ');
        final healthy = await client.healthCheck();
        if (healthy) {
          print('OK');
          exit(0);
        } else {
          print('FAILED');
          exit(1);
        }
      }

      final bucket = results['bucket'] as String;
      final m3u8Path = results['m3u8'] as String;
      final outputModeStr = results['output-mode'] as String;
      final outputMode =
          outputModeStr == 'download' ? OutputMode.download : OutputMode.storage;

      // Validate storage mode options
      if (outputMode == OutputMode.storage) {
        if (results['output-bucket'] == null || results['output-path'] == null) {
          stderr.writeln(
            'Error: --output-bucket and --output-path are required for storage mode',
          );
          exit(1);
        }
      }

      print('Combining M3U8 to MP4...');
      print('  Bucket: $bucket');
      print('  M3U8 Path: $m3u8Path');
      print('  Output Mode: ${outputMode.name}');
      print('');

      final result = await client.combine(
        bucket: bucket,
        m3u8Path: m3u8Path,
        outputMode: outputMode,
        outputBucket: results['output-bucket'] as String?,
        outputPath: results['output-path'] as String?,
        downloadPath: results['download-path'] as String?,
      );

      print(result);

      exit(result.success ? 0 : 1);
    } finally {
      client.close();
    }
  } on ArgParserException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln('');
    _printUsage(parser);
    exit(1);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('M3U8 to MP4 Combiner CLI');
  print('');
  print('Usage: combiner_cli [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('');
  print('  # Combine to Cloud Storage:');
  print('  combiner_cli -b my-bucket -m videos/playlist.m3u8 \\');
  print('    --output-mode storage \\');
  print('    --output-bucket output-bucket \\');
  print('    --output-path videos/output.mp4');
  print('');
  print('  # Download directly:');
  print('  combiner_cli -b my-bucket -m videos/playlist.m3u8 \\');
  print('    --output-mode download \\');
  print('    --download-path ./my-video.mp4');
  print('');
  print('  # Use a deployed function:');
  print('  combiner_cli -u https://my-function.run.app \\');
  print('    -b my-bucket -m videos/playlist.m3u8 \\');
  print('    --output-mode download');
}
