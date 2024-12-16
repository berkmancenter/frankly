import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:junto/app/junto/announcements/announcements_provider.dart';
import 'package:junto/app/junto/announcements/create_announcement_dialog.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/thick_outline_button.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/announcement.dart';
import 'package:provider/provider.dart';

class Announcements extends StatefulWidget {
  const Announcements._();

  static Widget create() => ChangeNotifierProvider(
        create: (context) => AnnouncementsProvider(
          juntoId: context.read<JuntoProvider>().juntoId,
        ),
        child: Announcements._(),
      );

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  @override
  void initState() {
    context.read<AnnouncementsProvider>().initialize();

    super.initState();
  }

  Widget _buildCreateAnnouncementButton() {
    return ThickOutlineButton(
      onPressed: () => CreateAnnouncementDialog.show(
        juntoId: context.read<JuntoProvider>().juntoId,
      ),
      text: 'New Announcement',
    );
  }

  Widget _buildAnnouncement(Announcement announcement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: JuntoText(
                announcement.title ?? 'Announcement',
                style: body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (Provider.of<CommunityPermissionsProvider>(context).canEditCommunity)
              JuntoInkWell(
                onTap: () => alertOnError(context, () async {
                  final confirmedDelete = await ConfirmDialog(
                    mainText: 'Are you sure you want to delete this announcement?',
                    cancelText: 'No, cancel',
                  ).show();

                  if (confirmedDelete) {
                    await firestoreAnnouncementsService.deleteAnnouncement(
                      juntoId: JuntoProvider.read(context).juntoId,
                      announcementId: announcement.id!,
                    );
                  }
                }),
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 8),
          child: JuntoText(
            DateFormat('MMM d yyyy, h:mma').format(announcement.createdDate!),
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SelectableLinkify(
          text: announcement.message ?? '',
          textAlign: TextAlign.left,
          style: body.copyWith(
            fontSize: 14,
            color: AppColor.gray3,
          ),
          options: LinkifyOptions(looseUrl: true),
          onOpen: (link) => launch(link.url),
        ),
        SizedBox(height: 25),
      ],
    );
  }

  Widget _buildAnnouncements(List<Announcement> announcements) {
    if (announcements.isEmpty) {
      return JuntoText('No announcements yet.');
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final announcement in announcements) _buildAnnouncement(announcement),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsLoading() {
    return JuntoStreamBuilder<List<Announcement>>(
      stream: Provider.of<AnnouncementsProvider>(context).announcements,
      entryFrom: '_AnnouncementsState._buildAnnouncementsLoading',
      errorMessage: 'There was an error loading announcements.',
      builder: (_, announcements) {
        return _buildAnnouncements(announcements!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JuntoText(
          'Announcements',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (Provider.of<CommunityPermissionsProvider>(context).canEditCommunity) ...[
          SizedBox(height: 16),
          _buildCreateAnnouncementButton(),
        ],
        SizedBox(height: 30),
        Expanded(
          child: _buildAnnouncementsLoading(),
        ),
      ],
    );
  }
}
