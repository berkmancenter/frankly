import 'package:flutter/material.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.title,
    required this.body,
    this.expanded = false,
    Key? key,
  }) : super(key: key);

  final String title;
  final Widget body;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: _buildExpansionTile(),
    );
  }

  Widget _buildExpansionTile() {
    return ExpansionTile(
      initiallyExpanded: expanded,
      backgroundColor: AppColor.darkBlue,
      collapsedBackgroundColor: AppColor.darkBlue,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: HeightConstrainedText(
          title,
          style: AppTextStyle.subhead.copyWith(color: AppColor.white),
        ),
      ),
      iconColor: AppColor.white,
      collapsedIconColor: AppColor.white,
      children: [
        body,
      ],
    );
  }
}
