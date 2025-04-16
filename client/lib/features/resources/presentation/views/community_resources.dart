import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/resources/presentation/views/create_community_resource_modal.dart';
import 'package:client/features/resources/presentation/community_resources_presenter.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/community/presentation/widgets/community_tag_builder.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/tag_filter_widget.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

class CommunityResources extends StatelessWidget {
  const CommunityResources();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CommunityResourcesPresenter(
        communityProvider: context.read<CommunityProvider>(),
      )..initialize(),
      child: _CommunityResources._(),
    );
  }
}

class _CommunityResources extends StatefulWidget {
  const _CommunityResources._();

  @override
  State<_CommunityResources> createState() => _CommunityResourcesState();
}

class _CommunityResourcesState extends State<_CommunityResources> {
  CommunityResourcesPresenter get _resourcePresenter =>
      context.watch<CommunityResourcesPresenter>();

  bool get canEditCommunity =>
      Provider.of<CommunityPermissionsProvider>(context).canEditCommunity;

  bool get isMobile => responsiveLayoutService.isMobile(context);

  Widget _buildResources() {
    if (_resourcePresenter.allResources.isEmpty) {
      return _buildNoResource();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var resource in _resourcePresenter.filteredResources) ...[
          if (resource != _resourcePresenter.filteredResources.first)
            SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700),
              child: CustomInkWell(
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
                      ProxiedImage(
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
                            HeightConstrainedText(
                              resource.title ?? '',
                              style: AppTextStyle.bodyMedium
                                  .copyWith(color: AppColor.gray1),
                            ),
                            SizedBox(height: 4),
                            Wrap(
                              children: [
                                for (var tag in _resourcePresenter
                                    .getResourceTags(resource))
                                  CommunityTagBuilder(
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
                          onPressed: () => CreateCommunityResourceModal.show(
                            context,
                            resource: resource,
                          ),
                          icon: Icon(Icons.edit),
                        ),
                        SizedBox(height: 10),
                        IconButton(
                          onPressed: () async {
                            final delete = await ConfirmDialog(
                              mainText:
                                  'Are you sure you want to delete this resource?',
                            ).show();

                            if (!delete) return;

                            await alertOnError(
                              context,
                              () => firestoreCommunityResourceService
                                  .deleteCommunityResource(
                                communityId:
                                    CommunityProvider.read(context).communityId,
                                resourceId: resource.id,
                              ),
                            );
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
        ],
      ],
    );
  }

  Widget _buildNoResource() {
    return EmptyPageContent(
      type: EmptyPageType.resources,
      showContainer: false,
      onButtonPress: canEditCommunity
          ? () => CreateCommunityResourceModal.show(context)
          : null,
      isBackgroundPrimaryColor: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBody(
          child: CustomStreamBuilder(
            entryFrom: 'CommunityResources._buildResources',
            stream: CommunityProvider.watch(context).resourcesStream,
            builder: (context, _) => CustomStreamBuilder(
              entryFrom: 'CommunityResources._buildResources2',
              stream: _resourcePresenter.allResourceTagsStream,
              builder: (context, _) => Column(
                children: [
                  SizedBox(height: 30),
                  TagFilterWidget(
                    tags: _resourcePresenter.allTags,
                    isSelectedDefinitionId: (tagDefinitionId) =>
                        _resourcePresenter.selectedTagDefinitionIds
                            .contains(tagDefinitionId),
                    onTapTag: (tagDefinitionId) =>
                        Provider.of<CommunityResourcesPresenter>(
                      context,
                      listen: false,
                    ).selectTag(tagDefinitionId),
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
