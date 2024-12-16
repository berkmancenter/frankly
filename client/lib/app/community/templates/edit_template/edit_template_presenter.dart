import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/templates/template_page_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/services/firestore/firestore_database.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/dialogs.dart';
import 'package:data_models/firestore/community.dart';
import 'package:data_models/firestore/template.dart';
import 'package:provider/provider.dart';

import 'edit_template_contract.dart';
import 'edit_template_model.dart';

class EditTemplatePresenter {
  final EditTemplateView _view;
  final EditTemplateModel _model;
  final EditTemplatePresenterHelper _helper;
  final AppDrawerProvider _appDrawerProvider;
  final TemplatePageProvider _templatePageProvider;
  final CommunityProvider _communityProvider;
  final CommunityPermissionsProvider _communityPermissionsProvider;
  final FirestoreDatabase _firestoreDatabase;

  EditTemplatePresenter(
    BuildContext context,
    this._view,
    this._model, {
    EditTemplatePresenterHelper? editTemplatePresenterHelper,
    AppDrawerProvider? appDrawerProvider,
    TemplatePageProvider? templatePageProvider,
    CommunityProvider? communityProvider,
    CommunityPermissionsProvider? communityPermissionsProvider,
    FirestoreDatabase? firestoreDatabase,
  })  : _helper = editTemplatePresenterHelper ?? EditTemplatePresenterHelper(),
        _appDrawerProvider =
            appDrawerProvider ?? context.read<AppDrawerProvider>(),
        _templatePageProvider =
            templatePageProvider ?? context.read<TemplatePageProvider>(),
        _communityProvider =
            communityProvider ?? context.read<CommunityProvider>(),
        _communityPermissionsProvider = communityPermissionsProvider ??
            context.read<CommunityPermissionsProvider>(),
        _firestoreDatabase =
            firestoreDatabase ?? GetIt.instance<FirestoreDatabase>();

  void init() {
    _appDrawerProvider.setOnSaveChanges(onSaveChanges: saveChanges);

    final template = _templatePageProvider.template;
    if (template == null) {
      loggingService.log(
        'EditTemplatePresenter.init: Template is null',
        logType: LogType.error,
      );
      _view.closeDrawer();
      return;
    }

    _model.template = template;
    _model.initialTemplate = template;
    _view.updateView();
  }

  void updateTitle(String value) {
    _model.template = _model.template.copyWith(title: value.trim());
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateDescription(String value) {
    _model.template = _model.template.copyWith(description: value.trim());
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
    final validationError = _helper.areChangesValid(_model.template);
    if (validationError != null) {
      _view.showMessage(validationError, toastType: ToastType.failed);
      _appDrawerProvider.hideConfirmChangesDialogLayer();
      return;
    }

    final community = _communityProvider.community;
    final templateDocPath = getTemplateDocumentPath();

    // It might be little confusing here. We are not only updating template doc,
    // but also updating featured state.
    await Future.wait([
      if (_communityPermissionsProvider.canFeatureItems)
        _firestoreDatabase.updateFeaturedItem(
          communityId: community.id,
          documentId: _model.template.id,
          featured: Featured(
            documentPath: templateDocPath,
            featuredType: FeaturedType.template,
          ),
          isFeatured: _model.isFeatured ?? false,
        ),
      firestoreDatabase.updateTemplate(
        communityId: community.id,
        template: _model.template,
        keys: [
          Template.kFieldTemplateUrl,
          Template.kFieldTemplateTitle,
          Template.kFieldTemplateDescription,
          Template.kFieldTemplateImage,
        ],
      ),
    ]);

    _view.closeDrawer();
  }

  bool isFeatured(List<Featured>? featuredItems) {
    final templateDocPath = getTemplateDocumentPath();
    return featuredItems == null
        ? false
        : featuredItems.any((f) => f.documentPath == templateDocPath);
  }

  BehaviorSubjectWrapper<List<Featured>>? getFeaturedStream() {
    final communityId = _communityProvider.community.id;
    return _firestoreDatabase.getCommunityFeaturedItems(communityId);
  }

  String getTemplateDocumentPath() {
    return '/community/${_communityProvider.communityId}/templates/${_model.template.id}';
  }

  void updateImage(String url) {
    _model.template = _model.template.copyWith(image: url);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  Future<void> toggleTemplateStatus() async {
    final TemplateStatus templateStatus;
    switch (_model.template.status) {
      case TemplateStatus.active:
        templateStatus = TemplateStatus.removed;
        break;
      case TemplateStatus.removed:
        templateStatus = TemplateStatus.active;
        break;
    }

    await _firestoreDatabase.updateTemplate(
      communityId: _communityProvider.communityId,
      template: _model.template.copyWith(status: templateStatus),
      keys: [Template.kFieldTemplateStatus],
    );

    _view.closeDrawer();
  }

  bool wereChangesMade() {
    return _helper.wereChangesMade(_model);
  }

  void showConfirmChangesDialog() {
    _appDrawerProvider.showConfirmChangesDialogLayer();
  }

  String getTemplateButtonToggleText() {
    switch (_model.template.status) {
      case TemplateStatus.active:
        return 'Remove template';
      case TemplateStatus.removed:
        return 'Reactivate';
    }
  }

  Color getTemplateButtonToggleColor() {
    switch (_model.template.status) {
      case TemplateStatus.active:
        return AppColor.redLightMode;
      case TemplateStatus.removed:
        return Color(0xFFFFC138);
    }
  }

  bool canDeleteTemplate() {
    return _communityPermissionsProvider.canDeleteTemplate(_model.template);
  }

  Community getCommunity() {
    return _communityProvider.community;
  }
}

@visibleForTesting
class EditTemplatePresenterHelper {
  String? areChangesValid(Template template) {
    final title = template.title;
    if (title == null || title.isEmpty) {
      return 'Title cannot be empty';
    }

    return null;
  }

  bool wereChangesMade(EditTemplateModel model) {
    return model.template != model.initialTemplate ||
        model.isFeatured != model.initialFeatured;
  }
}
