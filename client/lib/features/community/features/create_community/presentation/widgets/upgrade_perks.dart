import 'package:client/core/utils/extensions.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/upgrade_icon.dart';
import 'package:client/config/environment.dart';
import 'package:client/app.dart';
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
                for (final perk in _upgradePerks)
                  _buildUpgradePerk(context, perk),
              ].intersperse(
                SizedBox(height: 10),
              ),
              SizedBox(height: 20),
              ActionButton(
                textColor: context.theme.colorScheme.primary,
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
                  color: context.theme.colorScheme.primary,
                  textColor: context.theme.colorScheme.onPrimary,
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

  Widget _buildUpgradePerk(BuildContext context, String perk) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            color: context.theme.colorScheme.secondary,
            size: 12,
          ),
          SizedBox(
            width: 10,
          ),
          Flexible(
            child: HeightConstrainedText(
              perk,
              style: AppTextStyle.eyebrowSmall.copyWith(
                color: context.theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      );
}
