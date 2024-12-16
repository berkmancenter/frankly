import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/common_widgets/tabs/tab_bar_view.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:provider/provider.dart';

class CollapsibleBottomDiscussionContent extends StatefulHookWidget {
  const CollapsibleBottomDiscussionContent();

  @override
  _CollapsibleBottomDiscussionContentState createState() =>
      _CollapsibleBottomDiscussionContentState();
}

class _CollapsibleBottomDiscussionContentState extends State<CollapsibleBottomDiscussionContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _collapseController;

  bool get _isCollapsed => !Provider.of<DiscussionTabsControllerState>(context).expanded;

  DiscussionTabsControllerState get _providerRead =>
      Provider.of<DiscussionTabsControllerState>(context, listen: false);

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
            child: JuntoTabBarView(),
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
          child: JuntoPointerInterceptor(
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
          JuntoPointerInterceptor(
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
