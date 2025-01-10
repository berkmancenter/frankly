import 'package:client/core/utils/provider_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

const _kDefaultLogoImageUrl = Environment.logoUrl;

String get defaultInstantMeetingTemplateId => defaultInstantMeetingTemplate.id;
Template get defaultInstantMeetingTemplate => Template(
      id: 'instant-meeting-template',
      // This required field will be set before writing to firestore.
      collectionPath: '',
      creatorId: userService.currentUserId!,
      title: 'Instant Meeting',
      image: _kDefaultLogoImageUrl,
    );

const defaultTemplateId = 'misc';
Template get defaultTemplate => Template(
      id: defaultTemplateId,
      // This required field will be set before writing to firestore.
      collectionPath: '',
      creatorId: userService.currentUserId!,
      title: 'Miscellaneous',
      image: _kDefaultLogoImageUrl,
    );

class TemplateProvider with ChangeNotifier {
  final String communityId;
  final String templateId;

  TemplateProvider({
    required this.communityId,
    required this.templateId,
  });

  factory TemplateProvider.fromDocumentPath(String documentPath) {
    final eventMatch = RegExp('/?community/([^/]+)/templates/([^/]+)')
        .matchAsPrefix(documentPath);
    final communityId = eventMatch!.group(1)!;
    final templateId = eventMatch.group(2)!;

    return TemplateProvider(
      communityId: communityId,
      templateId: templateId,
    );
  }

  TemplateProvider copy() {
    return TemplateProvider(communityId: communityId, templateId: templateId)
      .._templateFuture = _templateFuture
      .._template = _template;
  }

  late Future<Template> _templateFuture;
  Template? _template;

  Future<Template> get templateFuture => _templateFuture;
  Template get template {
    final templateValue = _template;
    if (templateValue == null) {
      throw Exception('Template must be loaded before being accessed.');
    }

    return templateValue;
  }

  void initialize() {
    _templateFuture = _loadTemplate();
  }

  Future<Template> _loadTemplate() async {
    final template = await firestoreDatabase.communityTemplate(
      communityId: communityId,
      templateId: templateId,
    );

    _template = template;
    notifyListeners();
    return template;
  }

  static TemplateProvider watch(BuildContext context) =>
      Provider.of<TemplateProvider>(context);

  static TemplateProvider read(BuildContext context) =>
      Provider.of<TemplateProvider>(context, listen: false);

  static TemplateProvider? readOrNull(BuildContext context) => providerOrNull(
        () => Provider.of<TemplateProvider>(context, listen: false),
      );
}
