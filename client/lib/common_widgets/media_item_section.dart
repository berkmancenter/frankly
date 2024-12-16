import 'package:dotted_border/dotted_border.dart' as dotted_border;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_stream/url_video_widget.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/services/media_helper_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/media_item.dart';

class MediaItemSection extends StatelessWidget {
  final MediaItem? mediaItem;
  final void Function() onDelete;
  final void Function(MediaItem) onUpdate;

  const MediaItemSection({
    Key? key,
    required this.mediaItem,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  Future<void> _showMediaPickerDialog(BuildContext context) async {
    final mediaUrl = await GetIt.instance<MediaHelperService>().pickMediaViaCloudinary(
      uploadPreset: MediaHelperService.defaultMediaPreset,
    );

    if (mediaUrl != null) {
      final isVideo = MediaHelperService.allowedVideoFormats.any((ext) => mediaUrl.endsWith(ext));
      final mediaItem = MediaItem(url: mediaUrl, type: isVideo ? MediaType.video : MediaType.image);
      onUpdate(mediaItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    const _kDashBorderColor = Color(0xff757584);
    const _kDashPattern = <double>[10, 10];
    const _kMediaSectionSize = Size(150, 100);

    final localMediaItem = mediaItem;

    if (localMediaItem == null) {
      return dotted_border.DottedBorder(
        color: _kDashBorderColor,
        dashPattern: _kDashPattern,
        child: JuntoInkWell(
          onTap: () => _showMediaPickerDialog(context),
          child: Container(
            color: AppColor.gray6,
            child: Row(
              children: [
                SizedBox.fromSize(
                  size: _kMediaSectionSize,
                  child: Container(
                    color: AppColor.darkBlue,
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: AppColor.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: JuntoText(
                      'Add video or Image',
                      style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return dotted_border.DottedBorder(
        color: _kDashBorderColor,
        dashPattern: _kDashPattern,
        child: Row(
          children: [
            SizedBox.fromSize(
              size: _kMediaSectionSize,
              child: _buildMediaPreview(localMediaItem),
            ),
            Spacer(),
            Material(
              color: AppColor.darkBlue,
              shape: CircleBorder(),
              child: InkWell(
                customBorder: CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.edit, size: 20, color: AppColor.white),
                ),
                onTap: () => _showMediaPickerDialog(context),
              ),
            ),
            SizedBox(width: 20),
            Material(
              color: AppColor.darkBlue,
              shape: CircleBorder(),
              child: InkWell(
                customBorder: CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.delete, size: 20, color: AppColor.white),
                ),
                onTap: () {
                  ConfirmDialog(
                    title: 'Are you sure you want to delete media?',
                    onConfirm: (_) {
                      Navigator.pop(context);
                      onDelete();
                    },
                  ).show();
                },
              ),
            ),
            SizedBox(width: 40),
          ],
        ),
      );
    }
  }

  Widget _buildMediaPreview(MediaItem mediaItem) {
    switch (mediaItem.type) {
      case MediaType.image:
        return JuntoImage(mediaItem.url, fit: BoxFit.cover);
      case MediaType.video:
        return UrlVideoWidget(
          playbackUrl: mediaItem.url,
          autoplay: false,
        );
    }
  }
}
