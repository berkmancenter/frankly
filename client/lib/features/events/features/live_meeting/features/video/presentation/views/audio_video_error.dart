import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:universal_html/html.dart' as html;

class AudioVideoErrorDialog extends StatelessWidget {
  final String error;

  const AudioVideoErrorDialog({Key? key, required this.error})
      : super(key: key);

  static Future<T?> showOnError<T>(
    BuildContext context,
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } catch (e, s) {
      loggingService.log(
        'Error in audio/video',
        logType: LogType.error,
        error: e,
        stackTrace: s,
      );

      await showCustomDialog(
        context: context,
        builder: (_) => AudioVideoErrorDialog(error: e.toString()),
      );
      return null;
    }
  }

  static Future<void> show<T>(BuildContext context, String error) async {
    await showCustomDialog(
      context: context,
      builder: (_) => AudioVideoErrorDialog(error: error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.darkBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 700),
        child: Stack(
          children: [
            AudioVideoErrorDisplay(error: error),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AudioVideoErrorDisplay extends StatelessWidget {
  final String error;
  final Color textColor;

  const AudioVideoErrorDisplay({
    Key? key,
    required this.error,
    this.textColor = AppColor.white,
  }) : super(key: key);

  String _buildErrorText() {
    String errorText = error;
    if (errorText.contains('NotReadableError')) {
      errorText =
          'Unable to start microphone or camera. Ensure that no other app or tab is using '
          'your microphone or camera and refresh. '
          'If the problem persists, please restart your browser.';
    } else if (errorText.contains('NotFoundError')) {
      errorText = 'Your microphone or camera was not found. Please ensure your '
          'input devices are connected and enabled for the browser in system '
          'settings. If the problem persists, please restart your browser.';
    } else if (['OverconstrainedError', 'TypeError']
        .any((error) => errorText.contains(error))) {
      errorText = 'Error getting camera and microphone media. Please refresh.';
    } else if (errorText.contains('NotAllowedError')) {
      errorText =
          'You must give permission to access your microphone and camera.'
          '\nMore Info: https://support.google.com/chrome/answer/2693767';
    } else if (errorText.contains('TwilioError')) {
      errorText = 'You were disconnected. Please refresh to reconnect.';
    } else if (errorText
        .toLowerCase()
        .contains('Invalid constraints'.toLowerCase())) {
      errorText =
          'Error connecting to microphone or camera. Please ensure your browser is updated'
          ' and try again.';
    } else if (errorText.contains('TimeoutException')) {
      errorText = 'Oops there was a network error, please try that again.';
    }

    if (errorText.contains(
      'TwilioError: Participant disconnected because of duplicate identity',
    )) {
      errorText =
          'Looks like you have successfully rejoined from a different device or browser.';
    }

    return errorText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Linkify(
            onOpen: (link) => launch(link.url),
            options: LinkifyOptions(
              humanize: false,
              removeWww: false,
            ),
            text: _buildErrorText(),
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 22),
          ),
          SizedBox(height: 16),
          ActionButton(
            text: 'Refresh',
            onPressed: () => html.window.location.reload(),
          ),
        ],
      ),
    );
  }
}
