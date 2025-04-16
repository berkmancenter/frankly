import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/events/features/event_page/presentation/event_tabs_model.dart';
import 'package:client/core/widgets/tabs/tab_bar_view.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:provider/provider.dart';

class CollapsibleBottomEventContent extends StatefulHookWidget {
  const CollapsibleBottomEventContent();

  @override
  _CollapsibleBottomEventContentState createState() =>
      _CollapsibleBottomEventContentState();
}

class _CollapsibleBottomEventContentState
    extends State<CollapsibleBottomEventContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _collapseController;

  bool get _isCollapsed =>
      !Provider.of<EventTabsControllerState>(context).expanded;

  EventTabsControllerState get _providerRead =>
      Provider.of<EventTabsControllerState>(context, listen: false);

  @override
  void initState() {
    super.initState();

    _collapseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_providerRead.expanded) {
      _collapseController.forward();
    } else {
      _collapseController.reverse();
    }
  }

  @override
  void dispose() {
    _collapseController.dispose();
    super.dispose();
  }

  Widget _buildCollapsibleContainer() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _providerRead.expanded = false,
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.topCenter,
            color: Theme.of(context).colorScheme.secondary,
            child: Icon(
              _isCollapsed ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: AppColor.darkBlue,
            child: CustomTabBarView(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomDrawerContent(BoxConstraints constraints) {
    final overlayHeight = constraints.maxHeight * 0.8;
    return Container(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0, 1),
          end: Offset(0, 0),
        ).animate(_collapseController),
        child: SizedBox(
          width: constraints.maxWidth,
          height: overlayHeight,
          child: CustomPointerInterceptor(
            child: _buildCollapsibleContainer(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomDrawerLayout(BoxConstraints constraints) {
    return Stack(
      children: [
        if (!_isCollapsed)
          CustomPointerInterceptor(
            child: GestureDetector(
              onTap: () => _providerRead.expanded = false,
              behavior: HitTestBehavior.opaque,
            ),
          ),
        RepaintBoundary(
          key: Key('meeting-content'),
          child: _buildBottomDrawerContent(constraints),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _buildBottomDrawerLayout(constraints),
    );
  }
}
