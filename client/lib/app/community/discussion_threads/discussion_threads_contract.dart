import 'package:client/app/community/utils.dart';

abstract class DiscussionThreadsView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
