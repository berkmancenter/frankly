import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/data/providers/community_tag_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/community/presentation/widgets/create_tag_widget.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';
class CreateCommunityTags extends StatelessWidget {
  final String communityId;

  const CreateCommunityTags(this.communityId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateCommunityTagProvider>(
      create: (context) =>
          CreateCommunityTagProvider(communityId: communityId)..initialize(),
      builder: (context, child) {
        final createCommunityTagProvider =
            Provider.of<CreateCommunityTagProvider>(context);
        return CustomStreamBuilder(
          entryFrom: 'CreateCommunityDialog._buildAddTagsSection',
          stream: createCommunityTagProvider.communityTagsStream,
          builder: (context, _) => CreateTagWidget(
            titleText: context.l10n.addTags,
            showIcon: false,
            tags: Provider.of<CreateCommunityTagProvider>(context).tags,
            onAddTag: (title) => alertOnError(
              context,
              () => createCommunityTagProvider.addTag(title),
            ),
            checkIsSelected: (tag) =>
                createCommunityTagProvider.isSelected(tag),
            onTapTag: (tag) => createCommunityTagProvider.onTapTag(tag),
          ),
        );
      },
    );
  }
}
