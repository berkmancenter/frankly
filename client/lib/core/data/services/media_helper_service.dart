import 'dart:async';
import 'dart:convert';

import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;
import 'package:universal_html/js_util.dart' as js_util;

class PickedVideoResult {
  final String url;

  /// Duration in whole seconds, as reported by Cloudinary. Null for non-direct uploads (YouTube,
  /// Vimeo, external URLs) where the duration is not available at upload time.
  final int? durationInSeconds;

  PickedVideoResult({required this.url, this.durationInSeconds});
}

class _PickedMediaInfo {
  final String url;
  final double? duration;
  _PickedMediaInfo(this.url, this.duration);
}

class MediaHelperService {
  static const defaultMediaPreset = Environment.cloudinaryDefaultPreset;

  static const imageFormatDescription = 'image';
  static const videoExtensionsToTransform = ['mov', 'flv', 'mkv', 'ogv'];
  static const allowedVideoFormats = [
    ...videoExtensionsToTransform,
    'mp4',
    'webm',
  ];

  /// Cloudinary will automatically transform videos to mp4 if we replace the extension to .mp4.
  ///
  /// We leave mp4 and webm videos alone because they can be played natively by our player.
  String? tryTransformVideoUrlToMp4(String? url) {
    if (url != null &&
        videoExtensionsToTransform.any((ext) => url.endsWith(ext))) {
      final segments = url.split('.');
      if (segments.length > 1) {
        return [
          ...segments.take(segments.length - 1),
          'mp4',
        ].join('.');
      }
    }
    return url;
  }

  Future<PickedVideoResult?> pickVideoViaCloudinary() async {
    final info = await _pickMediaInfo(
      uploadPreset: Environment.cloudinaryVideoPreset,
      clientAllowedFormats: allowedVideoFormats,
    );
    if (info == null) return null;
    final url = tryTransformVideoUrlToMp4(info.url) ?? info.url;
    return PickedVideoResult(
      url: url,
      durationInSeconds: info.duration?.round(),
    );
  }

  Future<String?> pickImageViaCloudinary() {
    return pickMediaViaCloudinary(
      uploadPreset: Environment.cloudinaryImagePreset,
      clientAllowedFormats: [imageFormatDescription],
      cropping: true,
      croppingAspectRatio: 1.0,
    );
  }

  Future<String?> pickMediaViaCloudinary({
    required String uploadPreset,
    List<String> clientAllowedFormats = const [
      imageFormatDescription,
      ...allowedVideoFormats,
    ],
    bool cropping = false,
    double? croppingAspectRatio,
  }) async {
    final info = await _pickMediaInfo(
      uploadPreset: uploadPreset,
      clientAllowedFormats: clientAllowedFormats,
      cropping: cropping,
      croppingAspectRatio: croppingAspectRatio,
    );
    return info?.url;
  }

  /// Like [pickMediaViaCloudinary] but also returns the video duration in seconds
  /// when a video file is uploaded via Cloudinary (null for images or external URLs).
  Future<PickedVideoResult?> pickMediaViaCloudinaryWithDuration({
    required String uploadPreset,
    List<String> clientAllowedFormats = const [
      imageFormatDescription,
      ...allowedVideoFormats,
    ],
    bool cropping = false,
    double? croppingAspectRatio,
  }) async {
    final info = await _pickMediaInfo(
      uploadPreset: uploadPreset,
      clientAllowedFormats: clientAllowedFormats,
      cropping: cropping,
      croppingAspectRatio: croppingAspectRatio,
    );
    if (info == null) return null;
    return PickedVideoResult(
      url: info.url,
      durationInSeconds: info.duration?.round(),
    );
  }

  Future<_PickedMediaInfo?> _pickMediaInfo({
    required String uploadPreset,
    List<String> clientAllowedFormats = const [
      imageFormatDescription,
      ...allowedVideoFormats,
    ],
    bool cropping = false,
    double? croppingAspectRatio,
  }) {
    final completer = Completer<_PickedMediaInfo?>();

    final parameters = {
      'cloudName': Environment.cloudinaryCloudName,
      'uploadPreset': uploadPreset,
      // Only picking from files or via inputting URL
      'sources': ['local', 'url'],
      // Only single file possible to pick
      'multiple': false,
      'clientAllowedFormats': clientAllowedFormats,
      'cropping': cropping,
      'croppingAspectRatio': croppingAspectRatio,
      'showPoweredBy': false,
      'showCompletedButton': false,
      // Close picker straight after image is uploaded
      'singleUploadAutoClose': true,
    };
    js_util.callMethod(html.window, 'pickMedia', [
      js_util.jsify(parameters),
      js.allowInterop((error, result) {
        loggingService
            .log('Image Picker result Error: $error, Result: $result');
        if (completer.isCompleted) {
          loggingService.log('Completer already completed. Returning');
          return;
        }

        if (error != null) {
          completer.completeError(error);
        } else {
          try {
            // We are expecting this format
            //{"info":{"files":[{"id":"uw-file3","batchId":"uw-batch2","name":"nyan-cat-4k.gif","size":0,"type":"","imageDimensions":[],"status":"success","progress":100,"done":true,"failed":false,"aborted":false,"paused":false,"partOfBatch":false,"publicId":"","preparedParams":{},"camera":false,"coordinatesResize":false,"delayedPreCalls":false,"publicIdCounter":-1,"isFetch":true,"statusText":"success","uploadInfo":{"asset_id":"2448ddf3f766f70f1e477313671fb488","public_id":"nyan-cat-4k_epljbh","version":1636362311,"version_id":"8afdf8293dc8211de2be1315b37d1ab2","signature":"77e182747682e38c8bfc3543357cefb617a8bb2c","width":220,"height":124,"format":"gif","resource_type":"image","created_at":"2021-11-08T09:05:11Z","tags":[],"pages":24,"bytes":35477,"type":"upload","etag":"5e7895f961693adc6b76729f12fdecd3","placeholder":false,"url":"http://res.cloudinary.com/community/image/upload/v1636362311/nyan-cat-4k_epljbh.gif","secure_url":"https://res.cloudinary.com/community/image/upload/v1636362311/nyan-cat-4k_epljbh.gif","access_mode":"public","existing":false,"original_filename":"nyan-cat-4k","path":"v1636362311/nyan-cat-4k_epljbh.gif","thumbnail_url":"https://res.cloudinary.com/community/image/upload/c_limit,h_60,w_90/v1636362311/nyan-cat-4k_epljbh.jpg"}}]},"event":"queues-end","uw_event":true,"data":{"type":"uw_event","widgetId":"widget_9","event":"queues-end","info":{"files":[{"id":"uw-file3","batchId":"uw-batch2","name":"nyan-cat-4k.gif","size":0,"type":"","imageDimensions":[],"status":"success","progress":100,"done":true,"failed":false,"aborted":false,"paused":false,"partOfBatch":false,"publicId":"","preparedParams":{},"camera":false,"coordinatesResize":false,"delayedPreCalls":false,"publicIdCounter":-1,"isFetch":true,"statusText":"success","uploadInfo":{"asset_id":"2448ddf3f766f70f1e477313671fb488","public_id":"nyan-cat-4k_epljbh","version":1636362311,"version_id":"8afdf8293dc8211de2be1315b37d1ab2","signature":"77e182747682e38c8bfc3543357cefb617a8bb2c","width":220,"height":124,"format":"gif","resource_type":"image","created_at":"2021-11-08T09:05:11Z","tags":[],"pages":24,"bytes":35477,"type":"upload","etag":"5e7895f961693adc6b76729f12fdecd3","placeholder":false,"url":"http://res.cloudinary.com/community/image/upload/v1636362311/nyan-cat-4k_epljbh.gif","secure_url":"https://res.cloudinary.com/community/image/upload/v1636362311/nyan-cat-4k_epljbh.gif","access_mode":"public","existing":false,"original_filename":"nyan-cat-4k","path":"v1636362311/nyan-cat-4k_epljbh.gif","thumbnail_url":"https://res.cloudinary.com/community/image/upload/c_limit,h_60,w_90/v1636362311/nyan-cat-4k_epljbh.jpg"}}]}}}
            // More info here https://cloudinary.com/documentation/upload_widget_reference#events
            final parsedResult = jsonDecode(result) as Map<String, dynamic>;
            final event = parsedResult['event'];

            // https://cloudinary.com/documentation/upload_widget_reference#success
            if (event == 'success') {
              final info = parsedResult['info'] as Map<String, dynamic>;
              final url = info['url'] as String;
              final duration = (info['duration'] as num?)?.toDouble();
              completer.complete(_PickedMediaInfo(url, duration));
            } else if (event == 'close') {
              completer.complete(null);
            }
          } catch (error) {
            completer.completeError(error);
          }
        }
      }),
    ]);

    return completer.future;
  }

  String? getYoutubeVideoId(String url) {
    // Handles watch, embed, shorts, and youtu.be short-link formats,
    // with or without extra query parameters.
    final RegExp regExp = RegExp(
      r'(?:youtube(?:-nocookie)?\.com/(?:watch\?(?:.*&)?v=|embed/|shorts/|v/)|youtu\.be/)([a-zA-Z0-9_-]{11})',
    );
    return regExp.firstMatch(url)?.group(1);
  }

  String? getVimeoVideoId(String url) {
    // https://stackoverflow.com/a/67153064/4722635
    final RegExp regExp = RegExp(
      r'(?:http|https)?:?\/?\/?(?:www\.)?(?:player\.)?vimeo\.com\/(?:channels\/(?:\w+\/)?|groups\/(?:[^\/]*)\/videos\/|video\/|)(\d+)(?:|\/\?)',
    );
    final regExpMatch = regExp.firstMatch(url);

    return regExpMatch != null && regExpMatch.groupCount > 0
        ? regExpMatch.group(1)
        : null;
  }

  /// Fetches the duration in whole seconds for a Vimeo video using the public
  /// oEmbed API. Returns null if the video is private, not found, or on network error.
  Future<int?> fetchVimeoDuration(String vimeoId) async {
    try {
      final response = await http.get(
        Uri.parse('https://vimeo.com/api/oembed.json?url=https://vimeo.com/$vimeoId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['duration'] as num?)?.round();
      }
    } catch (_) {}
    return null;
  }
}
