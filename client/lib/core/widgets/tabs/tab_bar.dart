import 'package:client/styles/styles.dart';
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
                  onTap: () => tabController.currentTab = i,
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

  const _CustomTab({
    required this.tab,
    required this.index,
  });

  @override
  State<_CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<_CustomTab> {
  bool _hovered = false;

  bool get isSelected {
    final controller = Provider.of<CustomTabControllerState>(context);
    return widget.index == controller.currentTab;
  }

  @override
  Widget build(BuildContext context) {
    final shouldHighlight = isSelected || _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        constraints: BoxConstraints(minWidth: 100),
        padding: EdgeInsets.only(bottom: _hovered ? 6 : 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: shouldHighlight
                  ? context.theme.colorScheme.primary
                  : AppColor.textTertiary,
              width: shouldHighlight ? 5 : 3,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Transparent bold text to take up the space of the hovered tab and avoid the widget resizing on hover
                  HeightConstrainedText(
                    widget.tab.tab.toUpperCase(),
                    maxLines: 1,
                    softWrap: false,
                    style: AppTextStyle.bodyMedium
                        .copyWith(color: Colors.transparent),
                  ),
                  HeightConstrainedText(
                    widget.tab.tab.toUpperCase(),
                    maxLines: 1,
                    softWrap: false,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: shouldHighlight
                          ? context.theme.colorScheme.primary
                          : AppColor.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
