import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const _defaultCameraId = 'default-camera-id';
  static const _defaultMicrophoneId = 'default-microphone-id';
  static const _isReturningUser = 'is-returning-user';
  static const _lastQueryParameters = 'last-query-parameters';
  static const _kWasMeetingTutorialShown = 'was-meeting-tutorial-shown';
  static const _kIsOnboardingOverviewTooltipShown =
      'is-onboarding-overview-tooltip-shown';
  static const _kAvCheckComplete = 'av-check-complete';
  static const _kCameraOnByDefault = 'camera-on-by-default';
  static const _kMicOnByDefault = 'mic-on-by-default';
  static const _kIsEditTemplateTooltipShown = 'is-edit-template-tooltip-shown';

  late SharedPreferences _preferences;
  Future<SharedPreferences>? _loadingPreferencesFuture;

  Future<void> initialize() async {
    _loadingPreferencesFuture ??= SharedPreferences.getInstance();

    _preferences = await _loadingPreferencesFuture!;
  }

  bool isReturningUser() => _preferences.getBool(_isReturningUser) ?? false;
  Future<bool> setIsReturningUser(bool isReturningUser) => _preferences.setBool(
        _isReturningUser,
        isReturningUser,
      );

  bool wasMeetingTutorialShown() =>
      _preferences.getBool(_kWasMeetingTutorialShown) ?? false;
  Future<bool> setMeetingTutorialShown(bool wasShown) => _preferences.setBool(
        _kWasMeetingTutorialShown,
        wasShown,
      );

  bool isOnboardingOverviewTooltipShown() {
    return _preferences.getBool(_kIsOnboardingOverviewTooltipShown) ?? true;
  }

  Future<bool> updateOnboardingOverviewTooltipVisibility(bool isShown) async {
    final result =
        await _preferences.setBool(_kIsOnboardingOverviewTooltipShown, isShown);
    return result;
  }

  bool isEditTemplateTooltipShown() {
    return _preferences.getBool(_kIsEditTemplateTooltipShown) ?? true;
  }

  Future<bool> updateEditTemplateTooltipVisibility(bool isShown) async {
    final result =
        await _preferences.setBool(_kIsEditTemplateTooltipShown, isShown);
    return result;
  }

  String? getLastQueryParams() => _preferences.getString(_lastQueryParameters);
  Future<void> setLastQueryParameters(String lastQueryParameters) =>
      _preferences.setString(
        _lastQueryParameters,
        lastQueryParameters,
      );

  bool getAvCheckComplete() => _preferences.getBool(_kAvCheckComplete) ?? false;
  Future<void> setAvCheckComplete({
    required bool cameraOnByDefault,
    required bool micOnByDefault,
    required String defaultMic,
    required String defaultCamera,
  }) {
    return Future.wait([
      _setCameraOnByDefault(cameraOnByDefault),
      _setMicOnByDefault(micOnByDefault),
      setDefaultCameraId(defaultCamera),
      setDefaultMicrophoneId(defaultMic),
      _preferences.setBool(_kAvCheckComplete, true),
    ]);
  }

  bool getCameraOnByDefault() =>
      _preferences.getBool(_kCameraOnByDefault) ?? false;
  Future<void> _setCameraOnByDefault(bool val) =>
      _preferences.setBool(_kCameraOnByDefault, val);

  bool getMicOnByDefault() => _preferences.getBool(_kMicOnByDefault) ?? false;
  Future<void> _setMicOnByDefault(bool val) =>
      _preferences.setBool(_kMicOnByDefault, val);

  String? getDefaultCameraId() => _preferences.getString(_defaultCameraId);
  Future<bool> setDefaultCameraId(String id) =>
      _preferences.setString(_defaultCameraId, id);

  String? getDefaultMicrophoneId() =>
      _preferences.getString(_defaultMicrophoneId);
  Future<bool> setDefaultMicrophoneId(String id) =>
      _preferences.setString(_defaultMicrophoneId, id);
}
