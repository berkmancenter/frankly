import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/config/environment.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/services.dart';
import 'package:client/core/localization/localization_helper.dart';


const _kTroubleshootingGuideUrl = Environment.troubleshootingGuideUrl;

final l10n = appLocalizationService.getLocalization();

class NeedHelpDialog extends StatelessWidget {
  final bool showContactAdmin;

  const NeedHelpDialog({this.showContactAdmin = false});

  Future<bool> show() async {
    return (await showCustomDialog(builder: (_) => this)) ?? false;
  }

  Widget _buildDialog(BuildContext context) {

    final l10n = appLocalizationService.getLocalization();
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
                    color: context.theme.colorScheme.primary,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              Flexible(
                child: Markdown(
                  data: showContactAdmin
                      ? l10n.needHelpMarkdownWithContactAdmin
                      : l10n.needHelpMarkdown,
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
                  text: l10n.needMoreHelp,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: l10n.troubleshootingGuide,
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.theme.colorScheme.primary,
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
    return Align(
      alignment: Alignment.center,
      child: Builder(
        builder: (context) => _buildDialog(context),
      ),
    );
  }
}
