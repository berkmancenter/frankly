import 'package:client/app/community/utils.dart';

abstract class MeetingGuideCardItemUserSuggestionsView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
