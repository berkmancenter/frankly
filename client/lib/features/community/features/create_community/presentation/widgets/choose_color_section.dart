import 'package:client/core/utils/extensions.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/utils/community_theme_utils.dart.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/theme_preview_container.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// This is the section of the create / update community dialog where the community's theme is set
/// either from a preset list of color combinations or by entering custom 6-digit color strings
class ChooseColorSection extends StatefulWidget {
  final Community community;
  final void Function(String) setLightColor;
  final void Function(String) setDarkColor;
  final bool showTabs;
  final bool bigTitle;

  const ChooseColorSection({
    required this.community,
    required this.setLightColor,
    required this.setDarkColor,
    this.showTabs = true,
    this.bigTitle = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ChooseColorSection> createState() => _ChooseColorSectionState();
}

class _ChooseColorSectionState extends State<ChooseColorSection> {
  late bool _isPresetSelected;
  late final TextEditingController _customLightColorController;
  late final TextEditingController _customDarkColorController;

  int _selectedPresetIndex = 0;
  String? _selectedColorErrorMessage;

  String get _currentLightColor => _customLightColorController.text;

  String get _currentDarkColor => _customDarkColorController.text;

  bool get _isSelectedColorComboValid => ThemeUtils.isColorComboValid(
        context,
        _currentLightColor,
        _currentDarkColor,
      );

  String? get _currentCommunityLightColor => widget.community.themeLightColor;

  String? get _currentCommunityDarkColor => widget.community.themeDarkColor;

    final Color _lightColor = Color(0xfff5f5f5);
  Color darkColor = Color(0xff212121);

  @override
  void initState() {
    super.initState();
    _customLightColorController =
        TextEditingController(text: _currentCommunityLightColor);
    _customDarkColorController =
        TextEditingController(text: _currentCommunityDarkColor);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _determineSelectedColorScheme();
  }

  @override
  void dispose() {
    _customLightColorController.dispose();
    _customDarkColorController.dispose();
    super.dispose();
  }

  void _determineSelectedColorScheme() {
    final currentDarkColor = ThemeUtils.parseColor(_currentCommunityDarkColor);
    final currentLightColor =
        ThemeUtils.parseColor(_currentCommunityLightColor);
    _selectedPresetIndex = ThemeUtils().presetColorThemes(context).indexWhere(
          (theme) =>
              theme.darkColor == currentDarkColor &&
              theme.lightColor == currentLightColor,
        );
    final customColorsSpecified = _currentCommunityDarkColor != null &&
        _currentCommunityLightColor != null;
    _isPresetSelected =
        _selectedPresetIndex >= 0 || !customColorsSpecified || !widget.showTabs;
    if (_selectedPresetIndex == -1) _selectedPresetIndex = 0;
  }

  void _checkChosenColorConstraints() {
    setState(() {
      if (ThemeUtils.isColorValid(_currentLightColor) &&
          ThemeUtils.isColorValid(_currentDarkColor)) {
        final firstColor = ThemeUtils.parseColor(_currentLightColor) ??
            context.theme.colorScheme.surface;
        final secondColor = ThemeUtils.parseColor(_currentDarkColor) ??
            context.theme.colorScheme.primary;

        if (!ThemeUtils.isFirstColorLighter(firstColor, secondColor)) {
          _selectedColorErrorMessage = 'Light color must be lighter';
        } else if (!ThemeUtils.isContrastRatioValid(
          context,
          firstColor,
          secondColor,
        )) {
          _selectedColorErrorMessage =
              'Contrast ratio must be greater than 4.5';
        } else if (!ThemeUtils.isContrastRatioValid(
          context,
          firstColor,
          context.theme.colorScheme.secondary,
        )) {
          _selectedColorErrorMessage = 'Light color must be lighter';
        } else if (!ThemeUtils.isContrastRatioValid(
          context,
          secondColor,
          context.theme.colorScheme.surface,
        )) {
          _selectedColorErrorMessage = 'Dark color must be darker';
        }
      } else {
        _selectedColorErrorMessage = null;
      }
    });
  }

  void _changeDarkColorTextField(String val) {
    if (ThemeUtils.isColorValid(_currentDarkColor)) {
      widget.setDarkColor(_currentDarkColor);
    } else {
      widget.setDarkColor('');
    }
    _checkChosenColorConstraints();
  }

  void _changeLightColorTextField(String val) {
    if (ThemeUtils.isColorValid(val)) {
      widget.setLightColor(_currentLightColor);
// setState(() {
//       _lightColor = ThemeUtils.parseColor(val);
// });
    } else {
      widget.setLightColor('');
    }
    _checkChosenColorConstraints();
  }

  void _selectPreset(BuildContext context, int index) {
    widget.setDarkColor(ThemeUtils().darkColorStringFromTheme(context, index));
    widget
        .setLightColor(ThemeUtils().lightColorStringFromTheme(context, index));
    setState(() => _selectedPresetIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = responsiveLayoutService.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HeightConstrainedText(
          context.l10n.theme,
          style: context.theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 30),
        SizedBox(
          height: 400,
          child: DefaultTabController(
            initialIndex: _isPresetSelected ? 0 : 1,
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: <Widget>[
                    Tab(
                      child: Text(
                        context.l10n.presets,
                        style: context.theme.textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        context.l10n.custom,
                        style: context.theme.textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  _buildPresetColorsContent(context, mobile),
                  _buildCustomColorsContent(mobile),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetColorsContent(BuildContext context, bool mobile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: mobile ? 3 : 5,
        crossAxisSpacing: mobile ? 40 : 30,
        mainAxisSpacing: 30,
        children:
            List.generate(ThemeUtils().presetColorThemes(context).length, (i) {
          return FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () => _selectPreset(context, i),
            backgroundColor:
                ThemeUtils().presetColorThemes(context)[i].lightColor,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeUtils().presetColorThemes(context)[i].darkColor,
              ),
              child: Center(
                child: Icon(
                  _selectedPresetIndex == i ? Icons.check : null,
                  color: context.theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _buildColorPickerDialog(String currentColor,  Function(Color color) colorChanged,) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor.isNotEmpty ? (ThemeUtils.parseColor(currentColor) ?? Colors.white) : Colors.white,
            onColorChanged: (Color color) => colorChanged(color),
          ),
        ),
        actions: <Widget>[
          ActionButton(
            text: 'Got it',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomColorsContent(bool mobile) {
    const description =
        'Choose one light color and one dark color. Colors must meet a 4.5:1 contrast ratio. For help selecting compliant colors, go to ';
    const linkText = 'color.review.';
    final launchLink = TapGestureRecognizer()
      ..onTap = () => launch('https://color.review');

    return Flex(
      direction: mobile ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.water_drop,
                color: _lightColor,),
              onPressed: () {
                _buildColorPickerDialog(
                  _currentLightColor,
                  (Color color) {
                    _customLightColorController.text = color.toHexString();
                    _changeLightColorTextField(_customLightColorController.text);
                  },
                );
              },
             
            ),
            SizedBox(width: 10),
            _buildChooseColorTextField(
              label: context.l10n.lightColorHex,
              onChanged: _changeLightColorTextField,
              controller: _customLightColorController,
            ),
          ],
        ),
      ],
    );

    // SizedBox(width: 10),
    // _buildChooseColorTextField(
    //   label: context.l10n.darkColorHex,
    //   onChanged: _changeDarkColorTextField,
    //   controller: _customDarkColorController,
    // ),
    // _buildErrorMessage(),
  }

  List<Widget> _buildCustomTextFields() => [
        SizedBox(
          width: 150,
          child: Column(
            children: [
              _buildChooseColorTextField(
                label: context.l10n.lightColorHex,
                onChanged: _changeLightColorTextField,
                controller: _customLightColorController,
              ),
              _buildChooseColorTextField(
                onChanged: _changeDarkColorTextField,
                label: context.l10n.darkColorHex,
                controller: _customDarkColorController,
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        _buildCheckIcon(),
      ];
  
  Widget _buildChooseColorTextField({
    required String label,
    required void Function(String) onChanged,
    required TextEditingController controller,
  }) =>
      Expanded(
        child: CustomTextField(
          controller: controller,
          onChanged: onChanged,
          labelText: label,
          maxLength: 6,
          hideCounter: true,
          prefixText: '#',
          borderType: BorderType.underline,
        ),
      );

  Widget _buildCheckIcon() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isSelectedColorComboValid
                ? context.theme.colorScheme.onPrimary.withAlpha(40)
                : null,
            border: Border.all(
              color: _isSelectedColorComboValid
                  ? context.theme.colorScheme.primary
                  : context.theme.colorScheme.onPrimaryContainer,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.check,
              color: _isSelectedColorComboValid
                  ? context.theme.colorScheme.secondary
                  : context.theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      );

  Widget _buildErrorMessage() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedColorErrorMessage != null) ...[
            SizedBox(height: 10),
            HeightConstrainedText(
              _selectedColorErrorMessage!,
              style: AppTextStyle.eyebrowSmall
                  .copyWith(color: context.theme.colorScheme.error),
            ),
          ],
        ],
      );
}
