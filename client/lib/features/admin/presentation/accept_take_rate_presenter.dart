import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/create_dialog_ui_migration.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:flutter/material.dart';

class AcceptTakeRatePresenter {
  static Future<bool> showAcceptTakeRateDialog(
    BuildContext context,
    CommunityProvider communityProvider,
  ) async {
    final community = communityProvider.community;
    final capabilities =
        await cloudFunctionsCommunityService.getCommunityCapabilities(
      GetCommunityCapabilitiesRequest(communityId: community.id),
    );

    final bool? isAccepted = await CreateDialogUiMigration<bool?>(
      builder: (context) {
        final takeRate = capabilities.takeRate!;

        return Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment terms',
                style: AppTextStyle.headline3
                    .copyWith(color: context.theme.colorScheme.primary),
              ),
              SizedBox(height: 10),
              Text(
                'On our free plan, any end user payments will incur a ${takeRate * 100}% commission. Upgrade your plan for a lower rate.',
                style: AppTextStyle.body.copyWith(color: AppColor.gray1),
              ),
              SizedBox(height: 20),
              ActionButton(
                text: 'Agree and continue',
                color: context.theme.colorScheme.primary,
                textColor: AppColor.brightGreen,
                expand: true,
                onPressed: () => Navigator.pop(context, true),
              ),
              SizedBox(height: 5),
              ActionButton(
                text: 'Not now',
                color: Colors.transparent,
                textColor: context.theme.colorScheme.primary,
                expand: true,
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        );
      },
    ).show();

    return isAccepted ?? false;
  }
}
