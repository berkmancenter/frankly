import 'package:flutter/material.dart';
import 'package:client/common_widgets/proxied_image.dart';
import 'package:data_models/firestore/event.dart';

class MeetingGuideCardItemImage extends StatelessWidget {
  final AgendaItem agendaItem;

  const MeetingGuideCardItemImage({Key? key, required this.agendaItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ProxiedImage(
        agendaItem.imageUrl,
        fit: BoxFit.none,
      ),
    );
  }
}
