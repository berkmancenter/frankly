import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';

class LiveStreamInstructions extends StatelessWidget {
  const LiveStreamInstructions({this.whiteBackground = true});

  final bool whiteBackground;

  Widget _buildCopyable({
    required BuildContext context,
    required String text,
    required Widget widget,
  }) {
    return JuntoInkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        showRegularToast(context, 'Copied to clipboard!', toastType: ToastType.success);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: widget),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.copy, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return JuntoStreamBuilder<PrivateLiveStreamInfo?>(
      entryFrom: 'LiveStreamInstructions._buildInstructions',
      stream: Stream.fromFuture(DiscussionProvider.watch(context).privateLiveStreamInfo),
      height: 100,
      builder: (context, privateInfo) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JuntoText(
            'Admin Live Stream Setup',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 6),
          JuntoText(
              'When you are ready to start streaming, enter the Stream URL and Stream Key into the '
              'stream settings of your streaming application (i.e. Zoom).'),
          SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              JuntoText(
                'Stream URL:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildCopyable(
                context: context,
                text: privateInfo?.streamServerUrl ?? '',
                widget: JuntoText('${privateInfo?.streamServerUrl}'),
              ),
            ],
          ),
          SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              JuntoText(
                'Stream Key:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildCopyable(
                context: context,
                text: privateInfo?.streamKey ?? '',
                widget: JuntoText(''.padRight(privateInfo?.streamKey?.length ?? 0, '•')),
              ),
            ],
          ),
          SizedBox(height: 6),
          JuntoText(
            'WARNING: Anyone with this stream key can stream content on your stream. Keep it secret.',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JuntoUiMigration(
      whiteBackground: whiteBackground,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: whiteBackground ? AppColor.white : AppColor.darkerBlue,
        ),
        alignment: Alignment.center,
        child: _buildInstructions(context),
      ),
    );
  }
}
