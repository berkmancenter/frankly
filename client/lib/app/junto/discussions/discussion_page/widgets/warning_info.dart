import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/styles/app_styles.dart';

class WarningInfo extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? message;

  const WarningInfo({
    Key? key,
    required this.icon,
    required this.title,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColor.pink,
      ),
      child: Center(
        child: JuntoUiMigration(
          whiteBackground: true,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              icon,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Builder(
                  builder: (context) => RichText(
                    text: TextSpan(
                      text: '$title  ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColor.redLightMode, fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                          text: message,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
