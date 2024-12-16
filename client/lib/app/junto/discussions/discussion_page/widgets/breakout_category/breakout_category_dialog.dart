import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/breakout_category/breakout_category_presenter.dart';
import 'package:junto/common_widgets/create_dialog_ui_migration.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

/// Dialog that shows breakout categories
class BreakoutCategoryDialog extends StatelessWidget {
  const BreakoutCategoryDialog({Key? key}) : super(key: key);

  static Future<BreakoutCategory?> show({
    required DiscussionProvider discussionProvider,
  }) async {
    var category = await CreateDialogUiMigration<BreakoutCategory>(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => BreakoutCategoryPresenter(discussionProvider: discussionProvider),
        child: PointerInterceptor(child: BreakoutCategoryDialog()),
      ),
    ).show();

    return category;
  }

  @override
  Widget build(BuildContext context) {
    final _categoryPresenter = context.watch<BreakoutCategoryPresenter>();

    const spacerHeight = 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: spacerHeight),
        JuntoText(
          'Choose a category',
          style: AppTextStyle.headline1.copyWith(color: AppColor.white),
        ),
        SizedBox(height: 10),
        JuntoText(
          'Please pick the category to be placed into a room.',
          style: AppTextStyle.body.copyWith(color: AppColor.white),
        ),
        SizedBox(height: spacerHeight),
        for (var categoryData in _categoryPresenter.breakoutCategories)
          JuntoInkWell(
            onTap: () => Navigator.of(context).pop(categoryData),
            child: Container(
              width: 350,
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColor.white),
                  borderRadius: BorderRadius.circular(10)),
              child: JuntoText(
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
