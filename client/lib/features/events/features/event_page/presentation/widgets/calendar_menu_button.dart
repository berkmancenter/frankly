import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

enum CalendarMenuSelection {
  google,
  outlook,
  office365,
  ical,
}

class CalendarMenuButton extends StatefulWidget {
  final void Function(CalendarMenuSelection) onSelected;

  const CalendarMenuButton({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<CalendarMenuButton> createState() => _CalendarMenuButtonState();
}

class _CalendarMenuButtonState extends State<CalendarMenuButton> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!_isHovered) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (_isHovered) {
          setState(() => _isHovered = false);
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _isHovered ? AppColor.grayHoverColor : null,
        ),
        child: TooltipTheme(
          data: TooltipThemeData(
            decoration: BoxDecoration(color: Colors.transparent),
          ),
          child: PopupMenuButton<CalendarMenuSelection>(
            padding: EdgeInsets.zero,
            offset: Offset(0, 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (value) => widget.onSelected(value),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.calendar_badge_plus,
                  size: 20,
                  color: AppColor.gray3,
                ),
                SizedBox(width: 10),
                HeightConstrainedText(
                  'Add to calendar',
                  style: AppTextStyle.body.copyWith(color: AppColor.gray3),
                ),
              ],
            ),
            itemBuilder: (context) {
              return CalendarMenuSelection.values.map(
                (e) {
                  final text = _getText(e);
                  return PopupMenuItem(
                    value: e,
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 100,
                      child: HeightConstrainedText(
                        text,
                        style: AppTextStyle.bodyMedium
                            .copyWith(color: AppColor.darkBlue),
                      ),
                    ),
                  );
                },
              ).toList();
            },
          ),
        ),
      ),
    );
  }

  String _getText(CalendarMenuSelection calendarMenuSelection) {
    switch (calendarMenuSelection) {
      case CalendarMenuSelection.google:
        return 'Google ';
      case CalendarMenuSelection.outlook:
        return 'Outlook';
      case CalendarMenuSelection.office365:
        return 'Office 365';
      case CalendarMenuSelection.ical:
        return 'iCal';
    }
  }
}
