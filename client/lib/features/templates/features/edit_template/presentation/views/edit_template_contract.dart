import 'package:client/core/utils/toast_utils.dart';

abstract class EditTemplateView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void closeDrawer();
}
