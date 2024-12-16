import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:intl/intl.dart';
import 'package:junto_functions/functions/junto_cloud_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/timezone_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:junto_functions/utils/topic_utils.dart';

class ShareLink implements JuntoCloudFunction {
  @override
  final String functionName = 'ShareLink';

  final juntoIdLookup = <String, String>{
    'living-room-conversations': '53FXvTKVnJlUPInVgDzd',
  };
  final _appName = functions.config.get('app.name') as String;

  /// Remove /share/
  String _getRedirect(String requestedUri) {
    print('Getting redirect');
    if (requestedUri.contains('/share/junto/')) {
      return requestedUri.replaceFirst("/share/junto/", "/space/");
    } else if (requestedUri.contains('/share/')) {
      print('Replacing share');
      return requestedUri.replaceFirst("/share/", "/");
    } else {
      return requestedUri;
    }
  }

  String _getAppPath(Uri requestedUri) {
    return requestedUri.pathSegments.skip(1).join('/');
  }

  Future<String> _getHtmlContent(String requestedUri,
      {bool isLinkedIn = false}) async {
    final redirect = _getRedirect(requestedUri);
    final appPath = _getAppPath(Uri.parse(requestedUri));

    var title = '$_appName - Real Discussions, Meaningful Communities';
    var image = functions.config.get('app.banner_image_url') as String;
    var description =
        'Discussion groups with real people in real time, for any interest.';

    final discussionMatch =
        RegExp('(?:space|junto)/([^/]+)/discuss/([^/]+)/([^/]+)')
            .matchAsPrefix(appPath);
    final juntoMatch = RegExp('(?:space|junto)/([^/]+)').matchAsPrefix(appPath);
    if (discussionMatch != null) {
      var juntoId =
          juntoIdLookup[discussionMatch.group(1)] ?? discussionMatch.group(1);
      final topicId = discussionMatch.group(2);
      final discussionId = discussionMatch.group(3);

      final juntoDoc = await firestore.document('junto/$juntoId').get();
      final junto = Junto.fromJson(
          firestoreUtils.fromFirestoreJson(juntoDoc.data.toMap()));

      final topicDoc =
          await firestore.document('junto/$juntoId/topics/$topicId').get();
      final topic = TopicUtils.topicFromSnapshot(topicDoc);

      final discussionDoc = await firestore
          .document('junto/$juntoId/topics/$topicId/discussions/$discussionId')
          .get();
      final discussion = Discussion.fromJson(
          firestoreUtils.fromFirestoreJson(discussionDoc.data.toMap()));

      final scheduledTimeUtc = discussion.scheduledTime?.toUtc();

      tz.Location scheduledLocation;
      try {
        scheduledLocation =
            timezoneUtils.getLocation(discussion.scheduledTimeZone ?? '');
      } catch (e) {
        print(
            'Error getting scheduled location: $e. Using America/Los_Angeles');
        scheduledLocation = timezoneUtils.getLocation('America/Los_Angeles');
      }
      final timeZoneAbbreviation = scheduledLocation.currentTimeZone.abbr;

      tz.TZDateTime scheduledTimeLocal =
          tz.TZDateTime.from(scheduledTimeUtc!, scheduledLocation);

      final date = DateFormat('E, MMM d').format(scheduledTimeLocal);
      final time = DateFormat('h:mm a').format(scheduledTimeLocal);

      title = 'Join my conversation on ${discussion.title ?? topic.title}!';
      description = '$_appName - $date $time $timeZoneAbbreviation - Join '
          '${junto.name} on $_appName!';
      image = discussion.image ?? topic.image ?? junto.bannerImageUrl ?? '';
    } else if (juntoMatch != null) {
      var juntoId = juntoIdLookup[juntoMatch.group(1)] ?? juntoMatch.group(1);

      final juntoDoc = await firestore.document('junto/$juntoId').get();
      final junto = Junto.fromJson(
          firestoreUtils.fromFirestoreJson(juntoDoc.data.toMap()));

      title = '${junto.name} on $_appName';
      description = junto.description ?? description;
      image = junto.bannerImageUrl ?? '';
    }

    if (isLinkedIn &&
        image.contains('picsum.photos') &&
        image.contains('.webp')) {
      image = image.replaceAll('.webp', '');
    }

    print(image);
    return '''
      <html>
      <head>
        <meta charset="UTF-8">
        <meta content="IE=Edge" http-equiv="X-UA-Compatible">
        <meta name="description" content="$description">

        <meta property="og:title" content="$title"/>
        <meta property="og:description" content="$description"/>
        <meta property="og:url" content="$requestedUri"/>
        <meta property="og:image" content="$image"/>
        <meta name="image" property="og:image" content="$image">

        <meta name="twitter:title" content="$title">
        <meta name="twitter:description" content="$description">
        <meta name="twitter:image" content="$image">
        <meta name="twitter:card" content="summary_large_image">

        <title>$title</title>

      </head>
      <body>
        <p><a href="$redirect">Click here</a> to continue!</p>
      </body>
      </html>
    ''';
  }

  Future<void> expressAction(ExpressHttpRequest expressRequest) async {
    try {
      // Determine what resource is being requested from URL
      print(expressRequest.requestedUri.toString());

      // Necessary because the expressRequest requested URI object is not actually a dart URI
      final requestedUri = Uri.parse(expressRequest.requestedUri.toString());
      print(requestedUri.toString());

      final userAgent =
          expressRequest.headers.value('User-Agent')?.toLowerCase() ?? '';
      if (userAgent.contains('facebookexternalhit') ||
          userAgent.contains('facebot') ||
          userAgent.contains('twitterbot') ||
          userAgent.contains('linkedinbot')) {
        expressRequest.response.headers.add("Cache-Control", "no-cache");
        expressRequest.response.write(await _getHtmlContent(
            expressRequest.requestedUri.toString(),
            isLinkedIn: userAgent.contains('linkedinbot')));
      } else {
        return await expressRequest.response.redirect(
            Uri.parse(_getRedirect(expressRequest.requestedUri.toString())));
      }
    } catch (e, stacktrace) {
      print('Error during action');
      print(e);
      print(stacktrace);
      expressRequest.response.addError(e, stacktrace);
    }

    await expressRequest.response.close();
  }

  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(RuntimeOptions(
            timeoutSeconds: 60, memory: '1GB', minInstances: 0))
        .https
        .onRequest(expressAction);
  }
}
