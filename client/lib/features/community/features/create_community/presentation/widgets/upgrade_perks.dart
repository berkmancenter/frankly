import 'package:client/core/utils/extensions.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/upgrade_icon.dart';
import 'package:client/config/environment.dart';
import 'package:client/app.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

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
                    child: HeightConstrainedText(
                      'Upgrade for more',
                      style: AppTextStyle.headline3,
                    ),
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
                  launch(Environment.pricingUrl, targetIsSelf: false);
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
                ),
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
            child: HeightConstrainedText(
              perk,
              style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.gray2),
            ),
          ),
        ],
      );
}
