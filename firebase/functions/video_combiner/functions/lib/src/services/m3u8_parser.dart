import 'package:path/path.dart' as p;

class M3u8Segment {
  final String uri;
  final double? duration;

  M3u8Segment({required this.uri, this.duration});
}

class M3u8Playlist {
  final List<M3u8Segment> segments;
  final double totalDuration;

  M3u8Playlist({required this.segments, required this.totalDuration});
}

class M3u8Parser {
  static const _extinfTag = '#EXTINF:';
  static const _extM3uTag = '#EXTM3U';

  M3u8Playlist parse(String content, {String? basePath}) {
    final lines = content.split('\n').map((l) => l.trim()).toList();

    if (lines.isEmpty || !lines.first.startsWith(_extM3uTag)) {
      throw FormatException('Invalid M3U8 file: missing #EXTM3U header');
    }

    final segments = <M3u8Segment>[];
    double? currentDuration;
    var totalDuration = 0.0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith(_extinfTag)) {
        // Parse duration from #EXTINF:duration,
        final durationStr = line.substring(_extinfTag.length).split(',').first;
        currentDuration = double.tryParse(durationStr);
        if (currentDuration != null) {
          totalDuration += currentDuration;
        }
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        // This is a segment URI
        var uri = line;

        // Resolve relative paths if basePath is provided
        if (basePath != null && !_isAbsoluteUri(uri)) {
          uri = p.join(p.dirname(basePath), uri);
          // Normalize path separators
          uri = p.normalize(uri);
        }

        segments.add(M3u8Segment(uri: uri, duration: currentDuration));
        currentDuration = null;
      }
    }

    if (segments.isEmpty) {
      throw FormatException('No segments found in M3U8 file');
    }

    return M3u8Playlist(segments: segments, totalDuration: totalDuration);
  }

  bool _isAbsoluteUri(String uri) {
    return uri.startsWith('http://') ||
        uri.startsWith('https://') ||
        uri.startsWith('/');
  }
}
