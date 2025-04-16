import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_user_suggestions_data.dart';

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
