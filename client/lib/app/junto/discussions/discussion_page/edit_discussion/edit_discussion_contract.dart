import 'package:junto/app/junto/utils.dart';

abstract class EditDiscussionView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void closeDrawer();
}
