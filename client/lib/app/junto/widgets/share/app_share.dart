import 'dart:math';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/widgets/share/share_section.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/analytics/share_type.dart';

class AppShareData {
  /// Indicates page path.
  ///
  /// If [pathToPage] is not provided, it will be generated to default to current page.
  late String pathToPage;
  final String subject;
  final String body;
  final String? juntoId;

  AppShareData({
    required this.subject,
    required this.body,
    String? pathToPage,
    this.juntoId,
  }) {
    this.pathToPage = pathToPage == null
        ? _getPathUrl(routerDelegate.currentConfiguration?.location.toString() ?? '')
        : _getPathUrl(pathToPage);
  }

  /// Generates default sharing url.
  String _getPathUrl(String pathToPage) {
    final domain = isDev ? 'gen-hls-bkc-7627.web.app' : 'app.frankly.org';
    return 'https://$domain/share$pathToPage';
  }
}

class AppShareDialog extends StatefulWidget {
  final String? title;
  final String content;
  final AppShareData appShareData;
  final Color iconColor;
  final Color? iconBackgroundColor;

  const AppShareDialog({
    Key? key,
    this.title,
    required this.content,
    required this.appShareData,
    this.iconColor = AppColor.darkBlue,
    this.iconBackgroundColor,
  }) : super(key: key);

  @override
  State<AppShareDialog> createState() => _AppShareDialogState();
}

class _AppShareDialogState extends State<AppShareDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);
    final title = widget.title;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColor.darkBlue,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        width: responsiveLayoutService.getDynamicSize(context, 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                JuntoInkWell(
                  onTap: () => Navigator.of(context).pop(),
                  boxShape: BoxShape.circle,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close,
                      color: AppColor.white,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            if (title != null) ...[
              JuntoText(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyle.body.copyWith(
                  color: AppColor.white,
                ),
              ),
              SizedBox(height: 10),
            ],
            JuntoText(
              widget.content,
              textAlign: TextAlign.center,
              style: isMobile
                  ? AppTextStyle.bodyMedium.copyWith(color: AppColor.white)
                  : AppTextStyle.body.copyWith(
                      fontSize: responsiveLayoutService.getDynamicSize(context, 35),
                      color: AppColor.white,
                    ),
            ),
            SizedBox(height: isMobile ? 8 : 18),
            if (isMobile)
              _buildShareSection()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  JuntoText('Share', style: AppTextStyle.body.copyWith(color: AppColor.white)),
                  _buildShareSection(),
                  _buildFinishButton(),
                ],
              ),
            SizedBox(height: 20),
            if (isMobile) _buildFinishButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishButton() => ActionButton(
        onPressed: () => Navigator.of(context).pop(),
        sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
        text: 'Finish',
        color: AppColor.brightGreen,
        textColor: AppColor.darkBlue,
      );

  Widget _buildShareSection() => LayoutBuilder(builder: (context, constraints) {
        final double size;
        final double padding;

        if (constraints.maxWidth < 230) {
          size = 28;
          padding = 2;
        } else if (constraints.maxWidth < 285) {
          size = 32;
          padding = 4;
        } else {
          size = 40;
          padding = 6;
        }

        return ShareSection(
          url: widget.appShareData.pathToPage,
          body: widget.appShareData.body,
          subject: widget.title,
          shareCallback: (ShareType type) {
            final juntoId = widget.appShareData.juntoId;
            if (juntoId != null) {
              analytics.logEvent(AnalyticsPressShareJuntoLinkEvent(
                juntoId: juntoId,
                shareType: type,
              ));
            }
          },
          iconColor: widget.iconColor,
          iconBackgroundColor: widget.iconBackgroundColor,
          buttonPadding: padding,
          size: size,
          iconSize: min(size - 16, 20),
        );
      });
}
