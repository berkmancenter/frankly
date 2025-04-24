import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/resources/presentation/create_community_resource_presenter.dart';
import 'package:client/features/resources/presentation/community_resources_presenter.dart';
import 'package:client/features/resources/presentation/widgets/url_field_widget.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/create_dialog_ui_migration.dart';
import 'package:client/features/community/presentation/widgets/create_tag_widget.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/resources/community_resource.dart';
import 'package:provider/provider.dart';

class CreateCommunityResourceModal extends StatelessWidget {
  static Future<void> show(
    BuildContext context, {
    CommunityResource? resource,
  }) async {
    final isMobile = responsiveLayoutService.isMobile(context);
    CommunityProvider communityProvider = context.read<CommunityProvider>();
    CommunityResourcesPresenter communityResourcePresenter =
        context.read<CommunityResourcesPresenter>();

    await CreateDialogUiMigration(
      isFullscreenOnMobile: true,
      maxWidth: isMobile ? MediaQuery.of(context).size.width : 600.0,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => CreateCommunityResourcePresenter(
          resourcesPresenter: communityResourcePresenter,
          communityId: communityProvider.communityId,
          initialResource: resource,
        )..initialize(),
        child: CreateCommunityResourceModal(),
      ),
    ).show();
  }

  Widget _buildResource(
    BuildContext context,
    CreateCommunityResourcePresenter createResourcePresenter,
  ) {
    return Row(
      children: [
        CustomInkWell(
          boxShape: BoxShape.circle,
          onTap: () => alertOnError(context, () async {
            var initialUrl = createResourcePresenter.resource.image;
            String? url = await GetIt.instance<MediaHelperService>()
                .pickImageViaCloudinary();
            url = url?.trim();

            if (url != null && url.isNotEmpty && url != initialUrl) {
              createResourcePresenter.updateImage(url);
            }
          }),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              ProxiedImage(
                createResourcePresenter.resource.image,
                width: 80,
                height: 80,
              ),
              CircleAvatar(
                maxRadius: 10,
                backgroundColor:
                    context.theme.colorScheme.surfaceContainerLowest,
                child: Icon(
                  Icons.edit,
                  size: 15,
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        if (createResourcePresenter.showTitleField)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    maxLines: 3,
                    initialValue: createResourcePresenter.resource.title,
                    onChanged: (value) =>
                        createResourcePresenter.updateTitle(value),
                    onEditingComplete: () =>
                        createResourcePresenter.onTapEditTitle(),
                  ),
                ),
                if (createResourcePresenter.isEditingTitle) ...[
                  SizedBox(width: 10),
                  CustomInkWell(
                    boxShape: BoxShape.circle,
                    onTap: () => createResourcePresenter.onTapEditTitle(),
                    child: CircleAvatar(
                      backgroundColor: context.theme.colorScheme.primary,
                      child: Icon(
                        Icons.check,
                        color: context.theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          Expanded(
            child: Wrap(
              children: [
                HeightConstrainedText(
                  createResourcePresenter.resource.title ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    createResourcePresenter.onTapEditTitle();
                  },
                  icon: Icon(
                    Icons.edit,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    CreateCommunityResourcePresenter createResourcePresenter =
        context.watch<CreateCommunityResourcePresenter>();

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          SizedBox(height: 50),
          UrlFieldWidget(
            onUrlChange: (text) => createResourcePresenter.onUrlChange(text),
            onSubmit: () => createResourcePresenter.urlLookup(),
            url: createResourcePresenter.url,
            isLoading: createResourcePresenter.isLoading,
            error: createResourcePresenter.error,
            isEdited: createResourcePresenter.url !=
                createResourcePresenter.lastLoadedUrl,
          ),
          if (createResourcePresenter.resource.url != null &&
              !createResourcePresenter.isLoading) ...[
            SizedBox(height: 20),
            _buildResource(context, createResourcePresenter),
          ],
          SizedBox(height: 20),
          CreateTagWidget(
            tags: createResourcePresenter.tags,
            onAddTag: (text) => alertOnError(
              context,
              () => createResourcePresenter.addTag(title: text),
            ),
            checkIsSelected: (tag) => createResourcePresenter.isSelected(tag),
            onTapTag: (tag) => alertOnError(
              context,
              () => createResourcePresenter.selectTag(tag),
            ),
          ),
          SizedBox(height: 20),
          Divider(
            thickness: 1,
            color: context.theme.colorScheme.onPrimaryContainer,
          ),
          SizedBox(height: 20),
          Container(
            alignment: Alignment.bottomRight,
            child: ActionButton(
              text: 'Post',
              onPressed: createResourcePresenter.resource.url != null
                  ? () => alertOnError(context, () async {
                        await createResourcePresenter.submit();
                        Navigator.pop(context);
                      })
                  : null,
              color: context.theme.colorScheme.primary,
              textColor: context.theme.colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
