import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class AddMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AddMoreButton({
    Key? key,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.theme.colorScheme.outline,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: ShapeDecoration(
                color: context.theme.colorScheme.primary,
                shape: CircleBorder(),
              ),
              child: Icon(
                Icons.add,
                size: 12,
                color: context.theme.colorScheme.onPrimary,
              ),
            ),
            SizedBox(width: 12),
            HeightConstrainedText(
              label,
              style: AppTextStyle.subhead,
            ),
          ],
        ),
      ),
    );
  }
}
