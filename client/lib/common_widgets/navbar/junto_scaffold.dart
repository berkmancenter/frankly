import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/navbar/nav_bar/nav_bar.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/common_widgets/navbar/sidebar/sidebar.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/keyboard_utils.dart';
import 'package:provider/provider.dart';

class JuntoScaffold extends StatefulWidget {
  final Widget child;
  final bool fillViewport;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color bgColor;

  const JuntoScaffold({
    required this.child,
    this.fillViewport = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bgColor = AppColor.white,
  });

  @override
  _JuntoScaffoldState createState() => _JuntoScaffoldState();
}

class _JuntoScaffoldState extends State<JuntoScaffold> {
  final _subtreeKey = GlobalKey();

  Widget _buildMainContent(NavBarProvider provider) {
    final keyedChild = KeyedSubtree(key: _subtreeKey, child: widget.child);
    if (provider.hideNav) {
      return keyedChild;
    }
    return widget.fillViewport
        ? Column(
            children: [
              JuntoUiMigration(child: NavBar()),
              Expanded(child: keyedChild),
            ],
          )
        : JuntoListView(
            children: [
              JuntoUiMigration(child: NavBar()),
              keyedChild,
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final navBarProvider = context.watch<NavBarProvider>();
    return FocusFixer(
      child: Scaffold(
        backgroundColor: widget.bgColor,
        floatingActionButton: widget.floatingActionButton,
        endDrawer: SideBar(),
        body: Column(
          children: [
            Expanded(
              child: _buildMainContent(navBarProvider),
            ),
            if (widget.bottomNavigationBar != null) widget.bottomNavigationBar!,
          ],
        ),
      ),
    );
  }
}
