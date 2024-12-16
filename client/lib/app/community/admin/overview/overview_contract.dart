import 'package:client/app/community/utils.dart';

abstract class OverviewView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
