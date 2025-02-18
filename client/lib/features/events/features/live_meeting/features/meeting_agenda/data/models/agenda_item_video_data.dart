import 'package:data_models/events/event.dart';

class AgendaItemVideoData {
  String title;
  AgendaItemVideoType type;
  String url;

  AgendaItemVideoData(this.title, this.type, this.url);

  AgendaItemVideoData.newItem()
      : title = '',
        type = AgendaItemVideoType.url,
        url = '';

  bool isNew() {
    return title.isEmpty && type == AgendaItemVideoType.url && url.isEmpty;
  }
}
