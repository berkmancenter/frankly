import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:url_launcher/url_launcher.dart';

const _kTroubleshootingGuideUrl =
    'https://rebootingsocialmedia.notion.site/Troubleshooting-c6f922b816a742a9bba4bf000e84565d';

class TroubleshootIssuesButton extends StatelessWidget {
  final Color linkColor;

  const TroubleshootIssuesButton({this.linkColor = AppColor.darkBlue, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        JuntoText('A/V issues?'),
        SizedBox(width: 8),
        JuntoInkWell(
          onTap: () => launchUrl(Uri.parse(_kTroubleshootingGuideUrl)),
          child: JuntoText(
            'Troubleshoot',
            style: AppTextStyle.body.copyWith(
              decoration: TextDecoration.underline,
              color: linkColor,
            ),
          ),
        )
      ],
    );
  }
}
