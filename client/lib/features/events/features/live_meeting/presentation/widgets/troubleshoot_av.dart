import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/config/environment.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:url_launcher/url_launcher.dart';

const _kTroubleshootingGuideUrl = Environment.troubleshootingGuideUrl;

class TroubleshootIssuesButton extends StatelessWidget {
  final Color linkColor;

  const TroubleshootIssuesButton(
      {this.linkColor = context.theme.colorScheme.primary, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeightConstrainedText('A/V issues?'),
        SizedBox(width: 8),
        CustomInkWell(
          onTap: () => launchUrl(Uri.parse(_kTroubleshootingGuideUrl)),
          child: HeightConstrainedText(
            'Troubleshoot',
            style: AppTextStyle.body.copyWith(
              decoration: TextDecoration.underline,
              color: linkColor,
            ),
          ),
        ),
      ],
    );
  }
}
