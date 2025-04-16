import 'package:client/core/utils/toast_utils.dart';

abstract class EventSettingsView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void closeDrawer();
}
