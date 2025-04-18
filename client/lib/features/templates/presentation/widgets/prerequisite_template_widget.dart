import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/template_provider.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

/// This is a Widget that displays event Prerequisite template
class PrerequisiteTemplateWidget extends StatelessWidget {
  final String prerequisiteTemplateId;
  final String communityId;

  const PrerequisiteTemplateWidget({
    Key? key,
    required this.prerequisiteTemplateId,
    required this.communityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeightConstrainedText(
          'Attend this first:',
          style: AppTextStyle.headline4,
        ),
        SizedBox(height: 10),
        ChangeNotifierProvider<TemplateProvider>(
          key: Key(prerequisiteTemplateId),
          create: (_) => TemplateProvider(
            communityId: communityId,
            templateId: prerequisiteTemplateId,
          )..initialize(),
          builder: (context, __) {
            return CustomStreamBuilder<Template>(
              entryFrom: '_PrerequisiteTemplateWidget.build',
              stream: Provider.of<TemplateProvider>(context)
                  .templateFuture
                  .asStream(),
              builder: (_, template) => CustomInkWell(
                onTap: () => routerDelegate.beamTo(
                  CommunityPageRoutes(
                    communityDisplayId: communityId,
                  ).templatePage(templateId: prerequisiteTemplateId),
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: context.theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      ProxiedImage(
                        template?.image,
                        width: 70,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeightConstrainedText(
                              template?.title ?? '',
                              style: AppTextStyle.headline4,
                            ),
                            HeightConstrainedText(
                              'Find an event with this template.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
