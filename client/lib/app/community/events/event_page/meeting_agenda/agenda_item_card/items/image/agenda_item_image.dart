import 'package:flutter/material.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_contract.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_data.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_model.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_presenter.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/action_button.dart';
import 'package:client/common_widgets/proxied_image.dart';
import 'package:client/common_widgets/custom_text_field.dart';
import 'package:client/common_widgets/ui_migration.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';

class AgendaItemImage extends StatefulWidget {
  final bool isEditMode;
  final AgendaItemImageData agendaItemImageData;
  final void Function(AgendaItemImageData) onChanged;

  const AgendaItemImage({
    Key? key,
    required this.isEditMode,
    required this.agendaItemImageData,
    required this.onChanged,
  }) : super(key: key);

  @override
  _AgendaItemImageState createState() => _AgendaItemImageState();
}

class _AgendaItemImageState extends State<AgendaItemImage>
    implements AgendaItemImageView {
  late final TextEditingController _textEditingController;

  late AgendaItemImageModel _model;
  late AgendaItemImagePresenter _presenter;

  void _init() {
    _model = AgendaItemImageModel(
      widget.isEditMode,
      widget.agendaItemImageData,
      widget.onChanged,
    );
    _presenter = AgendaItemImagePresenter(context, this, _model);

    final String url = _model.agendaItemImageData.url;
    _updateTextInController(url);
  }

  void _updateTextInController(String text) {
    _textEditingController.text = text;
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: widget.agendaItemImageData.url);

    _init();
  }

  @override
  void didUpdateWidget(AgendaItemImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isEditMode != widget.isEditMode ||
        oldWidget.agendaItemImageData != widget.agendaItemImageData) {
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    const kImageHeight = 400.0;
    final imageUrl = _presenter.getImageUrl();
    final isEditMode = _model.isEditMode;
    final isImageUploaded = _presenter.isValidImage();

    if (isEditMode) {
      return UIMigration(
        whiteBackground: true,
        child: Column(
          children: [
            CustomTextField(
              initialValue: _model.agendaItemImageData.title,
              labelText: 'Title',
              hintText: 'Enter Image title',
              maxLength: agendaTitleCharactersLength,
              counterStyle: AppTextStyle.bodySmall.copyWith(
                color: AppColor.darkBlue,
              ),
              maxLines: 1,
              onChanged: (value) => _presenter.updateImageTitle(value),
            ),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: AppColor.gray5,
                  height: kImageHeight,
                  child: isImageUploaded ? ProxiedImage(imageUrl) : null,
                ),
                if (!isImageUploaded) _buildUploadImage('Upload Image'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _textEditingController,
                    labelText: 'Image URL',
                    maxLines: null,
                    onChanged: (value) => _presenter.updateImageUrl(value),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (isImageUploaded) _buildUploadImage('Upload New Image'),
          ],
        ),
      );
    } else {
      return UIMigration(
        whiteBackground: true,
        child: Column(
          children: [
            if (imageUrl.isEmpty)
              HeightConstrainedText('(Image URL is not set.)')
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ProxiedImage(imageUrl, height: kImageHeight),
              ),
          ],
        ),
      );
    }
  }

  @override
  void updateView() {
    setState(() {});
  }

  Widget _buildUploadImage(String text) {
    return ActionButton(
      color: AppColor.darkBlue,
      textColor: AppColor.brightGreen,
      text: text,
      onPressed: () async {
        await alertOnError(context, () async {
          final String? url = await _presenter.pickImage();

          if (url != null) {
            _updateTextInController(url);
            _presenter.updateImageUrl(url);
          }
        });
      },
    );
  }
}
