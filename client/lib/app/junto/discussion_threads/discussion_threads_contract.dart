import 'package:junto/app/junto/utils.dart';

abstract class DiscussionThreadsView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
