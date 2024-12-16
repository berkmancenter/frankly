import 'package:flutter/material.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/utils/keyboard_utils.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:provider/provider.dart';

Future<T?> showJuntoDialog<T>({
  BuildContext? context,
  Color barrierColor = Colors.black54,
  bool isDismissible = true,
  bool resizeForKeyboard = true,
  required WidgetBuilder builder,
}) async {
  context ??= navigatorState.context;

  final provider = Provider.of<DialogProvider>(context, listen: false);
  provider.incrementDialogCount();

  final content = FocusFixer(
    resizeForKeyboard: resizeForKeyboard,
    child: Builder(builder: builder),
  );

  final result = await showDialog<T>(
    context: context,
    barrierColor: barrierColor,
    barrierDismissible: isDismissible,
    builder: (context) {
      if (provider._isOnIframePage) {
        return JuntoPointerInterceptor(child: content);
      } else {
        return content;
      }
    },
  );
  provider.decrementDialogCount();
  return result;
}

class DialogProvider with ChangeNotifier {
  int _numDialogs = 0;
  bool _isOnIframePage = false;

  bool get isShowingDialog => _numDialogs > 0;

  set isOnIframePage(bool value) {
    _isOnIframePage = value;
  }

  void incrementDialogCount() {
    _numDialogs++;
    notifyListeners();
  }

  void decrementDialogCount() {
    _numDialogs--;
    notifyListeners();
  }
}
