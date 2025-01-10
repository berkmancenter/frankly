import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/breakout_category_presenter.dart';
import 'package:client/core/widgets/create_dialog_ui_migration.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

/// Dialog that shows breakout categories
class BreakoutCategoryDialog extends StatelessWidget {
  const BreakoutCategoryDialog({Key? key}) : super(key: key);

  static Future<BreakoutCategory?> show({
    required EventProvider eventProvider,
  }) async {
    var category = await CreateDialogUiMigration<BreakoutCategory>(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => BreakoutCategoryPresenter(eventProvider: eventProvider),
        child: PointerInterceptor(child: BreakoutCategoryDialog()),
      ),
    ).show();

    return category;
  }

  @override
  Widget build(BuildContext context) {
    final categoryPresenter = context.watch<BreakoutCategoryPresenter>();

    const spacerHeight = 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: spacerHeight),
        HeightConstrainedText(
          'Choose a category',
          style: AppTextStyle.headline1.copyWith(color: AppColor.white),
        ),
        SizedBox(height: 10),
        HeightConstrainedText(
          'Please pick the category to be placed into a room.',
          style: AppTextStyle.body.copyWith(color: AppColor.white),
        ),
        SizedBox(height: spacerHeight),
        for (var categoryData in categoryPresenter.breakoutCategories)
          CustomInkWell(
            onTap: () => Navigator.of(context).pop(categoryData),
            child: Container(
              width: 350,
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: HeightConstrainedText(
                categoryData.category,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium.copyWith(color: AppColor.white),
              ),
            ),
          ),
        SizedBox(height: spacerHeight),
      ],
    );
  }
}
