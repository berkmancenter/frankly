import 'package:flutter/material.dart';
import 'package:client/core/widgets/create_dialog_ui_migration.dart';

mixin ShowDialogMixin on Widget {
  Future<void> show() async {
    return CreateDialogUiMigration(
      builder: (_) => this,
      isFullscreenOnMobile: true,
      maxWidth: 524,
    ).show();
  }
}
