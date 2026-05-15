import 'package:client/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/localization/localization_helper.dart';

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
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CalendarMenuSelection>(
      padding: EdgeInsets.zero,
      offset: Offset(0, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (value) => widget.onSelected(value),
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: context.theme.colorScheme.surfaceContainerLowest,
          ),
          foregroundColor: context.theme.colorScheme.onSurfaceVariant,
          minimumSize: Size(96, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                CupertinoIcons.calendar_badge_plus,
                size: 20,
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
            HeightConstrainedText(
              context.l10n.addToCalendar,
              style: context.theme.textTheme.bodyMedium!.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
                  style: context.theme.textTheme.bodyLarge,
                ),
              ),
            );
          },
        ).toList();
      },
    );
  }

  String _getText(CalendarMenuSelection calendarMenuSelection) {
    switch (calendarMenuSelection) {
      case CalendarMenuSelection.google:
        return context.l10n.googleCalendar;
      case CalendarMenuSelection.outlook:
        return context.l10n.outlookCalendar;
      case CalendarMenuSelection.office365:
        return context.l10n.office365Calendar;
      case CalendarMenuSelection.ical:
        return context.l10n.iCalCalendar;
    }
  }
}
