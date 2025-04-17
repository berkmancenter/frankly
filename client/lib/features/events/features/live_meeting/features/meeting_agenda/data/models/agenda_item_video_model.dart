import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_video.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';

class AgendaItemVideoModel {
  final bool isEditMode;
  final AgendaItemVideoData agendaItemVideoData;
  final void Function(AgendaItemVideoData) onChanged;

  bool shouldBuildVideoWidget = false;
  AgendaItemVideoTabType agendaItemVideoTabType = AgendaItemVideoTabType.local;

  AgendaItemVideoModel(
    this.isEditMode,
    this.agendaItemVideoData,
    this.onChanged,
  );
}
