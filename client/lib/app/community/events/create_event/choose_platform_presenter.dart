import 'package:flutter/material.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/events/platform_data.dart';
import 'package:client/services/services.dart';
import 'package:data_models/events/event.dart';

/// [ChoosePlatformPagePresenter] ChangeNotifier Presenter class
/// handles logics for ChoosePlatformPage
class ChoosePlatformPagePresenter with ChangeNotifier {
  final EventProvider? eventProvider;

  ChoosePlatformPagePresenter({
    this.eventProvider,
  });

  Event? _event;
  PlatformItem? _selectedPlatform;
  String? _url;
  String? _error;
  bool _isValidUrl = false;
  bool _editingUrl = true;

  bool get editingUrl => _editingUrl;
  bool get isValidUrl => _isValidUrl;
  String? get url => _url;
  String? get error => _error;

  Event? get event => _event;

  PlatformItem? get selectedPlatform =>
      _selectedPlatform ?? allowedVideoPlatforms.first;

  /// Controller for url input field
  final TextEditingController urlController = TextEditingController();

  void initialize() {
    _event = eventProvider?.event;
    _selectedPlatform = event?.externalPlatform;
    urlController.text = _selectedPlatform?.url ?? '';
    urlController.addListener(() {
      if (urlController.text.isNotEmpty) {
        _url = urlController.text.trim();
        _isValidUrl = validateUrl(_url, _selectedPlatform?.platformKey);
      } else {
        _url = null;
        _error = null;
      }
      notifyListeners();
    });
  }

  void updateSelectedPlatform() {
    if (selectedPlatform?.platformKey == PlatformKey.community) {
      _event = _event?.copyWith(externalPlatform: _selectedPlatform);
    } else {
      _selectedPlatform = _selectedPlatform?.copyWith(url: url);
      _isValidUrl = validateUrl(_url, _selectedPlatform?.platformKey);
      if (_isValidUrl) {
        _event = _event?.copyWith(
          externalPlatform: _selectedPlatform?.copyWith(url: url),
        );
        _editingUrl = false;
      }

      notifyListeners();
    }
  }

  bool validateUrl(String? text, PlatformKey? key) {
    final isUriMalformed = key == null ||
        text == null ||
        text.trim().isEmpty ||
        Uri.tryParse(text) == null;
    final isValidUrl =
        !isUriMalformed && text.contains(key.allowedUrlSubstring);

    if (isValidUrl) {
      _error = null;
    } else {
      _addErrorText();
    }
    return isValidUrl;
  }

  void _addErrorText() {
    _error =
        'This link does not appear to be a ${_selectedPlatform?.platformKey.info.title ?? ''} URL';
  }

  void selectPlatform(PlatformItem platformItem) {
    if (platformItem.platformKey == event?.externalPlatform?.platformKey) {
      _selectedPlatform = event?.externalPlatform;
      urlController.text = _selectedPlatform?.url ?? '';
    } else {
      _selectedPlatform = platformItem;
      clearPlatformUrl();
    }
    notifyListeners();
  }

  Future<Event?> submit() async {
    if (editingUrl) updateSelectedPlatform();
    await firestoreEventService.updateEvent(
      event: _event!,
      keys: [Event.kFieldExternalPlatform],
    );
    return null;
  }

  bool isSelectedPlatform(PlatformItem platformItem) =>
      selectedPlatform?.platformKey == platformItem.platformKey;

  void clearPlatformUrl() {
    urlController.clear();
    _editingUrl = true;
    notifyListeners();
  }
}
