import 'package:flutter/material.dart';
import 'package:junto/common_widgets/tabs/tab_controller.dart';
import 'package:provider/provider.dart';

class JuntoTabBarView extends StatelessWidget {
  /// Load the state of all tabs and keep alive even when on other tabs
  final bool keepAlive;

  const JuntoTabBarView({
    this.keepAlive = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<JuntoTabControllerState>(context);
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
            )
        ],
      ),
    );
  }
}
