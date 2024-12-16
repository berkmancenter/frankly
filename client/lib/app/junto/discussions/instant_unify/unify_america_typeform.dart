import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/participant_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/typeform_widget.dart';
import 'package:junto/app/junto/discussions/instant_unify/unify_america_controller.dart';

class UnifyAmericaTypeform extends StatelessWidget {
  const UnifyAmericaTypeform();

  @override
  Widget build(BuildContext context) {
    final unifyAmericaController = UnifyAmericaController.watch(context)!;
    return RepaintBoundary(
      child: GlobalKeyedSubtree(
        label: 'unify-america-typeform',
        child: TypeformWidget(
          typeformLink: unifyAmericaController.typeformLink,
        ),
      ),
    );
  }
}
