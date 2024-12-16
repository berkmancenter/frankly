import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/leave_regular_dialog.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto_models/firestore/junto.dart';

class LeaveRegularDialogPreview extends StatelessWidget {
  final Junto? junto;
  final void Function()? onFollowTap;
  final void Function()? onCloseTap;

  const LeaveRegularDialogPreview({
    Key? key,
    this.junto,
    this.onFollowTap,
    this.onCloseTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(child: Container(color: AppColor.black)),
                  Expanded(child: Container(color: Colors.blue)),
                  Expanded(child: Container(color: Colors.red)),
                  Expanded(child: Container(color: Colors.lightGreen)),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: LeaveRegularDialog(
                      junto: junto,
                      isMember: junto != null,
                      onMinimizeCard: () {},
                    ),
                  ),
                  Expanded(child: Container(color: Colors.orange)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
