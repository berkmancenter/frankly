import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horizontal_calendar_widget/horizontal_calendar.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/discussions/discussions_page_provider.dart';
import 'package:junto/app/junto/home/discussion_widget.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/empty_page_content.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_drag_scroll_behaviour.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:provider/provider.dart';

class DiscussionsPage extends StatefulWidget {
  const DiscussionsPage._();

  static Widget create() {
    return Consumer<UserService>(
      builder: (_, userService, __) => ChangeNotifierProvider(
        key: Key(userService.currentUserId!),
        create: (context) => DiscussionsPageProvider(
          juntoId: context.read<JuntoProvider>().juntoId,
        ),
        child: DiscussionsPage._(),
      ),
    );
  }

  @override
  _DiscussionsPageState createState() => _DiscussionsPageState();
}

class _DiscussionsPageState extends State<DiscussionsPage> {
  bool get isAdmin => Provider.of<JuntoUserDataService>(context)
      .getMembership(Provider.of<JuntoProvider>(context).juntoId)
      .isAdmin;

  @override
  void initState() {
    context.read<DiscussionsPageProvider>().initialize();
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
                  ConstrainedBody.outerPadding),
        );
        return ScrollConfiguration(
          behavior: JuntoDragScrollBehavior(),
          child: HorizontalCalendar(
            listViewPadding: padding,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            height: 95,
            spacingBetweenDates: 18.0,
            firstDate: dateTimeNow,
            lastDate: dateTimeNow.add(Duration(days: 90)),
            onDateSelected: Provider.of<DiscussionsPageProvider>(context).setDate,
            onDateUnSelected: (_) =>
                Provider.of<DiscussionsPageProvider>(context, listen: false).setDate(null),
            selectedDecoration: decoration.copyWith(color: Theme.of(context).colorScheme.primary),
            isDateDisabled: (date) => !Provider.of<DiscussionsPageProvider>(context, listen: false)
                .dateHasDiscussion(date),
            defaultDecoration: decoration.copyWith(color: AppColor.white),
            disabledDecoration: decoration.copyWith(color: AppColor.gray6.withOpacity(.7)),
            weekDayTextStyle: textStyle.copyWith(color: AppColor.black),
            dateTextStyle: dateTextStyle.copyWith(color: AppColor.black),
            monthTextStyle: textStyle.copyWith(color: AppColor.black),
            selectedMonthTextStyle:
                textStyle.copyWith(color: Theme.of(context).colorScheme.secondary),
            selectedWeekDayTextStyle:
                textStyle.copyWith(color: Theme.of(context).colorScheme.secondary),
            selectedDateTextStyle:
                dateTextStyle.copyWith(color: Theme.of(context).colorScheme.secondary),
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
      onChanged: context.read<DiscussionsPageProvider>().onSearchChanged,
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
      JuntoStreamBuilder(
        entryFrom: '_DiscussionsPageState._buildFilteringSectionWidgets',
        stream: Provider.of<DiscussionsPageProvider>(context).discussionsStream,
        height: 100,
        builder: (_, topic) => ConstrainedBody(
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

  Widget _buildDiscussions() {
    return JuntoStreamBuilder<List<Discussion>>(
      stream: Provider.of<DiscussionsPageProvider>(context).discussionsStream,
      entryFrom: '_DiscussionsPageState._buildDiscussions',
      height: 100,
      builder: (_, __) {
        final discussions = Provider.of<DiscussionsPageProvider>(context).filteredDiscussions ?? [];

        if (discussions.isEmpty) {
          final canCreateEvent = context.watch<CommunityPermissionsProvider>().canCreateEvent;
          return Column(
            children: [
              SizedBox(height: 30),
              EmptyPageContent(
                type: EmptyPageType.events,
                showContainer: false,
                onButtonPress: canCreateEvent ? () => CreateDiscussionDialog.show(context) : null,
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
            for (final discussion in discussions.take(100)) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 700),
                  child: DiscussionWidget(
                    discussion,
                    key: Key('discussion-${discussion.id}'),
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
    return JuntoListView(
      children: [
        SizedBox(height: 30),
        ..._buildFilteringSectionWidgets(),
        SizedBox(height: 18),
        ConstrainedBody(child: _buildDiscussions()),
        SizedBox(height: 100),
      ],
    );
  }
}
