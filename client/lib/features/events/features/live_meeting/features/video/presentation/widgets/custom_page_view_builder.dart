import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/styles/styles.dart';

/// Creates a PageView widget with arrows at the bottom to control pages
/// navigation and has circle page indicators
class CustomPageViewBuilder extends StatefulWidget {
  final PageController pageController;
  final ValueNotifier<int> currentPageNotifier;
  final Widget child;
  final int pagecount;
  final Widget? rightIcon;
  final Widget? leftIcon;
  final double iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry iconPadding;
  final int duration;
  final Curve curve;
  final bool isJump;
  final String? tooltipLeft;
  final String? tooltipRight;

  static const defaultIconSize = 46.0;
  static const defaultDuration = 300;
  static const defaultCurve = Curves.easeOut;
  static const defaultPadding = EdgeInsets.all(8.0);

  const CustomPageViewBuilder({
    Key? key,
    required this.pageController,
    required this.currentPageNotifier,
    required this.pagecount,
    required this.child,
    this.rightIcon,
    this.leftIcon,
    this.iconColor,
    this.iconPadding = defaultPadding,
    this.duration = defaultDuration,
    this.curve = defaultCurve,
    this.isJump = false,
    this.iconSize = defaultIconSize,
    this.tooltipLeft,
    this.tooltipRight,
  }) : super(key: key);

  @override
  CustomPageViewBuilderState createState() => CustomPageViewBuilderState();
}

class CustomPageViewBuilderState extends State<CustomPageViewBuilder> {
  int get _pageIndex => widget.currentPageNotifier.value;

  bool isFirstPage() => _pageIndex == 0;

  bool isLastPage() => _pageIndex == widget.pagecount - 1;

  @override
  void initState() {
    widget.currentPageNotifier.addListener(_handlePageIndex);
    super.initState();
  }

  @override
  void dispose() {
    widget.currentPageNotifier.removeListener(_handlePageIndex);
    super.dispose();
  }

  void _handlePageIndex() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: _buildPageView(),
        ),
        if (widget.pagecount > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLeftArrow(),
              SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomCirclePageIndicator(
                  itemCount: widget.pagecount,
                  currentPageNotifier: widget.currentPageNotifier,
                ),
              ),
              SizedBox(width: 5),
              _buildRightArrow(),
            ],
          ),
      ],
    );
  }

  Widget _buildPageView() {
    return ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: widget.child,
    );
  }

  Widget _buildLeftArrow() {
    return _buildArrow(
      icon: widget.leftIcon,
      iconData: Icons.chevron_left,
      isVisible: isFirstPage(),
      isLeft: true,
    );
  }

  Widget _buildRightArrow() {
    return _buildArrow(
      icon: widget.rightIcon,
      iconData: Icons.chevron_right,
      isVisible: isLastPage(),
      isLeft: false,
    );
  }

  Widget _buildArrow({
    Widget? icon,
    IconData? iconData,
    required bool isLeft,
    required bool isVisible,
  }) {
    return Opacity(
      opacity: isVisible ? 0.0 : 1.0,
      child: CustomInkWell(
        onTap: isVisible == true
            ? null
            : () {
                if (widget.isJump) {
                  widget.pageController
                      .jumpToPage(isLeft ? _pageIndex - 1 : _pageIndex + 1);
                } else {
                  if (isLeft) {
                    widget.pageController.previousPage(
                      duration: Duration(milliseconds: widget.duration),
                      curve: widget.curve,
                    );
                  } else {
                    widget.pageController.nextPage(
                      duration: Duration(milliseconds: widget.duration),
                      curve: widget.curve,
                    );
                  }
                }
              },
        child: Padding(
          padding: widget.iconPadding,
          child: icon ??
              Icon(
                iconData,
                color: widget.iconColor,
                size: widget.iconSize,
                semanticLabel:
                    isLeft ? widget.tooltipLeft : widget.tooltipRight,
              ),
        ),
      ),
    );
  }
}

/// Creates circle page indicators only visible if there is more than one page
/// The current page will be highlighted
class CustomCirclePageIndicator extends StatefulWidget {
  static const double _defaultSize = 8.0;
  static const double _defaultSelectedSize = 8.0;
  static const double _defaultSpacing = 8.0;
  static const Color _defaultDotColor = AppColor.gray4;
  static const Color _defaultSelectedDotColor = AppColor.white;

  final ValueNotifier<int> currentPageNotifier;
  final int itemCount;
  final ValueChanged<int>? onPageSelected;
  final Color dotColor;
  final Color selectedDotColor;
  final double size;
  final double selectedSize;
  final double dotSpacing;
  final double borderWidth;
  final Color? borderColor;
  final Color? selectedBorderColor;

  CustomCirclePageIndicator({
    Key? key,
    required this.currentPageNotifier,
    required this.itemCount,
    this.onPageSelected,
    this.size = _defaultSize,
    this.dotSpacing = _defaultSpacing,
    Color? dotColor,
    Color? selectedDotColor,
    this.selectedSize = _defaultSelectedSize,
    this.borderWidth = 0,
    this.borderColor,
    this.selectedBorderColor,
  })  : dotColor = dotColor ??
            ((selectedDotColor?.withAlpha(150)) ?? _defaultDotColor),
        selectedDotColor = selectedDotColor ?? _defaultSelectedDotColor,
        assert(
          borderWidth < size,
          'Border width cannot be bigger than dot size!',
        ),
        super(key: key);

  @override
  CustomCirclePageIndicatorState createState() =>
      CustomCirclePageIndicatorState();
}

class CustomCirclePageIndicatorState extends State<CustomCirclePageIndicator> {
  int get _currentPageIndex => widget.currentPageNotifier.value;

  late Color _borderColor;
  late Color _selectedBorderColor;

  bool isSelected(int dotIndex) => _currentPageIndex == dotIndex;

  @override
  void initState() {
    super.initState();
    widget.currentPageNotifier.addListener(_handlePageIndex);
    _borderColor = widget.borderColor ?? widget.dotColor;
    _selectedBorderColor =
        widget.selectedBorderColor ?? widget.selectedDotColor;
  }

  @override
  void dispose() {
    widget.currentPageNotifier.removeListener(_handlePageIndex);
    super.dispose();
  }

  void _handlePageIndex() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List<Widget>.generate(
        widget.itemCount,
        (int index) {
          double size = widget.size;
          Color color = widget.dotColor;
          Color? borderColor = _borderColor;
          if (isSelected(index)) {
            size = widget.selectedSize;
            color = widget.selectedDotColor;
            borderColor = _selectedBorderColor;
          }
          return CustomInkWell(
            onTap: () => widget.onPageSelected == null
                ? null
                : widget.onPageSelected!(index),
            child: SizedBox(
              width: size + widget.dotSpacing,
              child: Material(
                color: widget.borderWidth > 0 ? borderColor : color,
                type: MaterialType.circle,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Center(
                    child: Material(
                      type: MaterialType.circle,
                      color: color,
                      child: SizedBox(
                        width: size - widget.borderWidth,
                        height: size - widget.borderWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
