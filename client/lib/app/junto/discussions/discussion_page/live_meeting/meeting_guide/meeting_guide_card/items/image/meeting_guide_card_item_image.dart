import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto_models/firestore/discussion.dart';

class MeetingGuideCardItemImage extends StatelessWidget {
  final AgendaItem agendaItem;

  const MeetingGuideCardItemImage({Key? key, required this.agendaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: JuntoImage(
        agendaItem.imageUrl,
        fit: BoxFit.none,
      ),
    );
  }
}
