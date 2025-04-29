import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';

class MeetingGuideCardItemText extends StatelessWidget {
  final AgendaItem agendaItem;

  const MeetingGuideCardItemText({
    Key? key,
    required this.agendaItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: (agendaItem.content ?? '').replaceAll('\n', '\n\n'),
      shrinkWrap: true,
      selectable: true,
      styleSheet: _computeUpdatedStyleSheet(context),
      onTapLink: (text, href, _) => launch(href ?? ''),
    );
  }

  /// Update the default text sizes to be larger for text cards.
  ///
  /// If the content is sufficiently short, then make bodyText much larger.
  /// Otherwise, update the size of all TextStyles with in the TextTheme to be larger.
  MarkdownStyleSheet _computeUpdatedStyleSheet(BuildContext context) {
    TextTheme newTextTheme = Theme.of(context).textTheme;
    if (!responsiveLayoutService.isMobile(context)) {
      if ((agendaItem.content ?? '').length < 77) {
        newTextTheme = newTextTheme.copyWith(
          bodyLarge: newTextTheme.bodyLarge?.copyWith(fontSize: 30),
          bodyMedium: newTextTheme.bodyMedium?.copyWith(fontSize: 30),
        );
      } else {
        const defaultLargerBodyTextSize = 18.0;
        final currentBodyTextSize = newTextTheme.bodyMedium?.fontSize ?? 16;
        newTextTheme = newTextTheme.apply(
          fontSizeFactor: defaultLargerBodyTextSize / currentBodyTextSize,
        );
      }
    }
    return MarkdownStyleSheet.fromTheme(
      Theme.of(context).copyWith(
        textTheme: newTextTheme,
      ),
    );
  }
}
