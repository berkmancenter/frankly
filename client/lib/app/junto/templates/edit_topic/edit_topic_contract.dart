import 'package:junto/app/junto/utils.dart';

abstract class EditTopicView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void closeDrawer();
}
