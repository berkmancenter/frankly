import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/theme_creation_utility.dart';
import 'package:junto/app/home/creation_dialog/theme_preview_container.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/plan_capability_list.dart';

/// This is the section of the create / update community dialog where the community's theme is set
/// either from a preset list of color combinations or by entering custom 6-digit color strings
class ChooseColorSection extends StatefulWidget {
  final Junto junto;
  final void Function(String) setLightColor;
  final void Function(String) setDarkColor;
  final bool showTabs;
  final bool bigTitle;

  const ChooseColorSection({
    required this.junto,
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

  bool get _isSelectedColorComboValid =>
      ThemeUtils.isColorComboValid(_currentLightColor, _currentDarkColor);

  String? get _currentJuntoLightColor => widget.junto.themeLightColor;

  String? get _currentJuntoDarkColor => widget.junto.themeDarkColor;

  @override
  void initState() {
    _customLightColorController = TextEditingController(text: _currentJuntoLightColor);
    _customDarkColorController = TextEditingController(text: _currentJuntoDarkColor);
    _determineSelectedColorScheme();
    super.initState();
  }

  @override
  void dispose() {
    _customLightColorController.dispose();
    _customDarkColorController.dispose();
    super.dispose();
  }

  void _determineSelectedColorScheme() {
    final currentDarkColor = ThemeUtils.parseColor(_currentJuntoDarkColor);
    final currentLightColor = ThemeUtils.parseColor(_currentJuntoLightColor);
    _selectedPresetIndex = ThemeUtils.presetColorThemes.indexWhere(
        (theme) => theme.darkColor == currentDarkColor && theme.lightColor == currentLightColor);
    final customColorsSpecified = _currentJuntoDarkColor != null && _currentJuntoLightColor != null;
    _isPresetSelected = _selectedPresetIndex >= 0 || !customColorsSpecified || !widget.showTabs;
    if (_selectedPresetIndex == -1) _selectedPresetIndex = 0;
  }

  void _checkChosenColorConstraints() {
    setState(() {
      if (ThemeUtils.isColorValid(_currentLightColor) &&
          ThemeUtils.isColorValid(_currentDarkColor)) {
        final firstColor = ThemeUtils.parseColor(_currentLightColor) ?? AppColor.gray6;
        final secondColor = ThemeUtils.parseColor(_currentDarkColor) ?? AppColor.darkBlue;

        if (!ThemeUtils.isFirstColorLighter(firstColor, secondColor)) {
          _selectedColorErrorMessage = 'Light color must be lighter';
        } else if (!ThemeUtils.isContrastRatioValid(firstColor, secondColor)) {
          _selectedColorErrorMessage = 'Contrast ratio must be greater than 4.5';
        } else if (!ThemeUtils.isContrastRatioValid(firstColor, AppColor.gray1)) {
          _selectedColorErrorMessage = 'Light color must be lighter';
        } else if (!ThemeUtils.isContrastRatioValid(secondColor, AppColor.gray6)) {
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
    if (ThemeUtils.isColorValid(_currentLightColor)) {
      widget.setLightColor(_currentLightColor);
    } else {
      widget.setLightColor('');
    }
    _checkChosenColorConstraints();
  }

  void _selectPreset(int index) {
    widget.setDarkColor(ThemeUtils.darkColorStringFromTheme(index));
    widget.setLightColor(ThemeUtils.lightColorStringFromTheme(index));
    setState(() => _selectedPresetIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return JuntoStreamGetterBuilder<PlanCapabilityList>(
      entryFrom: 'CreateJuntoDialog.ChooseColorSection',
      streamGetter: () => cloudFunctionsService
          .getJuntoCapabilities(
            GetJuntoCapabilitiesRequest(juntoId: widget.junto.id),
          )
          .asStream(),
      builder: (context, caps) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _buildChooseColorScheme(caps?.hasAdvancedBranding ?? false),
        );
      },
    );
  }

  List<Widget> _buildChooseColorScheme(bool enableCustom) {
    return [
      if (widget.bigTitle) SizedBox(height: 25),
      JuntoText(
        'Choose your color scheme',
        style: widget.bigTitle ? AppTextStyle.body.copyWith(fontSize: 24) : AppTextStyle.body,
      ),
      SizedBox(height: 20),
      if (widget.showTabs) ...[
        _buildPresetCustomTabs(enableCustom),
        SizedBox(height: 20),
      ],
      _buildChooseColorContent(),
      SizedBox(height: 30),
    ];
  }

  Widget _buildPresetCustomTabs(bool enableCustom) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildColorTab(
            text: 'preset',
            selected: _isPresetSelected,
            onTap: () => setState(() => _isPresetSelected = true),
          ),
          if (enableCustom) ...[
            SizedBox(width: 10),
            _buildColorTab(
              text: 'custom',
              selected: !_isPresetSelected,
              onTap: () => setState(() => _isPresetSelected = false),
            ),
          ],
        ],
      );

  Widget _buildColorTab({
    required String text,
    required bool selected,
    required void Function() onTap,
  }) {
    final color = selected ? AppColor.darkBlue : AppColor.gray4;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 4, color: color),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  JuntoText(
                    text.toUpperCase(),
                    style: AppTextStyle.eyebrow.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseColorContent() {
    if (_isPresetSelected) {
      return _buildPresetColorsContent();
    } else {
      return _buildCustomColorsContent();
    }
  }

  Widget _buildPresetColorsContent() => ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: <Widget>[
              for (var i = 0; i < ThemeUtils.presetColorThemes.length; i++)
                ThemePreview(
                  selectedTheme: ThemeUtils.presetColorThemes[i],
                  isSelected: i == _selectedPresetIndex,
                  onTap: () => _selectPreset(i),
                  compact: true,
                ),
            ].intersperse(SizedBox(width: 13)).toList(),
          ),
        ),
      );

  Widget _buildCustomColorsContent() {
    const description =
        'Choose one light color and one dark color. Colors must meet a 4.5:1 contrast ratio. For help selecting compliant colors, go to ';
    const linkText = 'color.review.';
    final launchLink = TapGestureRecognizer()..onTap = () => launch('https://color.review');
    final textStyle = AppTextStyle.body.copyWith(color: AppColor.gray2);
    final linkStyle = AppTextStyle.body
        .copyWith(decoration: TextDecoration.underline, color: AppColor.accentBlue);

    final constrained = MediaQuery.of(context).size.width < 475;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: description, style: textStyle),
              TextSpan(text: linkText, recognizer: launchLink, style: linkStyle),
            ],
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 141,
          child: Row(
            children: [
              ThemePreview(
                lightColorString: _currentLightColor,
                darkColorString: _currentDarkColor,
              ),
              SizedBox(width: 20),
              if (!constrained) ..._buildCustomTextFields(),
            ],
          ),
        ),
        if (constrained)
          SizedBox(
            height: 141,
            child: Row(
              children: _buildCustomTextFields(),
            ),
          ),
        _buildErrorMessage(),
      ],
    );
  }

  List<Widget> _buildCustomTextFields() => [
        SizedBox(
          width: 150,
          child: Column(
            children: [
              _buildChooseColorTextField(
                label: 'Light Color HEX#',
                onChanged: _changeLightColorTextField,
                controller: _customLightColorController,
              ),
              _buildChooseColorTextField(
                onChanged: _changeDarkColorTextField,
                label: 'Dark Color HEX#',
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
        child: JuntoTextField(
          controller: controller,
          onChanged: onChanged,
          labelText: label,
          maxLength: 6,
          hideCounter: true,
          prefixText: '#',
        ),
      );

  Widget _buildCheckIcon() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isSelectedColorComboValid ? AppColor.brightGreen.withAlpha(40) : null,
            border:
                Border.all(color: _isSelectedColorComboValid ? AppColor.darkBlue : AppColor.gray3),
          ),
          child: Center(
            child: Icon(
              Icons.check,
              color: _isSelectedColorComboValid ? AppColor.darkGreen : AppColor.gray4,
            ),
          ),
        ),
      );

  Widget _buildErrorMessage() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedColorErrorMessage != null) ...[
            SizedBox(height: 10),
            JuntoText(
              _selectedColorErrorMessage!,
              style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.redLightMode),
            ),
          ],
        ],
      );
}
