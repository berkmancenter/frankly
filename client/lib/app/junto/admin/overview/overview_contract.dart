import 'package:junto/app/junto/utils.dart';

abstract class OverviewView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
