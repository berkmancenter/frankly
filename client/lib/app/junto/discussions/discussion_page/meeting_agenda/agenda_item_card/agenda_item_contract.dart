import 'package:junto/app/junto/utils.dart';

abstract class AgendaItemView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
