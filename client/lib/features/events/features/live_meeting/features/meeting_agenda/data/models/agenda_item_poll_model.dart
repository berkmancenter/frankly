import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_data.dart';

class AgendaItemPollModel {
  final bool isEditMode;
  final AgendaItemPollData agendaItemPollData;
  final void Function(AgendaItemPollData) onChanged;

  int pollStateKey = 0;

  AgendaItemPollModel(this.isEditMode, this.agendaItemPollData, this.onChanged);
}
