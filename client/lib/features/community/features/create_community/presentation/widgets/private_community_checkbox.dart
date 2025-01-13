import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class PrivateCommunityCheckbox extends StatelessWidget {
  final void Function(bool?) onUpdate;
  final bool value;

  const PrivateCommunityCheckbox({
    required this.value,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FormBuilderCheckbox(
            name: 'is_private',
            title: HeightConstrainedText(
              'Make this space private',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            contentPadding: EdgeInsets.zero,
            onChanged: onUpdate,
            initialValue: value,
            checkColor: AppColor.white,
            activeColor: AppColor.darkBlue,
            decoration: InputDecoration(
              fillColor: AppColor.white,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}
