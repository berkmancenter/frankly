import 'package:flutter/material.dart';
import 'package:client/app/home/community_tag_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/create_tag_widget.dart';
import 'package:client/common_widgets/custom_stream_builder.dart';
import 'package:client/styles/app_styles.dart';
import 'package:provider/provider.dart';

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
            titleText: 'Add Tags',
            titleTextStyle: AppTextStyle.body.copyWith(fontSize: 24),
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
