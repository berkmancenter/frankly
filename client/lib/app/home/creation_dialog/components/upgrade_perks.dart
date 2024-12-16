import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/upgrade_icon.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

class UpgradePerks extends StatelessWidget {
  static const List<String> _upgradePerks = [
    'Multiple admin',
    'Advanced branding',
    'Livestreams',
    'Hostless, automated events',
    'Pre/Post Programming',
    'Dedicated URL path',
    'Data dashboard and custom reporting',
    'Integrations & Webhooks',
  ];
  final void Function()? onUpgradeTap;

  const UpgradePerks({
    Key? key,
    this.onUpgradeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return kShowStripeFeatures
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UpgradeIcon(),
                  SizedBox(width: 10),
                  Flexible(
                    child: JuntoText('Upgrade for more', style: AppTextStyle.headline3),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ...[
                for (final perk in _upgradePerks) _buildUpgradePerk(perk),
              ].intersperse(
                SizedBox(height: 10),
              ),
              SizedBox(height: 20),
              ActionButton(
                textColor: AppColor.darkBlue,
                text: 'Explore plans',
                expand: true,
                type: ActionButtonType.outline,
                borderRadius: BorderRadius.circular(10),
                onPressed: () {
                  launch('https://frankly.org/pricing', targetIsSelf: false);
                },
              ),
              if (onUpgradeTap != null) ...[
                SizedBox(height: 20),
                ActionButton(
                  color: AppColor.darkBlue,
                  textColor: AppColor.brightGreen,
                  text: 'Upgrade',
                  expand: true,
                  borderRadius: BorderRadius.circular(10),
                  onPressed: onUpgradeTap,
                )
              ],
            ],
          )
        : SizedBox.shrink();
  }

  Widget _buildUpgradePerk(String perk) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: AppColor.darkGreen, size: 12),
          SizedBox(
            width: 10,
          ),
          Flexible(
            child: JuntoText(
              perk,
              style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.gray2),
            ),
          )
        ],
      );
}
