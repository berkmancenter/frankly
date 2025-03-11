import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/tabs/tab_controller.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

/// The widget that contains the list of selectable tab titles
class CustomTabBar extends StatelessWidget {
  final EdgeInsets? padding;

  const CustomTabBar({
    Key? key,
    this.padding,
    x,
  });

  @override
  Widget build(BuildContext context) {
    final tabController = Provider.of<CustomTabControllerState>(context);
    return SizedBox(
      height: 42,
      child: ListView(
        padding: padding,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < tabController.tabs.length; i++)
            // Only show TABs which are not gated
            if (!tabController.tabs[i].isGated)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CustomInkWell(
                  hoverColor: Colors.transparent,
                  onTap: !tabController.tabs[i].isGated
                      ? () => tabController.currentTab = i
                      : null,
                  child: _CustomTab(
                    tab: tabController.tabs[i],
                    index: i,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _CustomTab extends StatefulWidget {
  final CustomTabAndContent tab;
  final int index;
  final int? unreadCount;

  const _CustomTab({
    required this.tab,
    required this.index,
    this.unreadCount,
  });

  @override
  State<_CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<_CustomTab> {
  bool _hovered = false;

  TextStyle get getTextStyle {
    final style = AppTextStyle.body;
    return style.copyWith(color: currentColor);
  }

  bool get _bold => _hovered;

  Color get currentColor {
    final Color color;

    if (isSelected) {
      color = selectedColor;
    } else if (_hovered) {
      color = AppColor.white;
    } else {
      color = AppColor.gray2.withOpacity(.75);
    }

    if (widget.tab.isGated) {
      return color.withOpacity(.5);
    } else {
      return color;
    }
  }

  bool get isSelected {
    final controller = Provider.of<CustomTabControllerState>(context);
    return widget.index == controller.currentTab;
  }

  Color get selectedColor => AppColor.darkBlue;

  @override
  Widget build(BuildContext context) {
    final localUnreadCount = widget.unreadCount;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 100),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Transparent bold text to take up the space of the hovered tab and avoid the widget resizing on hover
                      HeightConstrainedText(
                        widget.tab.tab.toUpperCase(),
                        style: AppTextStyle.bodyMedium
                            .copyWith(color: Colors.transparent),
                      ),
                      HeightConstrainedText(
                        widget.tab.tab.toUpperCase(),
                        style: getTextStyle,
                      ),
                    ],
                  ),
                  if (localUnreadCount != null && localUnreadCount > 0) ...[
                    SizedBox(width: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.brightGreen,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      height: 25,
                      width: 25,
                      child: Text(
                        widget.unreadCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: _bold ? 7 : 8),
              Container(
                height: _bold ? 5 : 4,
                color: currentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
