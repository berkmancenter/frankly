import 'package:client/core/utils/toast_utils.dart';

abstract class DiscussionThreadsView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
