import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/templates/topic_page_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/firestore/firestore_database.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

import 'edit_topic_contract.dart';
import 'edit_topic_model.dart';

class EditTopicPresenter {
  final EditTopicView _view;
  final EditTopicModel _model;
  final EditTopicPresenterHelper _helper;
  final AppDrawerProvider _appDrawerProvider;
  final TopicPageProvider _topicPageProvider;
  final JuntoProvider _juntoProvider;
  final CommunityPermissionsProvider _communityPermissionsProvider;
  final FirestoreDatabase _firestoreDatabase;

  EditTopicPresenter(
    BuildContext context,
    this._view,
    this._model, {
    EditTopicPresenterHelper? editTopicPresenterHelper,
    AppDrawerProvider? appDrawerProvider,
    TopicPageProvider? topicPageProvider,
    JuntoProvider? juntoProvider,
    CommunityPermissionsProvider? communityPermissionsProvider,
    FirestoreDatabase? firestoreDatabase,
  })  : _helper = editTopicPresenterHelper ?? EditTopicPresenterHelper(),
        _appDrawerProvider = appDrawerProvider ?? context.read<AppDrawerProvider>(),
        _topicPageProvider = topicPageProvider ?? context.read<TopicPageProvider>(),
        _juntoProvider = juntoProvider ?? context.read<JuntoProvider>(),
        _communityPermissionsProvider =
            communityPermissionsProvider ?? context.read<CommunityPermissionsProvider>(),
        _firestoreDatabase = firestoreDatabase ?? GetIt.instance<FirestoreDatabase>();

  void init() {
    _appDrawerProvider.setOnSaveChanges(onSaveChanges: saveChanges);

    final topic = _topicPageProvider.topic;
    if (topic == null) {
      loggingService.log('EditTopicPresenter.init: Topic is null', logType: LogType.error);
      _view.closeDrawer();
      return;
    }

    _model.topic = topic;
    _model.initialTopic = topic;
    _view.updateView();
  }

  void updateTitle(String value) {
    _model.topic = _model.topic.copyWith(title: value.trim());
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateDescription(String value) {
    _model.topic = _model.topic.copyWith(description: value.trim());
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateIsFeatured(bool value) {
    _model.isFeatured = value;
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  bool get showFeatureToggle => _communityPermissionsProvider.canEditCommunity;

  Future<void> saveChanges() async {
    final validationError = _helper.areChangesValid(_model.topic);
    if (validationError != null) {
      _view.showMessage(validationError, toastType: ToastType.failed);
      _appDrawerProvider.hideConfirmChangesDialogLayer();
      return;
    }

    final junto = _juntoProvider.junto;
    final topicDocPath = getTopicDocumentPath();

    // It might be little confusing here. We are not only updating topic doc,
    // but also updating featured state.
    await Future.wait([
      if (_communityPermissionsProvider.canFeatureItems)
        _firestoreDatabase.updateFeaturedItem(
          juntoId: junto.id,
          documentId: _model.topic.id,
          featured: Featured(
            documentPath: topicDocPath,
            featuredType: FeaturedType.topic,
          ),
          isFeatured: _model.isFeatured ?? false,
        ),
      firestoreDatabase.updateTopic(
        juntoId: junto.id,
        topic: _model.topic,
        keys: [
          Topic.kFieldTopicUrl,
          Topic.kFieldTopicTitle,
          Topic.kFieldTopicDescription,
          Topic.kFieldTopicImage,
        ],
      ),
    ]);

    _view.closeDrawer();
  }

  bool isFeatured(List<Featured>? featuredItems) {
    final topicDocPath = getTopicDocumentPath();
    return featuredItems == null ? false : featuredItems.any((f) => f.documentPath == topicDocPath);
  }

  BehaviorSubjectWrapper<List<Featured>>? getFeaturedStream() {
    final juntoId = _juntoProvider.junto.id;
    return _firestoreDatabase.getJuntoFeaturedItems(juntoId);
  }

  String getTopicDocumentPath() {
    return '/junto/${_juntoProvider.juntoId}/topics/${_model.topic.id}';
  }

  void updateImage(String url) {
    _model.topic = _model.topic.copyWith(image: url);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  Future<void> toggleTopicStatus() async {
    final TopicStatus topicStatus;
    switch (_model.topic.status) {
      case TopicStatus.active:
        topicStatus = TopicStatus.removed;
        break;
      case TopicStatus.removed:
        topicStatus = TopicStatus.active;
        break;
    }

    await _firestoreDatabase.updateTopic(
      juntoId: _juntoProvider.juntoId,
      topic: _model.topic.copyWith(status: topicStatus),
      keys: [Topic.kFieldTopicStatus],
    );

    _view.closeDrawer();
  }

  bool wereChangesMade() {
    return _helper.wereChangesMade(_model);
  }

  void showConfirmChangesDialog() {
    _appDrawerProvider.showConfirmChangesDialogLayer();
  }

  String getTopicButtonToggleText() {
    switch (_model.topic.status) {
      case TopicStatus.active:
        return 'Remove template';
      case TopicStatus.removed:
        return 'Reactivate';
    }
  }

  Color getTopicButtonToggleColor() {
    switch (_model.topic.status) {
      case TopicStatus.active:
        return AppColor.redLightMode;
      case TopicStatus.removed:
        return Color(0xFFFFC138);
    }
  }

  bool canDeleteTopic() {
    return _communityPermissionsProvider.canDeleteTopic(_model.topic);
  }

  Junto getJunto() {
    return _juntoProvider.junto;
  }
}

@visibleForTesting
class EditTopicPresenterHelper {
  String? areChangesValid(Topic topic) {
    final title = topic.title;
    if (title == null || title.isEmpty) {
      return 'Title cannot be empty';
    }

    return null;
  }

  bool wereChangesMade(EditTopicModel model) {
    return model.topic != model.initialTopic || model.isFeatured != model.initialFeatured;
  }
}
