import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/config/environment.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';

const _kTroubleshootingGuideUrl = Environment.troubleshootingGuideUrl;

const needHelpMarkdown = '''
### Technical Issues?

__Refresh the page:__ Click the refresh button in the upper-right corner or refresh your browser. You will stay in the same room.

__Close other programs:__ Close Zoom, Microsoft Teams, and other programs that use your camera and microphone.

__Check your Audio/Video Settings:__
- Click the three dots (. . .) in the bottom left and click “Audio/Video Settings” to select the correct camera and microphone.
- Be sure to “Allow” camera or mic access if prompted.

__Try a different device or browser:__ We recommend Chrome or Firefox on a laptop or desktop, and Safari if using an iPhone or iPad. When you enter the event again you will be placed in the same room.
''';

const needHelpMarkdownWithContactAdmin = '''
$needHelpMarkdown

If you still need help, [click here](ask-admin) to request an admin to join your room and assist you as soon as they can.
''';

class NeedHelpDialog extends StatelessWidget {
  final bool showContactAdmin;

  const NeedHelpDialog({this.showContactAdmin = false});

  Future<bool> show() async {
    return (await showCustomDialog(builder: (_) => this)) ?? false;
  }

  Widget _buildDialog(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: 600,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ActionButton(
                  height: 40,
                  padding: const EdgeInsets.all(0),
                  margin: const EdgeInsets.all(0),
                  minWidth: 50,
                  borderRadius: BorderRadius.circular(0),
                  color: Colors.transparent,
                  icon: Icon(
                    Icons.close,
                    size: 40,
                    color: AppColor.darkBlue,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              Flexible(
                child: Markdown(
                  data: showContactAdmin
                      ? needHelpMarkdownWithContactAdmin
                      : needHelpMarkdown,
                  shrinkWrap: true,
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    strong: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTapLink: (text, href, _) {
                    if (href == 'ask-admin') {
                      Navigator.of(context).pop(true);
                    } else if (href != null) {
                      launch(href);
                    }
                  },
                ),
              ),
              SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: 'Need more help? ',
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColor.gray2,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: 'Troubleshooting Guide',
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColor.accentBlue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launch(_kTroubleshootingGuideUrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UIMigration(
      child: Align(
        alignment: Alignment.center,
        child: Builder(
          builder: (context) => _buildDialog(context),
        ),
      ),
    );
  }
}
