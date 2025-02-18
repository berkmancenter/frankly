import 'package:data_models/events/event.dart';
import 'package:data_models/events/pre_post_card.dart';

class PrePostEventDialogModel {
  final PrePostCard prePostCard;
  final Event event;

  PrePostEventDialogModel(this.prePostCard, this.event);
}
