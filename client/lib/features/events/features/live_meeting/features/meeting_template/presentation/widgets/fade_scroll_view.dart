import 'package:flutter/material.dart';
import 'package:client/styles/styles.dart';

/// A scrolling view that shows a faded white gradient on the bottom of the view if there is
/// content to scroll to in that direction
class FadeScrollView extends StatefulWidget {
  final Widget child;
  final double maxFadeExtent;

  /// This value is multiplied by the remaining amount of space in the scroll view to determine the fade extent
  final double fadeScrollScale;

  const FadeScrollView({
    required this.child,
    this.maxFadeExtent = 80.0,
    this.fadeScrollScale = .5,
    Key? key,
  }) : super(key: key);

  @override
  State<FadeScrollView> createState() => _FadeScrollViewState();
}

class _FadeScrollViewState extends State<FadeScrollView> {
  late final ScrollController _controller = ScrollController();

  double get _fadeHeight {
    if (!_controller.hasClients) return 0;
    final distToEnd = _controller.position.maxScrollExtent - _controller.offset;
    return (distToEnd * widget.fadeScrollScale)
        .clamp(0.0, widget.maxFadeExtent);
  }

  @override
  void initState() {
    _controller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scrollbar(
          controller: _controller,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 10),
            controller: _controller,
            child: widget.child,
          ),
        ),
        if (widget.maxFadeExtent > 0)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MouseRegion(
                opaque: false,
                child: GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  child: Container(
                    height: _fadeHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.theme.colorScheme.surfaceContainerLowest,
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
