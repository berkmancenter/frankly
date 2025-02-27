import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';

class LiveStreamInstructions extends StatelessWidget {
  const LiveStreamInstructions({this.whiteBackground = true});

  final bool whiteBackground;

  Widget _buildCopyable({
    required BuildContext context,
    required String text,
    required Widget widget,
  }) {
    return CustomInkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        showRegularToast(
          context,
          'Copied to clipboard!',
          toastType: ToastType.success,
        );
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
    return CustomStreamBuilder<PrivateLiveStreamInfo?>(
      entryFrom: 'LiveStreamInstructions._buildInstructions',
      stream: Stream.fromFuture(
        EventProvider.watch(context).privateLiveStreamInfo,
      ),
      height: 100,
      builder: (context, privateInfo) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeightConstrainedText(
            'Admin Live Stream Setup',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 6),
          HeightConstrainedText(
              'When you are ready to start streaming, enter the Stream URL and Stream Key into the '
              'stream settings of your streaming application (i.e. Zoom).'),
          SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              HeightConstrainedText(
                'Stream URL:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildCopyable(
                context: context,
                text: privateInfo?.streamServerUrl ?? '',
                widget:
                    HeightConstrainedText('${privateInfo?.streamServerUrl}'),
              ),
            ],
          ),
          SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              HeightConstrainedText(
                'Stream Key:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildCopyable(
                context: context,
                text: privateInfo?.streamKey ?? '',
                widget: HeightConstrainedText(
                  ''.padRight(privateInfo?.streamKey?.length ?? 0, '•'),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          HeightConstrainedText(
            'WARNING: Anyone with this stream key can stream content on your stream. Keep it secret.',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: whiteBackground ? AppColor.white : AppColor.darkerBlue,
      ),
      alignment: Alignment.center,
      child: _buildInstructions(context),
    );
  }
}
