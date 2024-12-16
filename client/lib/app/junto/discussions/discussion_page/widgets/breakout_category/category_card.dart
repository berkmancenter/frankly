import 'package:flutter/cupertino.dart';
import 'package:junto/app/junto/discussions/discussion_page/breakout_room_definition/breakout_room_presenter.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:provider/src/provider.dart';
import 'package:quiver/strings.dart';

class CategoryCard extends StatefulWidget {
  final int position;

  const CategoryCard({
    Key? key,
    required this.position,
  }) : super(key: key);

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  late String _category;
  late BreakoutRoomPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _presenter = context.read<BreakoutRoomPresenter>();

    final breakoutCategory = _presenter.getCategory(widget.position);
    _category = breakoutCategory?.category ?? '';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<BreakoutRoomPresenter>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: JuntoTextField(
              labelText: 'Enter Category ${widget.position + 1}',
              maxLines: 1,
              maxLength: categoryCharactersMaxLength,
              initialValue: !isNullOrEmpty(_category) ? _category : null,
              onChanged: (value) =>
                  _presenter.updateCategoryData(category: value, position: widget.position),
            ),
          ),
          if (widget.position > 1) ...[
            SizedBox(width: 10),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: ActionButton(
                type: ActionButtonType.outline,
                sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                height: 50,
                minWidth: 44,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                onPressed: () async {
                  if (isEmpty(_category)) {
                    await alertOnError(
                        context, () => _presenter.deleteBreakoutRoomCategory(widget.position));
                  } else {
                    final delete = await ConfirmDialog(mainText: 'Are you sure you want to delete?')
                        .show(context: context);
                    if (delete) {
                      await alertOnError(
                          context, () => _presenter.deleteBreakoutRoomCategory(widget.position));
                    }
                  }
                },
                child: Icon(
                  CupertinoIcons.trash,
                  color: AppColor.white,
                  size: 20,
                ),
              ),
            ),
          ],
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
