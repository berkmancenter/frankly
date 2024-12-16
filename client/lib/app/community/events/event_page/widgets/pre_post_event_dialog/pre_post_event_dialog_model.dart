import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/pre_post_card.dart';

class PrePostEventDialogModel {
  final PrePostCard prePostCard;
  final Event event;

  PrePostEventDialogModel(this.prePostCard, this.event);
}
