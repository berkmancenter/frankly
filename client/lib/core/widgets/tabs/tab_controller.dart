import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectedTabController with ChangeNotifier {
  int _selectedTab;

  SelectedTabController({required int initialTab}) : _selectedTab = initialTab;

  int get selectedIndex => _selectedTab;

  void setTabIndex(int index) {
    _selectedTab = index;
    notifyListeners();
  }
}

/// This contains the current selected tab, and the list of tab / content-builder objects
/// It is provided to each instance where tabs are used (admin, event page, profile, template page)
class CustomTabController extends StatefulWidget {
  final SelectedTabController? selectedTabController;
  final List<CustomTabAndContent> tabs;
  final Widget child;

  const CustomTabController({
    this.selectedTabController,
    required this.tabs,
    required this.child,
  });

  @override
  State<CustomTabController> createState() => CustomTabControllerState();
}

class CustomTabControllerState extends State<CustomTabController> {
  late final SelectedTabController _selectedTabController;

  int get currentTab => _selectedTabController.selectedIndex;

  List<String> get tabTitles => widget.tabs.map((e) => e.tab).toList();

  List<CustomTabAndContent> get tabs => widget.tabs;

  List<Widget Function(BuildContext)> get tabContents =>
      widget.tabs.map((e) => e.content).toList();

  @override
  void initState() {
    super.initState();
    _selectedTabController =
        widget.selectedTabController ?? SelectedTabController(initialTab: 0);
  }

  set currentTab(int value) {
    if (currentTab == value) return;

    _selectedTabController.setTabIndex(value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _selectedTabController,
      builder: (context, __) => Provider.value(
        value: this,
        updateShouldNotify: (_, __) => true,
        builder: (_, __) => widget.child,
      ),
    );
  }
}

/// Title of tab and builder of the tab's content - a list of these objects is passed to the Tab Controller
class CustomTabAndContent {
  final bool isGated;
  final String tab;
  final Widget Function(BuildContext) content;
  final int unreadCount;

  CustomTabAndContent({
    this.isGated = false,
    required this.tab,
    required this.content,
    this.unreadCount = 0,
  });
}
