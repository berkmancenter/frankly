import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
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
    return ActionButton(
      type: ActionButtonType.outline,
      expand: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      contentAlign: ActionButtonContentAlignment.start,
      onPressed: onPressed,
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
            style: context.theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
