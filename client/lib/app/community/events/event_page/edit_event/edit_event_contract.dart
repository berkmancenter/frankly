import 'package:client/app/community/utils.dart';

abstract class EditEventView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void closeDrawer();
}
