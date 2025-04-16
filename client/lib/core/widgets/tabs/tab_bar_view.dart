import 'package:flutter/material.dart';
import 'package:client/core/widgets/tabs/tab_controller.dart';
import 'package:provider/provider.dart';

class CustomTabBarView extends StatelessWidget {
  /// Load the state of all tabs and keep alive even when on other tabs
  final bool keepAlive;

  const CustomTabBarView({
    this.keepAlive = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CustomTabControllerState>(context);
    final currentTab = controller.currentTab;
    final tabContents = controller.tabContents;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: IndexedStack(
        index: currentTab,
        sizing: StackFit.loose,
        children: [
          for (final content in tabContents)
            Visibility(
              maintainState: keepAlive,
              visible: currentTab == tabContents.indexOf(content),
              child: content(context),
            ),
        ],
      ),
    );
  }
}
