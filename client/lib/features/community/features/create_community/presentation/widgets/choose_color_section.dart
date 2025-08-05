import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/utils/community_theme_utils.dart.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community.dart';
import 'package:client/core/localization/localization_helper.dart';
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

  String? get _currentCommunityLightColor => widget.community.themeLightColor;
  String? get _currentCommunityDarkColor => widget.community.themeDarkColor;

  late Color _lightColor =  Color(0xffffffff);
  late Color _darkColor = Color(0xff212121);

  @override
  void initState() {
    super.initState();
    _customLightColorController =
        TextEditingController(text: _currentCommunityLightColor);
    _customDarkColorController =
        TextEditingController(text: _currentCommunityDarkColor);
         _lightColor = _currentLightColor.isNotEmpty
        ? ThemeUtils.parseColor(_currentLightColor)!
        : Color(0xffffffff);
    _darkColor = _currentDarkColor.isNotEmpty
        ? ThemeUtils.parseColor(_currentDarkColor)!
        : Color(0xff212121);
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
          _selectedColorErrorMessage = context.l10n.colorMustBeLighter;
        } else if (!ThemeUtils.isContrastRatioValid(
          context,
          firstColor,
          secondColor,
        )) {
          _selectedColorErrorMessage =
              context.l10n.contrastRatioMustBeGreaterThan4_5;
        } else if (!ThemeUtils.isContrastRatioValid(
          context,
          firstColor,
          context.theme.colorScheme.secondary,
        )) {
          _selectedColorErrorMessage = context.l10n.colorMustBeLighter;
        } else if (!ThemeUtils.isContrastRatioValid(
          context,
          secondColor,
          context.theme.colorScheme.surface,
        )) {
          _selectedColorErrorMessage = context.l10n.colorMustBeDarker;
        }
        else {
          _selectedColorErrorMessage = null;
          widget.setLightColor(_currentLightColor);
          widget.setDarkColor(_currentDarkColor);
        }
      } else {
        _selectedColorErrorMessage = null;
      }
    });
  }

  void _changeDarkColorTextField(Color val) {
    widget.setDarkColor(_currentDarkColor);
    _checkChosenColorConstraints();
    setState(() {
      _darkColor = val;
    });
  }

  void _changeLightColorTextField(Color val) {
    widget.setLightColor(ThemeUtils.convertToHexString(val));
    _checkChosenColorConstraints();
    setState(() {
      _lightColor = val;
    });
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
            child: Column(
              children: [
                TabBar(
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
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _buildPresetColorsContent(context, mobile),
                      _buildCustomColorsContent(mobile),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetColorsContent(BuildContext context, bool mobile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: mobile ? 3 : 5,
        crossAxisSpacing: mobile ? 40 : 30,
        mainAxisSpacing: 30,
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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

  Future<void> _buildColorPickerDialog(
    String currentColor,
    Function(Color color) colorChanged,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor.isNotEmpty
                ? (ThemeUtils.parseColor(currentColor) ?? Colors.white)
                : Colors.white,
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

    List<Widget> children = [
              IconButton(
            icon: Icon(
              Icons.water_drop,
              color: _lightColor,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                ),
              ],
            ),
            onPressed: () {
              _buildColorPickerDialog(
                _currentLightColor,
                (Color color) {
                  _customLightColorController.text =
                      color.toHexString().substring(2, 8);
                  _changeLightColorTextField(color);
                },
              );
            },
          ),
          _buildChooseColorTextField(
            label: context.l10n.lightColorHex,
            onChanged: _changeLightColorTextField,
            controller: _customLightColorController,
          ),
          IconButton(
            icon: Icon(
              Icons.water_drop,
              color: _darkColor,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                ),
              ],
            ),
            onPressed: () {
              _buildColorPickerDialog(
                _currentDarkColor,
                (Color color) {
                  _customDarkColorController.text =
                      color.toHexString().substring(2, 8);
                  _changeDarkColorTextField(color);
                },
              );
            },
          ),
          _buildChooseColorTextField(
            label: context.l10n.darkColorHex,
            onChanged: _changeDarkColorTextField,
            controller: _customDarkColorController,
          ),
    ];
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(mobile) ...children,
          if (!mobile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          ],
 
        _buildErrorMessage(),
      ],
);
  }

  Widget _buildChooseColorTextField({
    required String label,
    required void Function(Color) onChanged,
    required TextEditingController controller,
  }) =>
      CustomTextField(
          labelText: label,
          maxLength: 6,
          hideCounter: true,
          prefixText: '#',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          borderType: BorderType.underline,
          controller: controller,
          padding: EdgeInsets.zero,
          onChanged: (text) {
            final color = ThemeUtils.parseColor(text);
            if (color != null) {
              onChanged(color);
            }
          },
          validator: (value) =>
              ThemeUtils.isColorValid(value) ? null : context.l10n.mustBeValidHexColor,
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
