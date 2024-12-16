import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/resources/create_junto_resource_modal.dart';
import 'package:junto/app/junto/resources/junto_resources_presenter.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/empty_page_content.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_tag_builder.dart';
import 'package:junto/common_widgets/tag_filter_widget.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/provider.dart';

class JuntoResources extends StatelessWidget {
  const JuntoResources();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => JuntoResourcesPresenter(
        juntoProvider: context.read<JuntoProvider>(),
      )..initialize(),
      child: _JuntoResources._(),
    );
  }
}

class _JuntoResources extends StatefulWidget {
  const _JuntoResources._();

  @override
  State<_JuntoResources> createState() => _JuntoResourcesState();
}

class _JuntoResourcesState extends State<_JuntoResources> {
  JuntoResourcesPresenter get _resourcePresenter => context.watch<JuntoResourcesPresenter>();

  bool get canEditCommunity => Provider.of<CommunityPermissionsProvider>(context).canEditCommunity;

  bool get isMobile => responsiveLayoutService.isMobile(context);

  Widget _buildResources() {
    if (_resourcePresenter.allResources.isEmpty) {
      return _buildNoResource();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var resource in _resourcePresenter.filteredResources) ...[
          if (resource != _resourcePresenter.filteredResources.first) SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700),
              child: JuntoInkWell(
                onTap: () => launch(resource.url!),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(blurRadius: 5, color: AppColor.gray5),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      JuntoImage(
                        resource.image,
                        borderRadius: BorderRadius.circular(10),
                        width: 60,
                        height: 60,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            JuntoText(
                              resource.title ?? '',
                              style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray1),
                            ),
                            SizedBox(height: 4),
                            Wrap(
                              children: [
                                for (var tag in _resourcePresenter.getResourceTags(resource))
                                  JuntoTagBuilder(
                                    tagDefinitionId: tag.definitionId,
                                    builder: (_, isLoading, definition) =>
                                        isLoading || definition == null
                                            ? SizedBox.shrink()
                                            : Text(
                                                '#${definition.title}${_resourcePresenter.getResourceTags(resource).length > 1 ? ',' : ''} ',
                                              ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (canEditCommunity) ...[
                        IconButton(
                          onPressed: () =>
                              CreateJuntoResourceModal.show(context, resource: resource),
                          icon: Icon(Icons.edit),
                        ),
                        SizedBox(height: 10),
                        IconButton(
                          onPressed: () async {
                            final delete = await ConfirmDialog(
                              mainText: 'Are you sure you want to delete this resource?',
                            ).show();

                            if (!delete) return;

                            await alertOnError(
                                context,
                                () => firestoreJuntoResourceService.deleteJuntoResource(
                                      juntoId: JuntoProvider.read(context).juntoId,
                                      resourceId: resource.id,
                                    ));
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildNoResource() {
    return EmptyPageContent(
      type: EmptyPageType.resources,
      showContainer: false,
      onButtonPress: canEditCommunity ? () => CreateJuntoResourceModal.show(context) : null,
      isBackgroundPrimaryColor: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBody(
          child: JuntoStreamBuilder(
            entryFrom: 'JuntoResources._buildResources',
            stream: JuntoProvider.watch(context).resourcesStream,
            builder: (context, _) => JuntoStreamBuilder(
              entryFrom: 'JuntoResources._buildResources2',
              stream: _resourcePresenter.allResourceTagsStream,
              builder: (context, _) => Column(
                children: [
                  SizedBox(height: 30),
                  TagFilterWidget(
                    tags: _resourcePresenter.allTags,
                    isSelectedDefinitionId: (tagDefinitionId) =>
                        _resourcePresenter.selectedTagDefinitionIds.contains(tagDefinitionId),
                    onTapTag: (tagDefinitionId) =>
                        Provider.of<JuntoResourcesPresenter>(context, listen: false)
                            .selectTag(tagDefinitionId),
                  ),
                  SizedBox(height: 30),
                  _buildResources(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
