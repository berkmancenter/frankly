import 'package:flutter/material.dart';
import 'package:junto/app/home/junto_tag_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/create_tag_widget.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:provider/provider.dart';

class CreateJuntoTags extends StatelessWidget {
  final String juntoId;

  const CreateJuntoTags(this.juntoId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateJuntoTagProvider>(
      create: (context) => CreateJuntoTagProvider(juntoId: juntoId)..initialize(),
      builder: (context, child) {
        final createJuntoTagProvider = Provider.of<CreateJuntoTagProvider>(context);
        return JuntoStreamBuilder(
          entryFrom: 'CreateJuntoDialog._buildAddTagsSection',
          stream: createJuntoTagProvider.juntoTagsStream,
          builder: (context, _) => CreateTagWidget(
            titleText: 'Add Tags',
            titleTextStyle: AppTextStyle.body.copyWith(fontSize: 24),
            showIcon: false,
            tags: Provider.of<CreateJuntoTagProvider>(context).tags,
            onAddTag: (title) => alertOnError(context, () => createJuntoTagProvider.addTag(title)),
            checkIsSelected: (tag) => createJuntoTagProvider.isSelected(tag),
            onTapTag: (tag) => createJuntoTagProvider.onTapTag(tag),
          ),
        );
      },
    );
  }
}
