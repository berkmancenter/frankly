import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:client/features/announcements/data/providers/announcements_provider.dart';
import 'package:client/features/announcements/presentation/views/create_announcement_dialog.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/thick_outline_button.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/announcements/announcement.dart';
import 'package:provider/provider.dart';

class Announcements extends StatefulWidget {
  const Announcements._();

  static Widget create() => ChangeNotifierProvider(
        create: (context) => AnnouncementsProvider(
          communityId: context.read<CommunityProvider>().communityId,
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
        communityId: context.read<CommunityProvider>().communityId,
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
              child: HeightConstrainedText(
                announcement.title ?? 'Announcement',
                style: body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (Provider.of<CommunityPermissionsProvider>(context)
                .canEditCommunity)
              CustomInkWell(
                onTap: () => alertOnError(context, () async {
                  final confirmedDelete = await ConfirmDialog(
                    mainText:
                        'Are you sure you want to delete this announcement?',
                    cancelText: 'No, cancel',
                  ).show();

                  if (confirmedDelete) {
                    await firestoreAnnouncementsService.deleteAnnouncement(
                      communityId: CommunityProvider.read(context).communityId,
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
          child: HeightConstrainedText(
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
      return HeightConstrainedText('No announcements yet.');
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final announcement in announcements)
            _buildAnnouncement(announcement),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsLoading() {
    return CustomStreamBuilder<List<Announcement>>(
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
        HeightConstrainedText(
          'Announcements',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (Provider.of<CommunityPermissionsProvider>(context)
            .canEditCommunity) ...[
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
