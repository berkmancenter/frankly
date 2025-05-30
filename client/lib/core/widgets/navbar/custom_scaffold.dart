import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/navbar/nav_bar/nav_bar.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/core/widgets/navbar/sidebar/sidebar.dart';
import 'package:client/core/widgets/keyboard_util_widgets.dart';
import 'package:provider/provider.dart';

class CustomScaffold extends StatefulWidget {
  final Widget child;
  final bool fillViewport;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? bgColor;

  /// This allows a different theme to be provided to child widgets
  /// without affecting the theme of global/nav elements.
  /// This feature is used in community pages to customize theme.
  final ThemeData? childTheme;

  const CustomScaffold({
    required this.child,
    this.fillViewport = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bgColor,
    this.childTheme,
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
              NavBar(),
              Expanded(
                child: Theme(
                  data: widget.childTheme ?? Theme.of(context),
                  child: keyedChild,
                ),
              ),
            ],
          )
        : CustomListView(
            children: [
              NavBar(),
              Theme(
                data: widget.childTheme ?? Theme.of(context),
                child: keyedChild,
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final navBarProvider = context.watch<NavBarProvider>();
    return Scaffold(
      backgroundColor: widget.bgColor,

      // Floating action buttons should follow the theme of the scaffold
      // instead of other nav elements.
      floatingActionButton: widget.floatingActionButton != null
          ? Theme(
              data: widget.childTheme ?? Theme.of(context),
              child: widget.floatingActionButton!,
            )
          : null,
      endDrawer: SideBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMainContent(navBarProvider),
          ),
          if (widget.bottomNavigationBar != null) widget.bottomNavigationBar!,
        ],
      ),
    );
  }
}
