import 'dart:math';

import 'package:client/core/widgets/constrained_body.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_calendar_widget/horizontal_calendar.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/create_event/presentation/views/create_event_dialog.dart';
import 'package:client/features/events/data/providers/events_page_provider.dart';
import 'package:client/features/community/presentation/widgets/event_widget.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/styles.dart';
import 'package:client/features/events/presentation/widgets/custom_drag_scroll_behaviour.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';

class EventsPage extends StatefulWidget {
  const EventsPage._();

  static Widget create() {
    return Consumer<UserService>(
      builder: (_, userService, __) => ChangeNotifierProvider(
        key: Key(userService.currentUserId!),
        create: (context) => EventsPageProvider(
          communityId: context.read<CommunityProvider>().communityId,
        ),
        child: EventsPage._(),
      ),
    );
  }

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool get isAdmin => Provider.of<UserDataService>(context)
      .getMembership(Provider.of<CommunityProvider>(context).communityId)
      .isAdmin;

  @override
  void initState() {
    context.read<EventsPageProvider>().initialize();
    super.initState();
  }

  Widget _buildCalendar() {
    final dateTimeNow = clockService.now();
    final labelTextStyle = context.theme.textTheme.titleSmall!;
    final dateNumberTextStyle = context.theme.textTheme.headlineLarge!;
    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: context.theme.colorScheme.surfaceContainerLowest,
    );
    return LayoutBuilder(
      builder: (_, constraints) {
        final padding = EdgeInsets.symmetric(
          vertical: 4,
          horizontal: max(
            ConstrainedBody.outerPadding,
            (constraints.biggest.width - ConstrainedBody.defaultMaxWidth) / 2 +
                ConstrainedBody.outerPadding,
          ),
        );
        return ScrollConfiguration(
          behavior: CustomDragScrollBehavior(),
          child: HorizontalCalendar(
            listViewPadding: padding,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            spacingBetweenDates: 18.0,
            firstDate: dateTimeNow,
            lastDate: dateTimeNow.add(Duration(days: 90)),
            onDateSelected: Provider.of<EventsPageProvider>(context).setDate,
            onDateUnSelected: (_) =>
                Provider.of<EventsPageProvider>(context, listen: false)
                    .setDate(null),
            defaultDecoration: boxDecoration,
            disabledDecoration: boxDecoration.copyWith(
              color: context.theme.colorScheme.surfaceContainer,
            ),
            selectedDecoration: boxDecoration.copyWith(
              color: context.theme.colorScheme.primary,
            ),
            isDateDisabled: (date) =>
                !Provider.of<EventsPageProvider>(context, listen: false)
                    .dateHasEvent(date),
            weekDayTextStyle: labelTextStyle.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
            dateTextStyle: dateNumberTextStyle.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
            monthTextStyle: labelTextStyle.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
            selectedMonthTextStyle: labelTextStyle.copyWith(
              color: context.theme.colorScheme.onPrimary,
            ),
            selectedWeekDayTextStyle: labelTextStyle.copyWith(
              color: context.theme.colorScheme.onPrimary,
            ),
            selectedDateTextStyle: dateNumberTextStyle.copyWith(
              color: context.theme.colorScheme.onPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBarField() {
    return TextField(
      decoration: InputDecoration(
        fillColor: context.theme.colorScheme.surfaceContainerLowest,
        hintText: 'Search events',
        border: InputBorder.none,
      ),
      onChanged: context.read<EventsPageProvider>().onSearchChanged,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.theme.colorScheme.surfaceContainerLowest,
      ),
      padding: const EdgeInsets.only(left: 12, right: 32),
      constraints: BoxConstraints(maxWidth: 450),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child:
                Icon(Icons.search, color: context.theme.colorScheme.onSurface),
          ),
          Expanded(
            child: _buildSearchBarField(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteringSectionWidgets() {
    return [
      CustomStreamBuilder(
        entryFrom: '_EventsPageState._buildFilteringSectionWidgets',
        stream: Provider.of<EventsPageProvider>(context).eventsStream,
        height: 100,
        builder: (_, template) => ConstrainedBody(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildSearchBar(),
                ),
              ],
            ),
          ),
        ),
      ),
      _buildCalendar(),
    ];
  }

  Widget _buildEvents() {
    return CustomStreamBuilder<List<Event>>(
      stream: Provider.of<EventsPageProvider>(context).eventsStream,
      entryFrom: '_EventsPageState._buildEvents',
      height: 100,
      builder: (_, __) {
        final events =
            Provider.of<EventsPageProvider>(context).filteredEvents ?? [];

        if (events.isEmpty) {
          final canCreateEvent =
              context.watch<CommunityPermissionsProvider>().canCreateEvent;
          return Column(
            children: [
              SizedBox(height: 30),
              EmptyPageContent(
                type: EmptyPageType.events,
                showContainer: false,
                onButtonPress: canCreateEvent
                    ? () => CreateEventDialog.show(context)
                    : null,
                isBackgroundPrimaryColor: true,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            for (final event in events.take(100)) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 700),
                  child: EventWidget(
                    event,
                    key: Key('event-${event.id}'),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomListView(
      children: [
        SizedBox(height: 30),
        ..._buildFilteringSectionWidgets(),
        SizedBox(height: 18),
        ConstrainedBody(child: _buildEvents()),
        SizedBox(height: 100),
      ],
    );
  }
}
