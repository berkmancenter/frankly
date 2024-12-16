import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_data.dart';

class AgendaItemVideoModel {
  final bool isEditMode;
  final AgendaItemVideoData agendaItemVideoData;
  final void Function(AgendaItemVideoData) onChanged;

  bool shouldBuildVideoWidget = false;
  AgendaItemVideoTabType agendaItemVideoTabType = AgendaItemVideoTabType.local;

  AgendaItemVideoModel(this.isEditMode, this.agendaItemVideoData, this.onChanged);
}
