import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js_util.dart' as js_util;

class UnifyAmericaController extends ChangeNotifier {
  final String typeformLink;
  final String externalCommunityId;

  UnifyAmericaController({
    required this.typeformLink,
    required this.externalCommunityId,
  });

  bool _isNeedsHelpLaunched = false;
  bool get isNeedsHelpLaunched => _isNeedsHelpLaunched;

  static UnifyAmericaController? watch(BuildContext context) =>
      providerOrNull(() => Provider.of<UnifyAmericaController>(context));

  static UnifyAmericaController? read(BuildContext context) =>
      providerOrNull(() => Provider.of<UnifyAmericaController>(context, listen: false));

  void onNeedsHelp() {
    js_util.callMethod(html.window, 'Beacon', ['init', '2b8eb075-fe55-452e-a012-7592737b449c']);
    js_util.callMethod(html.window, 'Beacon', ['open']);

    _isNeedsHelpLaunched = true;
    notifyListeners();
  }
}
