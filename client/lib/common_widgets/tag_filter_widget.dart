import 'package:flutter/material.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/proxied_image.dart';
import 'package:client/common_widgets/custom_ink_well.dart';
import 'package:client/common_widgets/community_tag_builder.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:data_models/community/community_tag.dart';

class TagFilterWidget extends StatelessWidget {
  /// Tags to choose from
  final List<CommunityTag> tags;

  /// function callback that checks if tag is selected
  final bool Function(String) isSelectedDefinitionId;

  /// function callback that returns tapped tag
  final void Function(String)? onTapTag;

  const TagFilterWidget({
    Key? key,
    required this.tags,
    required this.isSelectedDefinitionId,
    this.onTapTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          if (tags.isNotEmpty) ...[
            ProxiedImage(
              null,
              asset: AppAsset.kFliterIcon,
            ),
            SizedBox(width: 10),
            Text('filter'),
          ],
          SizedBox(width: 20),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                for (final tagDefinitionId
                    in tags.map((t) => t.definitionId).toSet())
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    child: CustomInkWell(
                      onTap: () =>
                          onTapTag != null ? onTapTag!(tagDefinitionId) : null,
                      borderRadius: BorderRadius.circular(20),
                      child: CommunityTagBuilder(
                        tagDefinitionId: tagDefinitionId,
                        builder: (_, isLoading, definition) {
                          if (isLoading) return const CustomLoadingIndicator();
                          if (definition == null) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isSelectedDefinitionId(tagDefinitionId)
                                  ? AppColor.darkBlue
                                  : AppColor.white,
                            ),
                            child: Center(
                              child: Text(
                                '#${definition.title}',
                                style: AppTextStyle.body.copyWith(
                                  color: isSelectedDefinitionId(tagDefinitionId)
                                      ? AppColor.white
                                      : AppColor.darkBlue,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
