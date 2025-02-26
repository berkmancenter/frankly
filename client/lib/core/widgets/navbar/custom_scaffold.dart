import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/core/widgets/navbar/nav_bar/nav_bar.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/core/widgets/navbar/sidebar/sidebar.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/keyboard_util_widgets.dart';
import 'package:provider/provider.dart';

class CustomScaffold extends StatefulWidget {
  final Widget child;
  final bool fillViewport;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color bgColor;

  const CustomScaffold({
    required this.child,
    this.fillViewport = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bgColor = AppColor.white,
  });

  @override
  CustomScaffoldState createState() => CustomScaffoldState();
}

class CustomScaffoldState extends State<CustomScaffold> {
  final _subtreeKey = GlobalKey();

  Widget _buildMainContent(NavBarProvider provider) {
    final keyedChild = KeyedSubtree(key: _subtreeKey, child: widget.child);
    if (provider.hideNav) {
      return keyedChild;
    }
    return widget.fillViewport
        ? Column(
            children: [
              UIMigration(child: NavBar()),
              Expanded(child: keyedChild),
            ],
          )
        : CustomListView(
            children: [
              UIMigration(child: NavBar()),
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
