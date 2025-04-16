import 'package:client/features/community/utils/community_theme_utils.dart.dart';
import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_card.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/add_more_button.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class MeetingAgendaWrapper extends StatelessWidget {
  const MeetingAgendaWrapper({
    required this.communityId,
    this.event,
    this.template,
    this.allowButtonForUserSubmittedAgenda = true,
    this.agendaStartsCollapsed = false,
    this.saveNotifier,
    this.backgroundColor = AppColor.darkerBlue,
    this.labelColor,
    this.isLivestream = false,
    this.child,
    Key? key,
  }) : super(key: key);

  final String communityId;
  final Event? event;
  final Template? template;
  final bool allowButtonForUserSubmittedAgenda;
  final SubmitNotifier? saveNotifier;
  final Color backgroundColor;
  final Color? labelColor;
  final bool isLivestream;
  final bool agendaStartsCollapsed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final params = AgendaProviderParams(
      communityId: communityId,
      event: event,
      template: template,
      isNotOnEventPage: EventProvider.readOrNull(context) == null,
      allowButtonForUserSubmittedAgenda: allowButtonForUserSubmittedAgenda,
      agendaStartsCollapsed: agendaStartsCollapsed,
      saveNotifier: saveNotifier,
      backgroundColor: backgroundColor,
      isLivestream: isLivestream,
      labelColor: labelColor,
    );
    return ChangeNotifierProxyProvider0<AgendaProvider>(
      create: (context) => AgendaProvider(
        liveMeetingProvider: LiveMeetingProvider.readOrNull(context),
        params: params,
      )..initialize(),
      update: (context, currentProvider) => currentProvider!..update(params),
      builder: (context, __) =>
          child ??
          MeetingAgenda(
            canUserEditAgenda: false,
          ),
    );
  }
}

class MeetingAgenda extends StatefulWidget {
  final bool canUserEditAgenda;

  const MeetingAgenda({
    Key? key,
    required this.canUserEditAgenda,
  }) : super(key: key);

  @override
  State<MeetingAgenda> createState() => _MeetingAgendaState();
}

class _MeetingAgendaState extends State<MeetingAgenda> {
  AgendaProvider get _agendaProvider => Provider.of<AgendaProvider>(context);

  Widget _buildAgendaItem({required AgendaItem item}) {
    return AgendaItemCard(agendaItem: item);
  }

  bool get canEditAgenda {
    final isInBreakouts =
        LiveMeetingProvider.watchOrNull(context)?.isInBreakout == true;
    return widget.canUserEditAgenda && !isInBreakouts;
  }

  Widget _buildAgendaList(BuildContext context) {
    final agendaProvider = context.watch<AgendaProvider>();
    final hasAnyUnsavedItems = agendaProvider.unsavedItems.isNotEmpty;

    final allAgendaItems = [
      ..._agendaProvider.agendaItems,
      ..._agendaProvider.unsavedItems,
    ];

    return ReorderableList(
      onReorder: (draggedKey, newPositionKey) {
        final draggedIndex = agendaProvider.agendaItems
            .indexWhere((item) => Key(item.id) == draggedKey);
        final newPositionIndex = agendaProvider.agendaItems
            .indexWhere((item) => Key(item.id) == newPositionKey);

        if (draggedIndex >= 0 && newPositionIndex >= 0) {
          final newPositionItem = agendaProvider.agendaItems[newPositionIndex];
          final isLocked = agendaProvider.isCompleted(newPositionItem.id) ||
              agendaProvider.isCurrentAgendaItem(newPositionItem.id);
          if (!isLocked) {
            setState(() {
              final removed = agendaProvider.agendaItems.removeAt(draggedIndex);
              agendaProvider.agendaItems.insert(newPositionIndex, removed);
            });
            return true;
          }
        }

        return false;
      },
      onReorderDone: (_) =>
          alertOnError(context, () => agendaProvider.saveReorder()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (allAgendaItems.isEmpty)
            HeightConstrainedText(
              'There is no agenda for this event.',
              style: TextStyle(
                color:
                    Theme.of(context).isDark ? AppColor.white : AppColor.gray2,
              ),
            ),
          for (int i = 0; i < allAgendaItems.length; i++) ...[
            _buildAgendaItem(
              item: allAgendaItems[i],
            ),
            SizedBox(height: 20),
          ],
          if (canEditAgenda && !hasAnyUnsavedItems) ...[
            SizedBox(height: 20),
            AddMoreButton(
              isWhiteBackground: true,
              label: context.l10n.addAgendaItem,
              onPressed: () => agendaProvider.addNewUnsavedItem(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildAgendaList(context);
  }
}
