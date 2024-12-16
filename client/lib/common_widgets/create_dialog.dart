import 'package:flutter/material.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/custom_list_view.dart';
import 'package:client/common_widgets/ui_migration.dart';
import 'package:client/app.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/dialog_provider.dart';

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
      () => showCustomDialog<T>(
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
    return UIMigration(
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
                      child: CustomListView(
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
                          onPressed: onDismissBarrier ??
                              () => Navigator.of(context).pop(),
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
