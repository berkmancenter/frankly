import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_image_data.dart';

class AgendaItemImageModel {
  final bool isEditMode;
  final AgendaItemImageData agendaItemImageData;
  final void Function(AgendaItemImageData) onChanged;

  AgendaItemImageModel(
    this.isEditMode,
    this.agendaItemImageData,
    this.onChanged,
  );
}
