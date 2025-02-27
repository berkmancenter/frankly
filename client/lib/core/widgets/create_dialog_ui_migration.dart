import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';

class CreateDialogUiMigration<T> extends StatefulWidget {
  final WidgetBuilder builder;
  final Function()? onDismissBarrier;
  final Color barrierColor;
  final bool isFullscreenOnMobile;
  final double maxWidth;
  final bool isCloseButtonVisible;

  const CreateDialogUiMigration({
    required this.builder,
    this.onDismissBarrier,
    this.barrierColor = Colors.black54,
    this.isFullscreenOnMobile = false,
    this.maxWidth = 700.0,
    this.isCloseButtonVisible = true,
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

  @override
  State<CreateDialogUiMigration<T>> createState() =>
      _CreateDialogUiMigrationState<T>();
}

class _CreateDialogUiMigrationState<T>
    extends State<CreateDialogUiMigration<T>> {
  @override
  Widget build(BuildContext context) {
    final isFullscreen = widget.isFullscreenOnMobile &&
        responsiveLayoutService.isMobile(context);

    return UIMigration(
      child: GestureDetector(
        onTap: widget.onDismissBarrier ?? () => Navigator.of(context).pop(),
        child: Container(
          color: widget.barrierColor,
          alignment: Alignment.center,
          padding: !isFullscreen ? const EdgeInsets.all(30) : null,
          child: GestureDetector(
            onTap: () {},
            child: Material(
              borderRadius: !isFullscreen ? BorderRadius.circular(20) : null,
              color: AppColor.white,
              child: Container(
                constraints: !isFullscreen
                    ? BoxConstraints(maxWidth: widget.maxWidth)
                    : null,
                child: Stack(
                  children: [
                    CustomListView(
                      shrinkWrap: !isFullscreen,
                      children: [
                        Builder(builder: widget.builder),
                      ],
                    ),
                    if (widget.isCloseButtonVisible)
                      Positioned.fill(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
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
