import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/app_clickable_widget.dart';
import 'package:junto/common_widgets/create_dialog_ui_migration.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/keyboard_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:provider/provider.dart';

class Dialogs {
  static Future<String?> showComposeMessageDialog(
    BuildContext context, {
    required String title,
    required bool isMobile,
    String? labelText,
    String? positiveButtonText,
    String? Function(String?)? validator,
  }) async {
    final String? message = await showJuntoDialog<String?>(
      resizeForKeyboard: false,
      builder: (context) {
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        final TextEditingController textEditingController = TextEditingController();

        return Dialog(
          backgroundColor: AppColor.darkBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            constraints: BoxConstraints(maxHeight: 600, maxWidth: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.white,
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
                            ? AppTextStyle.headline1
                                // Apply same style just slightly smaller font for mobile
                                .copyWith(fontSize: 30, color: AppColor.darkBlue)
                            : AppTextStyle.headline1.copyWith(color: AppColor.darkBlue),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppClickableWidget(
                        child: JuntoImage(null, asset: AppAsset.kXPng, width: 32, height: 32),
                        onTap: () => Navigator.pop(context)),
                  ],
                ),
                SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: JuntoUiMigration(
                    whiteBackground: true,
                    child: JuntoTextField(
                      minLines: 3,
                      autofocus: true,
                      controller: textEditingController,
                      validator: validator,
                      labelText: labelText,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  alignment: Alignment.centerRight,
                  child: ActionButton(
                    text: positiveButtonText,
                    textColor: AppColor.brightGreen,
                    color: AppColor.darkBlue,
                    onPressed: () async {
                      if (formKey.currentState?.validate() == true) {
                        Navigator.pop(context, textEditingController.text);
                      }
                    },
                  ),
                )
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
    final double? selectedNumber = await showJuntoDialog<double?>(
      builder: (context) {
        double? selectedValue = currentNumber;

        return Dialog(
          backgroundColor: AppColor.darkBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            constraints: BoxConstraints(maxHeight: 600, maxWidth: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.white,
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: JuntoText(title, style: AppTextStyle.headline1),
                ),
                SizedBox(height: 10),
                FormBuilderSlider(
                  activeColor: AppColor.brightGreen,
                  inactiveColor: AppColor.gray4,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                    ),
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: AppColor.darkBlue),
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
                      text: 'Update',
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

    loggingService.log('Dialogs.showSelectNumberDialog: Selected number: $selectedNumber');

    return selectedNumber;
  }

  static Future<bool> showAcceptTakeRateDialog(
    BuildContext context,
    JuntoProvider juntoProvider,
  ) async {
    final junto = juntoProvider.junto;
    final capabilities = await cloudFunctionsService
        .getJuntoCapabilities(GetJuntoCapabilitiesRequest(juntoId: junto.id));

    final bool? isAccepted = await CreateDialogUiMigration<bool?>(
      builder: (context) {
        final takeRate = capabilities.takeRate!;

        return Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment terms',
                style: AppTextStyle.headline3.copyWith(color: AppColor.darkBlue),
              ),
              SizedBox(height: 10),
              Text(
                'On our free plan, any end user payments will incur a ${takeRate * 100}% commission. Upgrade your plan for a lower rate.',
                style: AppTextStyle.body.copyWith(color: AppColor.gray1),
              ),
              SizedBox(height: 20),
              ActionButton(
                text: 'Agree and continue',
                color: AppColor.darkBlue,
                textColor: AppColor.brightGreen,
                expand: true,
                onPressed: () => Navigator.pop(context, true),
              ),
              SizedBox(height: 5),
              ActionButton(
                text: 'Not now',
                color: Colors.transparent,
                textColor: AppColor.darkBlue,
                expand: true,
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        );
      },
    ).show();

    return isAccepted ?? false;
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
          child: Theme(
            data: Theme.of(context),
            child: ChangeNotifierProvider<AppDrawerProvider>(
              create: (_) => AppDrawerProvider(),
              child: Builder(
                builder: (originalContext) {
                  final appDrawerProvider = originalContext.watch<AppDrawerProvider>();

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
                          constraints: BoxConstraints(maxWidth: AppSize.kSidebarWidth),
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
      _onSaveChanges ?? () => throw UnimplementedError('No Confirmation Set in AppDrawerProvider');

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
      color: AppColor.grayTransparent,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(color: AppColor.white.withOpacity(0.75)),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Spacer(),
            JuntoText(
              'Save changes?',
              style: AppTextStyle.headline3.copyWith(
                  color: areColorsFromTheme
                      ? Theme.of(context).colorScheme.primary
                      : AppColor.darkBlue),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButton(
                  type: ActionButtonType.outline,
                  textColor: areColorsFromTheme
                      ? Theme.of(context).colorScheme.primary
                      : AppColor.darkBlue,
                  text: 'Discard',
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 10),
                ActionButton(
                  color: areColorsFromTheme
                      ? Theme.of(context).colorScheme.primary
                      : AppColor.darkBlue,
                  textColor: areColorsFromTheme
                      ? Theme.of(context).colorScheme.secondary
                      : AppColor.brightGreen,
                  text: 'Save',
                  onPressed: onSaveChanges,
                )
              ],
            ),
            Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
