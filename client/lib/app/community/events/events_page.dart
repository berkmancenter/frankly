import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horizontal_calendar_widget/horizontal_calendar.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/events/create_event/create_event_dialog.dart';
import 'package:client/app/community/events/events_page_provider.dart';
import 'package:client/app/community/home/event_widget.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/empty_page_content.dart';
import 'package:client/common_widgets/custom_list_view.dart';
import 'package:client/common_widgets/custom_stream_builder.dart';
import 'package:client/services/user_data_service.dart';
import 'package:client/services/services.dart';
import 'package:client/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/custom_drag_scroll_behaviour.dart';
import 'package:data_models/firestore/event.dart';
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
    final textStyle = AppTextStyle.eyebrowSmall;
    final dateTextStyle = AppTextStyle.headline2Light.copyWith(height: .9);
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
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
            height: 95,
            spacingBetweenDates: 18.0,
            firstDate: dateTimeNow,
            lastDate: dateTimeNow.add(Duration(days: 90)),
            onDateSelected: Provider.of<EventsPageProvider>(context).setDate,
            onDateUnSelected: (_) =>
                Provider.of<EventsPageProvider>(context, listen: false)
                    .setDate(null),
            selectedDecoration: decoration.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            isDateDisabled: (date) =>
                !Provider.of<EventsPageProvider>(context, listen: false)
                    .dateHasEvent(date),
            defaultDecoration: decoration.copyWith(color: AppColor.white),
            disabledDecoration:
                decoration.copyWith(color: AppColor.gray6.withOpacity(.7)),
            weekDayTextStyle: textStyle.copyWith(color: AppColor.black),
            dateTextStyle: dateTextStyle.copyWith(color: AppColor.black),
            monthTextStyle: textStyle.copyWith(color: AppColor.black),
            selectedMonthTextStyle: textStyle.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            selectedWeekDayTextStyle: textStyle.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            selectedDateTextStyle: dateTextStyle.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBarField() {
    return TextField(
      decoration: InputDecoration(
        fillColor: AppColor.white,
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
        color: AppColor.white,
      ),
      padding: const EdgeInsets.only(left: 12, right: 32),
      constraints: BoxConstraints(maxWidth: 450),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search, color: AppColor.gray1),
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
