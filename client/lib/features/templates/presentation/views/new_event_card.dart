import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/create_event/presentation/views/create_event_dialog.dart';
import 'package:client/features/templates/data/providers/template_page_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/features/events/presentation/widgets/hosting_option.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/templates/presentation/widgets/prerequisite_badge.dart';
import 'package:client/config/environment.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:client/core/localization/localization_helper.dart';

class NewEventCard extends StatefulWidget {
  final Template template;
  final bool hasAttendedPrerequisite;
  final void Function(EventType)? onCreateEventTap;

  const NewEventCard({
    required this.template,
    required this.hasAttendedPrerequisite,
    this.onCreateEventTap,
    Key? key,
  }) : super(key: key);

  @override
  State<NewEventCard> createState() => _NewEventCardState();
}

class _NewEventCardState extends State<NewEventCard> {
  EventType? _selectedHostingOption = EventType.hosted;

  bool get isMod => Provider.of<UserDataService>(context)
      .getMembership(Provider.of<CommunityProvider>(context).communityId)
      .isMod;

  @override
  Widget build(BuildContext context) {
    final showPrerequisiteBadge = !isMod &&
        widget.template.prerequisiteTemplateId != null &&
        !widget.hasAttendedPrerequisite;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColor.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleAndHelpIcon(),
            SizedBox(height: 10),
            if (isMod) ...[
              _buildHostingOption(),
              SizedBox(height: 10),
            ],
            if (showPrerequisiteBadge)
              PrerequisiteBadge()
            else
              _buildCreateEventButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndHelpIcon() {
    final isMobile = responsiveLayoutService.isMobile(context);
    final l10n = appLocalizationService.getLocalization();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: HeightConstrainedText(
            l10n.createEventFromTemplate(isMobile ? '' : '\n'),
            style: AppTextStyle.headline1.copyWith(
              fontSize: 18,
              color: AppColor.darkBlue,
            ),
          ),
        ),
        SizedBox(width: 10),
        _buildHelpTooltip(),
      ],
    );
  }

  Widget _buildHostingOption() => Center(
        child: HostingOption(
          isWhiteBackground: true,
          selectedEventType: (eventType) {
            setState(() {
              _selectedHostingOption = eventType;
            });
          },
          isHostlessEnabled: CommunityProvider.watch(context).enableHostless,
          initialHostingOption: EventType.hosted,
        ),
      );

  Widget _buildCreateEventButton() {
    final l10n = appLocalizationService.getLocalization();
    final onTap = widget.onCreateEventTap;

    return Align(
      alignment: Alignment.centerRight,
      child: ActionButton(
        expand: !isMod,
        color: AppColor.darkBlue,
        onPressed: () {
          analytics.logEvent(
            AnalyticsPressCreateEventFromTemplateEvent(
              communityId: widget.template.communityId,
              templateId: widget.template.id,
            ),
          );
          if (onTap != null) {
            onTap(_selectedHostingOption ?? EventType.hosted);
          } else {
            return CreateEventDialog.show(
              context,
              eventType: _selectedHostingOption ?? EventType.hosted,
              template: widget.template,
            );
          }
        },
        text: l10n.createEvent,
        textColor: AppColor.brightGreen,
      ),
    );
  }

  Widget _buildHelpTooltip() {
    final isMobile = responsiveLayoutService.isMobile(context);
    const helpDocLink = Environment.createEventHelpUrl;

    final templatePageProvider = context.watch<TemplatePageProvider>();

    return SimpleTooltip(
      minWidth: 200,
      maxWidth: !isMobile ? 280 : null,
      arrowLength: 15,
      borderColor: AppColor.gray6,
      borderWidth: 1,
      ballonPadding: EdgeInsets.all(0),
      minimumOutSidePadding: 40,
      customShadows: const [
        BoxShadow(color: AppColor.gray3, blurRadius: 5, spreadRadius: 2),
      ],
      animationDuration: Duration(milliseconds: 500),
      show: templatePageProvider.isHelpExpanded,
      tooltipDirection:
          isMobile ? TooltipDirection.horizontal : TooltipDirection.up,
      content: Material(
        color: AppColor.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 20,
                  bottom: 20,
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Quickly create interactive events using templates. ',
                    style: AppTextStyle.body.copyWith(
                      color: AppColor.gray2,
                    ),
                    children: [
                      TextSpan(
                        text: 'Learn more',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launch(helpDocLink),
                        style: AppTextStyle.body.copyWith(
                          color: AppColor.accentBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => templatePageProvider.isHelpExpanded = false,
              icon: Icon(Icons.close),
            ),
          ],
        ),
      ),
      child: CustomInkWell(
        onTap: () => templatePageProvider.isHelpExpanded = true,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.darkBlue,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              CupertinoIcons.question,
              size: 11,
              color: AppColor.darkBlue,
            ),
          ),
        ),
      ),
    );
  }
}
