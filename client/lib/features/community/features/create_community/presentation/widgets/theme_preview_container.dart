import 'package:flutter/material.dart';
import 'package:client/features/community/utils/community_theme_utils.dart';
import 'package:client/styles/styles.dart';

/// A widget which displays a mock-up of the chosen primary and secondary colors in the
/// ChooseColorSection of the create / update community dialog
class ThemePreview extends StatelessWidget {
  final String? lightColorString;
  final String? darkColorString;
  final PresetColorTheme? selectedTheme;
  final bool isSelected;
  final void Function()? onTap;

  const ThemePreview({
    this.lightColorString,
    this.darkColorString,
    this.selectedTheme,
    this.isSelected = false,
    this.onTap,
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
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: 162,
        height: 110,
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.theme.colorScheme.primary,
                  width: 1.5,
                ),
              )
            : null,
        child: Container(
          width: 152,
          height: 100,
          decoration: BoxDecoration(
            color: _selectedLightColor(context),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _selectedDarkColor(context),
                ),
                child: null,
              ),
              SizedBox(width: 7),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 50,
                      height: 16,
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
