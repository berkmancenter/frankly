import 'package:client/core/utils/toast_utils.dart';

abstract class EditEventView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void closeDrawer();
}
