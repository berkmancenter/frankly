import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/user_suggestions/agenda_item_user_suggestions_data.dart';

class AgendaItemUserSuggestionsModel {
  final bool isEditMode;
  final AgendaItemUserSuggestionsData agendaItemUserSuggestionsData;
  final void Function(AgendaItemUserSuggestionsData) onChanged;

  AgendaItemUserSuggestionsModel(
    this.isEditMode,
    this.agendaItemUserSuggestionsData,
    this.onChanged,
  );
}
