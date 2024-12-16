import 'package:client/app/community/utils.dart';

abstract class EditTemplateView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void closeDrawer();
}
