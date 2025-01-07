import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community_tag.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

class TemplatePageProvider with ChangeNotifier {
  final String communityId;
  final String templateId;

  late BehaviorSubjectWrapper<Template?> _templateStream;
  late StreamSubscription _templateSubscription;

  late BehaviorSubjectWrapper<List<Event>> _events;

  late BehaviorSubjectWrapper<List<CommunityTag>> _templateTagsStream;
  late StreamSubscription _templateTagListener;

  late Future<List<Template>> _templatesFuture;

  bool _isNewPrerequisite = false;
  bool _isHelpExpanded = false;
  TemplatePageProvider({required this.communityId, required this.templateId});

  Stream<Template?> get templateStream => _templateStream;

  Future<List<Template>> get templatesFuture => _templatesFuture;

  Template? get template => _templateStream.stream.valueOrNull;

  List<CommunityTag> get tags => _templateTagsStream.stream.valueOrNull ?? [];

  Stream<List<Event>> get events => _events.stream;

  bool get hasUpcomingEvents => (_events.value?.length ?? 0) > 0;

  bool get isNewPrerequisite => _isNewPrerequisite;

  bool get isHelpExpanded => _isHelpExpanded;

  void initialize() {
    _templateStream = wrapInBehaviorSubject(
      firestoreDatabase.templateStream(
        communityId: communityId,
        templateId: templateId,
      ),
    );
    _templateSubscription = _templateStream.listen((template) {
      notifyListeners();
    });
    _events = firestoreEventService.futurePublicEvents(
      communityId: communityId,
      templateId: templateId,
    );

    _templatesFuture = _loadAllTemplates();

    _templateTagsStream = wrapInBehaviorSubject(
      firestoreTagService.getCommunityTags(
        communityId: communityId,
        taggedItemId: templateId,
        taggedItemType: TaggedItemType.template,
      ),
    );
    _templateTagListener = _templateTagsStream.stream.listen((tags) {
      notifyListeners();
    });
  }

  Future<List<Template>> _loadAllTemplates() async {
    final allTemplates = await firestoreDatabase.allCommunityTemplates(
      communityId,
      includeRemovedTemplates: false,
    );

    return allTemplates;
  }

  set isNewPrerequisite(bool value) {
    _isNewPrerequisite = value;

    notifyListeners();
  }

  set isHelpExpanded(bool value) {
    _isHelpExpanded = value;
    notifyListeners();
  }

  static TemplatePageProvider? read(BuildContext context) {
    try {
      return Provider.of<TemplatePageProvider>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }

  static TemplatePageProvider? watch(BuildContext context) {
    try {
      return Provider.of<TemplatePageProvider>(context);
    } on ProviderNotFoundException {
      return null;
    }
  }

  @override
  void dispose() {
    _events.dispose();
    _templateStream.dispose();
    _templateSubscription.cancel();
    _templateTagListener.cancel();
    _templateTagsStream.dispose();
    super.dispose();
  }
}
