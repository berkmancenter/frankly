import 'dart:io';

class FfmpegException implements Exception {
  final String message;
  final int exitCode;
  final String? stderr;

  FfmpegException(this.message, this.exitCode, [this.stderr]);

  @override
  String toString() =>
      'FfmpegException: $message (exit code: $exitCode)${stderr != null ? '\n$stderr' : ''}';
}

class FfmpegService {
  final String ffmpegPath;

  FfmpegService({this.ffmpegPath = 'ffmpeg'});

  Future<String> combineToMp4({
    required List<String> inputFiles,
    required String outputPath,
  }) async {
    if (inputFiles.isEmpty) {
      throw ArgumentError('No input files provided');
    }

    // Create a concat file list for ffmpeg
    final tempDir = await Directory.systemTemp.createTemp('ffmpeg_concat_');
    final concatFile = File('${tempDir.path}/concat.txt');

    try {
      // Write the concat file
      final concatContent = inputFiles.map((f) => "file '$f'").join('\n');
      await concatFile.writeAsString(concatContent);

      // Run ffmpeg to concatenate and convert to MP4
      // -f concat: use concat demuxer
      // -safe 0: allow unsafe file paths
      // -i: input concat file
      // -c copy: copy streams without re-encoding (fast)
      // -bsf:a aac_adtstoasc: fix audio bitstream for MP4 container
      final result = await Process.run(
        ffmpegPath,
        [
          '-y', // Overwrite output
          '-f',
          'concat',
          '-safe',
          '0',
          '-i',
          concatFile.path,
          '-c',
          'copy',
          '-bsf:a',
          'aac_adtstoasc',
          outputPath,
        ],
        runInShell: false,
      );

      if (result.exitCode != 0) {
        throw FfmpegException(
          'Failed to combine files',
          result.exitCode,
          result.stderr.toString(),
        );
      }

      return outputPath;
    } finally {
      // Cleanup temp directory
      await tempDir.delete(recursive: true);
    }
  }

  Future<double?> getDuration(String filePath) async {
    final result = await Process.run(
      'ffprobe',
      [
        '-v',
        'error',
        '-show_entries',
        'format=duration',
        '-of',
        'default=noprint_wrappers=1:nokey=1',
        filePath,
      ],
    );

    if (result.exitCode != 0) {
      return null;
    }

    return double.tryParse(result.stdout.toString().trim());
  }

  Future<bool> isAvailable() async {
    try {
      final result = await Process.run(ffmpegPath, ['-version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
