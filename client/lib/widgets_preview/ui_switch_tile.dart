import 'package:flutter/material.dart';
import 'package:junto/styles/app_styles.dart';

class UiSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final void Function(bool) onChanged;

  const UiSwitchTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: AppTextStyle.body,
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
