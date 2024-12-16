import 'package:data_models/firestore/event.dart';

class EditEventModel {
  late Event event;
  late final Event initialEvent;
  bool? isFeatured;
  bool? initialFeatured;

  EditEventModel();
}
