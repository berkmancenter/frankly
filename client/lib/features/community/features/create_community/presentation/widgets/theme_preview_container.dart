import 'package:flutter/material.dart';
import 'package:client/features/community/utils/community_theme_utils.dart.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

/// A widget which displays a mock-up of the chosen primary and secondary colors in the
/// ChooseColorSection of the create / update community dialog
class ThemePreview extends StatelessWidget {
  final String? lightColorString;
  final String? darkColorString;
  final PresetColorTheme? selectedTheme;
  final bool isSelected;
  final void Function()? onTap;
  final bool compact;

  const ThemePreview({
    this.lightColorString,
    this.darkColorString,
    this.selectedTheme,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: _buildPreviewContainer(context),
      ),
    );
  }

  Color _selectedDarkColor(BuildContext context) =>
      selectedTheme?.darkColor ??
      ThemeUtils.parseColor(darkColorString) ??
      context.theme.colorScheme.primary;

  Color _selectedLightColor(BuildContext context) =>
      selectedTheme?.lightColor ??
      ThemeUtils.parseColor(lightColorString) ??
      context.theme.colorScheme.surface;

  Widget _buildPreviewContainer(BuildContext context) {
    // Rounding up is not allowed, e.g. 4.47 != 4.5
    final contrastString = ((ThemeUtils.calculateContrastRatio(
                      _selectedLightColor(context),
                      _selectedDarkColor(context),
                    ) *
                    10)
                .floor() *
            .1)
        .toStringAsFixed(1);

    final showContrastRatio = ThemeUtils.isColorValid(lightColorString) ||
        ThemeUtils.isColorValid(darkColorString);

    return Align(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        width: compact ? 162 : null,
        height: compact ? 110 : null,
        decoration: (compact && isSelected)
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.accentBlue, width: 1.5),
              )
            : null,
        child: Container(
          width: compact ? 152 : 215,
          height: compact ? 100 : 141,
          decoration: BoxDecoration(
            color: _selectedLightColor(context),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: compact
              ? const EdgeInsets.symmetric(vertical: 20, horizontal: 18)
              : const EdgeInsets.symmetric(vertical: 30, horizontal: 28),
          child: Row(
            children: [
              Container(
                alignment: Alignment.center,
                height: compact ? 58 : 82,
                width: compact ? 58 : 82,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _selectedDarkColor(context),
                ),
                child: showContrastRatio
                    ? HeightConstrainedText(
                        contrastString,
                        style: AppTextStyle.eyebrow
                            .copyWith(color: _selectedLightColor(context)),
                      )
                    : null,
              ),
              SizedBox(width: 7),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: compact ? 50 : 70,
                      height: compact ? 16 : 23,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
