import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/buttons/app_clickable_widget.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/widgets/keyboard_util_widgets.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class Dialogs {
  static Future<String?> showComposeMessageDialog(
    BuildContext context, {
    required String title,
    required bool isMobile,
    String? labelText,
    String? positiveButtonText,
    String? Function(String?)? validator,
  }) async {
    final String? message = await showCustomDialog<String?>(
      resizeForKeyboard: false,
      builder: (context) {
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        final TextEditingController textEditingController =
            TextEditingController();

        return Dialog(
          backgroundColor: context.theme.colorScheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            constraints: BoxConstraints(maxHeight: 600, maxWidth: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.theme.colorScheme.surfaceContainerLowest,
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: isMobile
                            ? context.theme.textTheme.headlineMedium
                            : context.theme.textTheme.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppClickableWidget(
                      child: ProxiedImage(
                        null,
                        asset: AppAsset.kXPng,
                        width: 32,
                        height: 32,
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: CustomTextField(
                    minLines: 3,
                    autofocus: true,
                    controller: textEditingController,
                    validator: validator,
                    labelText: labelText,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  alignment: Alignment.centerRight,
                  child: ActionButton(
                    text: positiveButtonText,
                    textColor: context.theme.colorScheme.onPrimary,
                    color: context.theme.colorScheme.primary,
                    onPressed: () async {
                      if (formKey.currentState?.validate() == true) {
                        Navigator.pop(context, textEditingController.text);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    loggingService.log('Dialogs.showComposeMessageDialog: Message: $message');

    return message;
  }

  static Future<double?> showSelectNumberDialog(
    BuildContext context, {
    required bool isMobile,
    required String title,
    required double minNumber,
    required double maxNumber,
    required double currentNumber,
    required String buttonText,
  }) async {
    final double? selectedNumber = await showCustomDialog<double?>(
      builder: (context) {
        double? selectedValue = currentNumber;

        return Dialog(
          backgroundColor: context.theme.colorScheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            constraints: BoxConstraints(maxHeight: 600, maxWidth: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.theme.colorScheme.surfaceContainerLowest,
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: HeightConstrainedText(
                    title,
                    style: context.theme.textTheme.headlineMedium,
                  ),
                ),
                SizedBox(height: 10),
                FormBuilderSlider(
                  activeColor: context.theme.colorScheme.primary,
                  inactiveColor: context.theme.colorScheme.primaryFixed,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0),
                    ),
                    border: const OutlineInputBorder(),
                    labelStyle:
                        TextStyle(color: context.theme.colorScheme.primary),
                  ),
                  initialValue: currentNumber,
                  min: minNumber,
                  numberFormat: NumberFormat('##'),
                  max: maxNumber,
                  onChanged: (value) => selectedValue = value,
                  name: 'num_participants',
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ActionButton(
                      text: context.l10n.update,
                      onPressed: () => Navigator.pop(context, selectedValue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    loggingService.log(
      'Dialogs.showSelectNumberDialog: Selected number: $selectedNumber',
    );

    return selectedNumber;
  }

  /// Showing Dialog as a Drawer on the left or right side of the screen.
  static Future<void> showAppDrawer(
    BuildContext context,
    AppDrawerSide appDrawerSide,
    Widget child,
  ) async {
    await showGeneralDialog(
      barrierDismissible: false,
      context: context,
      transitionBuilder: (_, animation, ___, widget) {
        final Offset offset;
        switch (appDrawerSide) {
          case AppDrawerSide.left:
            offset = Offset((animation.value - 1) * AppSize.kSidebarWidth, 0);
            break;
          case AppDrawerSide.right:
            offset = Offset((1 - animation.value) * AppSize.kSidebarWidth, 0);
            break;
        }

        return Transform.translate(offset: offset, child: widget);
      },
      pageBuilder: (BuildContext builderContext, _, __) {
        return FocusFixer(
          resizeForKeyboard: true,
          child: ChangeNotifierProvider<AppDrawerProvider>(
            create: (_) => AppDrawerProvider(),
            child: Builder(
              builder: (originalContext) {
                final appDrawerProvider =
                    originalContext.watch<AppDrawerProvider>();

                return Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (appDrawerProvider.hasDrawerUnsavedChanges) {
                          appDrawerProvider.showConfirmChangesDialogLayer();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    Align(
                      alignment: appDrawerSide == AppDrawerSide.left
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: AppSize.kSidebarWidth),
                        child: Stack(
                          children: [
                            child,
                            if (appDrawerProvider.isConfirmChangesDialogShown)
                              ConfirmDialogLayer(
                                areColorsFromTheme: true,
                                onSaveChanges: appDrawerProvider.onSaveChanges,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

enum AppDrawerSide {
  left,
  right,
}

/// Special model/provider specifically for [Dialogs.showAppDrawer]. With this model
/// we can control if we should show/hide dialog upon dismissal.
class AppDrawerProvider extends ChangeNotifier {
  bool _hasDrawerUnsavedChanges = false;
  bool get hasDrawerUnsavedChanges => _hasDrawerUnsavedChanges;

  bool _isConfirmChangesDialogShown = false;
  bool get isConfirmChangesDialogShown => _isConfirmChangesDialogShown;

  /// Confirmation callback. Each dialog has second layer, which gets triggered once user
  /// tried to leave it without saving changes. This callback is the positive button callback
  /// from that second layer dialog. It must be initialised and usually callback is the same as saving
  /// changes.
  void Function()? _onSaveChanges;
  void Function() get onSaveChanges =>
      _onSaveChanges ??
      () =>
          throw UnimplementedError('No Confirmation Set in AppDrawerProvider');

  void setUnsavedChanges(bool hasUnsavedChanges) {
    _hasDrawerUnsavedChanges = hasUnsavedChanges;
  }

  void showConfirmChangesDialogLayer() {
    _isConfirmChangesDialogShown = true;
    notifyListeners();
  }

  void hideConfirmChangesDialogLayer() {
    _isConfirmChangesDialogShown = false;
    notifyListeners();
  }

  void setOnSaveChanges({required void Function() onSaveChanges}) {
    _onSaveChanges = onSaveChanges;
  }
}

/// Layer that is shown if [AppDrawer] is trying to close but there are some unsaved changes.
class ConfirmDialogLayer extends StatelessWidget {
  final void Function() onSaveChanges;
  final bool areColorsFromTheme;

  const ConfirmDialogLayer({
    Key? key,
    required this.onSaveChanges,
    required this.areColorsFromTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.scrim.withScrimOpacity,
      alignment: Alignment.center,
      child: Container(
        decoration:
            BoxDecoration(color: context.theme.colorScheme.surfaceContainer),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Spacer(),
            HeightConstrainedText(
              context.l10n.saveChanges,
              style: context.theme.textTheme.titleMedium!,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButton(
                  type: ActionButtonType.outline,
                  textColor: context.theme.colorScheme.primary,
                  text: context.l10n.discard,
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 10),
                ActionButton(
                  color: context.theme.colorScheme.primary,
                  textColor: context.theme.colorScheme.onPrimary,
                  text: context.l10n.save,
                  onPressed: onSaveChanges,
                ),
              ],
            ),
            Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
