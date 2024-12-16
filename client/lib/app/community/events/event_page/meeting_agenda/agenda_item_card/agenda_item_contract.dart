import 'package:client/app/community/utils.dart';

abstract class AgendaItemView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
