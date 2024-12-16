import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';

/// Deprecated: Use CreateCustomDialog instead.
class CreateDialog<T> extends StatelessWidget {
  final WidgetBuilder builder;
  final Function()? onDismissBarrier;
  final bool showBackground;
  final double maxWidth;

  const CreateDialog({
    required this.builder,
    this.onDismissBarrier,
    this.showBackground = true,
    this.maxWidth = 700.0,
  });

  Future<T?> show({BuildContext? context}) async {
    final curContext = context ?? navigatorState.context;

    return guardSignedIn<T?>(
      () => showJuntoDialog<T>(
        context: curContext,
        barrierColor: Colors.transparent,
        builder: (_) => this,
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        alignment: Alignment.bottomLeft,
        child: Image.asset('media/flower.png'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JuntoUiMigration(
      whiteBackground: true,
      child: GestureDetector(
        onTap: onDismissBarrier ?? () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black54,
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: AppColor.white,
              child: GestureDetector(
                onTap: () {},
                child: Stack(
                  children: [
                    if (showBackground) _buildBackground(),
                    Container(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: JuntoListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          Builder(builder: builder),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: onDismissBarrier ?? () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
