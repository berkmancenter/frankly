import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import 'package:intl/intl.dart';
import '../cloud_function.dart';
import 'infra/firestore_utils.dart';
import 'timezone_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:timezone/standalone.dart' as tz;
import 'template_utils.dart';

class ShareLink implements CloudFunction {
  @override
  final String functionName = 'ShareLink';

  final _appName = functions.config.get('app.name') as String;

  /// Remove /share/
  String _getRedirect(String requestedUri) {
    print('Getting redirect');
    if (requestedUri.contains('/share/community/')) {
      return requestedUri.replaceFirst("/share/community/", "/space/");
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

  Future<String> _getHtmlContent(
    String requestedUri, {
    bool isLinkedIn = false,
  }) async {
    final redirect = _getRedirect(requestedUri);
    final appPath = _getAppPath(Uri.parse(requestedUri));

    var title = '$_appName - Real Deliberations, Meaningful Communities';
    var image = functions.config.get('app.banner_image_url') as String;
    var description =
        'Deliberations with real people in real time, for any interest.';

    final eventMatch =
        RegExp('(?:space|community)/([^/]+)/discuss/([^/]+)/([^/]+)')
            .matchAsPrefix(appPath);
    final communityMatch =
        RegExp('(?:space|community)/([^/]+)').matchAsPrefix(appPath);
    if (eventMatch != null) {
      var communityId = eventMatch.group(1);
      final templateId = eventMatch.group(2);
      final eventId = eventMatch.group(3);

      final communityDoc =
          await firestore.document('community/$communityId').get();
      final community = Community.fromJson(
        firestoreUtils.fromFirestoreJson(communityDoc.data.toMap()),
      );

      final templateDoc = await firestore
          .document('community/$communityId/templates/$templateId')
          .get();
      final template = TemplateUtils.templateFromSnapshot(templateDoc);

      final eventDoc = await firestore
          .document(
            'community/$communityId/templates/$templateId/events/$eventId',
          )
          .get();
      final event = Event.fromJson(
        firestoreUtils.fromFirestoreJson(eventDoc.data.toMap()),
      );

      final scheduledTimeUtc = event.scheduledTime?.toUtc();

      tz.Location scheduledLocation;
      try {
        scheduledLocation =
            timezoneUtils.getLocation(event.scheduledTimeZone ?? '');
      } catch (e) {
        print(
          'Error getting scheduled location: $e. Using America/Los_Angeles',
        );
        scheduledLocation = timezoneUtils.getLocation('America/Los_Angeles');
      }
      final timeZoneAbbreviation = scheduledLocation.currentTimeZone.abbr;

      tz.TZDateTime scheduledTimeLocal =
          tz.TZDateTime.from(scheduledTimeUtc!, scheduledLocation);

      final date = DateFormat('E, MMM d').format(scheduledTimeLocal);
      final time = DateFormat('h:mm a').format(scheduledTimeLocal);

      title = 'Join my event on ${event.title ?? template.title}!';
      description = '$_appName - $date $time $timeZoneAbbreviation - Join '
          '${community.name} on $_appName!';
      image = event.image ?? template.image ?? community.bannerImageUrl ?? '';
    } else if (communityMatch != null) {
      var communityId = communityMatch.group(1);

      final communityDoc =
          await firestore.document('community/$communityId').get();
      final community = Community.fromJson(
        firestoreUtils.fromFirestoreJson(communityDoc.data.toMap()),
      );

      title = '${community.name} on $_appName';
      description = community.description ?? description;
      image = community.bannerImageUrl ?? '';
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
        expressRequest.response.write(
          await _getHtmlContent(
            expressRequest.requestedUri.toString(),
            isLinkedIn: userAgent.contains('linkedinbot'),
          ),
        );
      } else {
        return await expressRequest.response.redirect(
          Uri.parse(_getRedirect(expressRequest.requestedUri.toString())),
        );
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
        .runWith(
          RuntimeOptions(timeoutSeconds: 60, memory: '1GB', minInstances: 0),
        )
        .https
        .onRequest(expressAction);
  }
}
