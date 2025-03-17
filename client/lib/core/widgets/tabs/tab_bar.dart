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
    return color;
  }

  bool get isSelected {
    final controller = Provider.of<CustomTabControllerState>(context);
    return widget.index == controller.currentTab;
  }

  Color get selectedColor => AppColor.darkBlue;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        constraints: BoxConstraints(minWidth: 100),
        padding: EdgeInsets.only(bottom: _bold ? 7 : 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: currentColor,
              width: _bold ? 5 : 4,
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
                    style: getTextStyle,
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
