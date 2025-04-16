import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

class AdditionalTemplatesCard extends StatelessWidget {
  const AdditionalTemplatesCard({
    Key? key,
    required this.context,
    required this.templates,
    required this.numShown,
  }) : super(key: key);

  final BuildContext context;
  final List<Template> templates;
  final int numShown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: CustomInkWell(
        onTap: () => routerDelegate.beamTo(
          CommunityPageRoutes(
            communityDisplayId:
                Provider.of<CommunityProvider>(context, listen: false)
                    .displayId,
          ).browseTemplatesPage,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              clipBehavior: Clip.hardEdge,
              child: ProxiedImage(templates[numShown].image),
            ),
            Container(
              width: 90,
              height: 90,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0x44000000),
              ),
            ),
            HeightConstrainedText(
              '+${templates.length - numShown}',
              style: AppTextStyle.body
                  .copyWith(color: AppColor.white, fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class TemplateCard extends StatelessWidget {
  const TemplateCard({
    Key? key,
    required this.context,
    required this.template,
  }) : super(key: key);

  final BuildContext context;
  final Template template;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => routerDelegate.beamTo(
              CommunityPageRoutes(
                communityDisplayId:
                    Provider.of<CommunityProvider>(context, listen: false)
                        .displayId,
              ).templatePage(templateId: template.id),
            ),
            child: Tooltip(
              message: template.title ?? 'Event Template',
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                clipBehavior: Clip.hardEdge,
                child: ProxiedImage(template.image, height: 90, width: 90),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: HeightConstrainedText(
              template.title ?? '',
              style: AppTextStyle.body
                  .copyWith(fontSize: 14, color: AppColor.gray1),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
