import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/config/environment.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client/core/localization/localization_helper.dart';

const _kTroubleshootingGuideUrl = Environment.troubleshootingGuideUrl;

class TroubleshootIssuesButton extends StatelessWidget {
  const TroubleshootIssuesButton({
    this.linkColor,
    Key? key,
  }) : super(key: key);

  final Color? linkColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeightConstrainedText(context.l10n.avIssues),
        SizedBox(width: 8),
        CustomInkWell(
          onTap: () => launchUrl(Uri.parse(_kTroubleshootingGuideUrl)),
          child: HeightConstrainedText(
            context.l10n.troubleshoot,
            style: AppTextStyle.body.copyWith(
              decoration: TextDecoration.underline,
              color: linkColor ?? context.theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
