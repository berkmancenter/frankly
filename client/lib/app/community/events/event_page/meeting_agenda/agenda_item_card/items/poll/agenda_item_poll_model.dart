import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_data.dart';

class AgendaItemPollModel {
  final bool isEditMode;
  final AgendaItemPollData agendaItemPollData;
  final void Function(AgendaItemPollData) onChanged;

  int pollStateKey = 0;

  AgendaItemPollModel(this.isEditMode, this.agendaItemPollData, this.onChanged);
}
