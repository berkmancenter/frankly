import 'package:client/core/utils/toast_utils.dart';

abstract class MeetingGuideCardItemUserSuggestionsView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
