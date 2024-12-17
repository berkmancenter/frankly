import 'package:flutter/material.dart';
import 'package:client/app/community/events/event_page/live_meeting/leave_regular_dialog.dart';
import 'package:client/styles/app_styles.dart';
import 'package:data_models/community/community.dart';

class LeaveRegularDialogPreview extends StatelessWidget {
  final Community? community;
  final void Function()? onFollowTap;
  final void Function()? onCloseTap;

  const LeaveRegularDialogPreview({
    Key? key,
    this.community,
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
                      community: community,
                      isMember: community != null,
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
