import 'package:client/app/community/utils.dart';

abstract class EventPageView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
