import 'package:flutter/material.dart';
import 'package:client/app/community/templates/create_template/create_custom_template_page.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:client/services/services.dart';
import 'package:data_models/firestore/template.dart';

class CreateTemplatePresenter extends ChangeNotifier {
  final CommunityProvider communityProvider;
  final TemplateActionType templateActionType;
  final Template? template;
  final String templateId;
  late Template _template;

  CreateTemplatePresenter({
    required this.communityProvider,
    required this.templateActionType,
    this.template,
    required this.templateId,
  });

  Template get updatedTemplate => _template;

  void initialize() {
    switch (templateActionType) {
      // If user selected to update the template, template must be provided.
      case TemplateActionType.edit:
        _template = template!;
        break;
      // If user is not updating the template - assign it to template OR brand new one.
      case TemplateActionType.create:
      case TemplateActionType.duplicate:
        _template = template ??
            Template(
              id: templateId,
              collectionPath: firestoreDatabase
                  .templatesCollection(communityProvider.communityId)
                  .path,
              creatorId: userService.currentUserId!,
              isOfficial: false,
              image: defaultTemplateImage(randomString()),
              agendaItems:
                  defaultAgendaItems(communityProvider.community.id).toList(),
              eventSettings: communityProvider.eventSettings,
            );
        break;
    }
  }

  Future<Template> createTemplate() async {
    final template = await firestoreDatabase.createTemplate(
      communityId: communityProvider.community.id,
      template: _template,
    );
    var communityId = template.communityId;
    var templateId = template.id;
    analytics.logEvent(
      AnalyticsCompleteNewGuideEvent(
        communityId: communityId,
        guideId: templateId,
      ),
    );
    return template;
  }

  Future<void> updateTemplate() async {
    return await firestoreDatabase.updateTemplate(
      communityId: communityProvider.community.id,
      template: _template,
      keys: [
        Template.kFieldTemplateUrl,
        Template.kFieldTemplateTitle,
        Template.kFieldTemplateDescription,
        Template.kFieldTemplateImage,
      ],
    );
  }

  void updateTemplateImage(String imageUrl) {
    _template = _template.copyWith(image: imageUrl);
    notifyListeners();
  }

  void onChangeTitle(value) {
    _template = _template.copyWith(title: value);
    notifyListeners();
  }

  void onChangeDescription(value) {
    _template = _template.copyWith(description: value);
    notifyListeners();
  }

  String getPageTitle() {
    switch (templateActionType) {
      case TemplateActionType.create:
      case TemplateActionType.duplicate:
        return 'Create a template';
      case TemplateActionType.edit:
        return 'Update template';
    }
  }

  String getButtonTitle() {
    switch (templateActionType) {
      case TemplateActionType.create:
        return 'Create';
      case TemplateActionType.edit:
        return 'Update';
      case TemplateActionType.duplicate:
        return 'Duplicate';
    }
  }
}
