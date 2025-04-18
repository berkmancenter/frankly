import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class AppRadioListTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String text;
  final void Function(T) onChanged;

  const AppRadioListTile({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.text,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
          SizedBox(width: 8),
          Flexible(
            child: HeightConstrainedText(
              text,
              style: AppTextStyle.body
                  .copyWith(color: Theme.of(context).colorScheme.primary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
