import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/resources/create_junto_resource_presenter.dart';
import 'package:junto/app/junto/resources/junto_resources_presenter.dart';
import 'package:junto/app/junto/resources/url_field_widget.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/create_dialog_ui_migration.dart';
import 'package:junto/common_widgets/create_tag_widget.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/services/media_helper_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto_resource.dart';
import 'package:provider/provider.dart';

class CreateJuntoResourceModal extends StatelessWidget {
  static Future<void> show(BuildContext context, {JuntoResource? resource}) async {
    final isMobile = responsiveLayoutService.isMobile(context);
    JuntoProvider juntoProvider = context.read<JuntoProvider>();
    JuntoResourcesPresenter juntoResourcePresenter = context.read<JuntoResourcesPresenter>();

    await CreateDialogUiMigration(
      isFullscreenOnMobile: true,
      maxWidth: isMobile ? MediaQuery.of(context).size.width : 600.0,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => CreateJuntoResourcePresenter(
          resourcesPresenter: juntoResourcePresenter,
          juntoId: juntoProvider.juntoId,
          initialResource: resource,
        )..initialize(),
        child: CreateJuntoResourceModal(),
      ),
    ).show();
  }

  Widget _buildEditTitle(CreateJuntoResourcePresenter _createResourcePresenter) {
    return Row(
      children: [
        Expanded(
          child: JuntoTextField(
            maxLines: 3,
            initialValue: _createResourcePresenter.resource.title,
            onChanged: (value) => _createResourcePresenter.updateTitle(value),
            onEditingComplete: () => _createResourcePresenter.onTapEditTitle(),
          ),
        ),
        if (_createResourcePresenter.isEditingTitle) ...[
          SizedBox(width: 10),
          JuntoInkWell(
            boxShape: BoxShape.circle,
            onTap: () => _createResourcePresenter.onTapEditTitle(),
            child: CircleAvatar(
              backgroundColor: AppColor.darkBlue,
              child: Icon(
                Icons.check,
                color: AppColor.brightGreen,
              ),
            ),
          )
        ]
      ],
    );
  }

  Widget _buildResource(
      BuildContext context, CreateJuntoResourcePresenter _createResourcePresenter) {
    return Row(
      children: [
        JuntoInkWell(
          boxShape: BoxShape.circle,
          onTap: () => alertOnError(context, () async {
            var _initialUrl = _createResourcePresenter.resource.image;
            String? url = await GetIt.instance<MediaHelperService>().pickImageViaCloudinary();
            url = url?.trim();

            if (url != null && url.isNotEmpty && url != _initialUrl) {
              _createResourcePresenter.updateImage(url);
            }
          }),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              JuntoImage(
                _createResourcePresenter.resource.image,
                width: 80,
                height: 80,
              ),
              CircleAvatar(
                maxRadius: 10,
                backgroundColor: AppColor.white,
                child: Icon(
                  Icons.edit,
                  size: 15,
                  color: AppColor.darkBlue,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        if (_createResourcePresenter.showTitleField)
          Expanded(child: _buildEditTitle(_createResourcePresenter))
        else
          Expanded(
            child: Wrap(
              children: [
                JuntoText(
                  _createResourcePresenter.resource.title ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _createResourcePresenter.onTapEditTitle();
                  },
                  icon: Icon(
                    Icons.edit,
                    size: 18,
                  ),
                )
              ],
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    CreateJuntoResourcePresenter _createResourcePresenter =
        context.watch<CreateJuntoResourcePresenter>();

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          SizedBox(height: 50),
          UrlFieldWidget(
            onUrlChange: (text) => _createResourcePresenter.onUrlChange(text),
            onSubmit: () => _createResourcePresenter.urlLookup(),
            url: _createResourcePresenter.url,
            isLoading: _createResourcePresenter.isLoading,
            error: _createResourcePresenter.error,
            isEdited: _createResourcePresenter.url != _createResourcePresenter.lastLoadedUrl,
          ),
          if (_createResourcePresenter.resource.url != null &&
              !_createResourcePresenter.isLoading) ...[
            SizedBox(height: 20),
            _buildResource(context, _createResourcePresenter),
          ],
          SizedBox(height: 20),
          CreateTagWidget(
            tags: _createResourcePresenter.tags,
            onAddTag: (text) =>
                alertOnError(context, () => _createResourcePresenter.addTag(title: text)),
            checkIsSelected: (tag) => _createResourcePresenter.isSelected(tag),
            onTapTag: (tag) => alertOnError(context, () => _createResourcePresenter.selectTag(tag)),
          ),
          SizedBox(height: 20),
          Divider(
            thickness: 1,
            color: AppColor.gray4,
          ),
          SizedBox(height: 20),
          Container(
            alignment: Alignment.bottomRight,
            child: ActionButton(
              text: 'Post',
              onPressed: _createResourcePresenter.resource.url != null
                  ? () => alertOnError(context, () async {
                        await _createResourcePresenter.submit();
                        Navigator.pop(context);
                      })
                  : null,
              color: AppColor.darkBlue,
              textColor: AppColor.white,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
