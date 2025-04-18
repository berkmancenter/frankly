import 'dart:math';

import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/presentation/widgets/share_section.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/config/environment.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/utils/share_type.dart';

class AppShareData {
  /// Indicates page path.
  ///
  /// If [pathToPage] is not provided, it will be generated to default to current page.
  late String pathToPage;
  final String subject;
  final String body;
  final String? communityId;

  AppShareData({
    required this.subject,
    required this.body,
    String? pathToPage,
    this.communityId,
  }) {
    this.pathToPage = pathToPage == null
        ? _getPathUrl(
            routerDelegate.currentConfiguration?.location.toString() ?? '',
          )
        : _getPathUrl(pathToPage);
  }

  /// Generates default sharing url.
  String _getPathUrl(String pathToPage) {
    return '${Environment.shareLinkUrl}$pathToPage';
  }
}

class AppShareDialog extends StatefulWidget {
  const AppShareDialog({
    Key? key,
    this.title,
    required this.content,
    required this.appShareData,
    this.iconColor,
    this.iconBackgroundColor,
  }) : super(key: key);

  final String? title;
  final String content;
  final AppShareData appShareData;
  final Color? iconColor;
  final Color? iconBackgroundColor;

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
      backgroundColor: context.theme.colorScheme.primary,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        width: responsiveLayoutService.getDynamicSize(context, 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomInkWell(
                  onTap: () => Navigator.of(context).pop(),
                  boxShape: BoxShape.circle,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close,
                      color: context.theme.colorScheme.onPrimary,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (title != null) ...[
              HeightConstrainedText(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyle.body.copyWith(
                  color: context.theme.colorScheme.onPrimary,
                ),
              ),
              SizedBox(height: 10),
            ],
            HeightConstrainedText(
              widget.content,
              textAlign: TextAlign.center,
              style: isMobile
                  ? AppTextStyle.bodyMedium
                      .copyWith(color: context.theme.colorScheme.onPrimary)
                  : AppTextStyle.body.copyWith(
                      fontSize:
                          responsiveLayoutService.getDynamicSize(context, 35),
                      color: context.theme.colorScheme.onPrimary,
                    ),
            ),
            SizedBox(height: isMobile ? 8 : 18),
            if (isMobile)
              _buildShareSection()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeightConstrainedText(
                    'Share',
                    style: AppTextStyle.body
                        .copyWith(color: context.theme.colorScheme.onPrimary),
                  ),
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
        color: context.theme.colorScheme.onPrimary,
        textColor: context.theme.colorScheme.primary,
      );

  Widget _buildShareSection() => LayoutBuilder(
        builder: (context, constraints) {
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
              final communityId = widget.appShareData.communityId;
              if (communityId != null) {
                analytics.logEvent(
                  AnalyticsPressShareCommunityLinkEvent(
                    communityId: communityId,
                    shareType: type,
                  ),
                );
              }
            },
            iconColor: widget.iconColor ?? context.theme.colorScheme.primary,
            iconBackgroundColor: widget.iconBackgroundColor,
            buttonPadding: padding,
            size: size,
            iconSize: min(size - 16, 20),
          );
        },
      );
}
