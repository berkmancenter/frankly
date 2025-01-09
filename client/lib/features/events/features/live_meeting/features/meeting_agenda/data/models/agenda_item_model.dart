import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_image_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_text_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_user_suggestions_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_word_cloud_data.dart';
import 'package:data_models/events/event.dart';

class AgendaItemModel {
  AgendaItem agendaItem;

  bool isEditMode = false;
  int timeInSeconds = AgendaItem.kDefaultTimeInSeconds;
  late AgendaItemTextData agendaItemTextData;
  late AgendaItemVideoData agendaItemVideoData;
  late AgendaItemImageData agendaItemImageData;
  late AgendaItemPollData agendaItemPollData;
  late AgendaItemWordCloudData agendaItemWordCloudData;
  late AgendaItemUserSuggestionsData agendaItemUserSuggestionsData;

  AgendaItemModel(this.agendaItem);
}
