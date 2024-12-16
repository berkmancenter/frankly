import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_data.dart';

class AgendaItemImageModel {
  final bool isEditMode;
  final AgendaItemImageData agendaItemImageData;
  final void Function(AgendaItemImageData) onChanged;

  AgendaItemImageModel(this.isEditMode, this.agendaItemImageData, this.onChanged);
}
