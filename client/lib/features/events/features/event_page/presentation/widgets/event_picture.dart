import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/events/features/event_page/data/providers/template_provider.dart';
import 'package:client/core/widgets/editable_image.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';

class EventOrTemplatePicture extends HookWidget {
  final Event? event;
  final Template? template;
  final Function(String)? onEdit;
  final double? height;

  const EventOrTemplatePicture({
    Key? key,
    this.event,
    this.template,
    this.onEdit,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localEvent = event;
    final localTemplate = template;
    final eventImage = localEvent?.image;
    final templateImage = localTemplate?.image;

    final Future<String?> imageFuture = useMemoized(() async {
      if (eventImage != null && eventImage.isNotEmpty) {
        return eventImage;
      } else if (templateImage != null && templateImage.isNotEmpty) {
        return templateImage;
      } else if (localEvent?.templateId == defaultInstantMeetingTemplateId) {
        return defaultInstantMeetingTemplate.image!;
      } else if (localEvent != null) {
        final templateData = await firestoreDatabase.communityTemplate(
          communityId: localEvent.communityId,
          templateId: localEvent.templateId,
        );
        return templateData.image;
      }
      return null;
    });

    return SizedBox(
      width: height,
      height: height,
      child: Container(
        alignment: Alignment.center,
        child: FutureBuilder<String?>(
          future: imageFuture,
          builder: (_, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? CustomLoadingIndicator()
                  : EditableImage(
                      initialUrl: snapshot.data ?? '',
                      allowEdit: onEdit != null,
                      onImageSelect: onEdit,
                      borderRadius: BorderRadius.circular(20),
                      child: ProxiedImage(
                        snapshot.data ?? '',
                        height: height,
                        borderRadius: BorderRadius.circular(20),
                        width: height,
                      ),
                    ),
        ),
      ),
    );
  }
}
