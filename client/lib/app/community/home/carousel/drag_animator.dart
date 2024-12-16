import 'package:flutter/material.dart';

/// Animates an animationController in response to drag events.
/// Helper methods can be invoked after a designated drag distance or can determine whether dragging
/// is allowed.
class DragAnimator extends StatefulWidget {
  final AnimationController animationController;
  final Widget? child;
  final void Function()? onDragStart;
  final void Function()? onDragEnd;
  final void Function()? triggerDragForwardAction;
  final void Function()? triggerDragBackAction;
  final bool Function()? dragForwardLocked;
  final bool Function()? dragBackLocked;
  final bool Function() dragAllowed;
  final void Function(TapUpDetails)? onBackgroundTap;
  final double dragActionThreshold;
  final double animationControllerValueDivisor;
  final double gestureDetectorHeight;

  /// This determines whether to create the gesture detector at all - useful for turning off drag behavior entirely
  final bool isActive;

  const DragAnimator({
    required this.animationController,
    required this.dragAllowed,
    this.onDragStart,
    this.onDragEnd,
    this.child,
    this.animationControllerValueDivisor = 1.0,
    this.gestureDetectorHeight = 200,
    this.triggerDragForwardAction,
    this.triggerDragBackAction,
    this.onBackgroundTap,
    this.dragActionThreshold = 200,
    this.dragForwardLocked,
    this.dragBackLocked,
    this.isActive = true,
    Key? key,
  }) : super(key: key);

  @override
  _DragAnimatorState createState() => _DragAnimatorState();
}

class _DragAnimatorState extends State<DragAnimator> {
  var _dragStartLocation = 0.0;
  bool _isDragging = false;

  double _currentDx(DragUpdateDetails details) {
    return (details.localPosition.dx - _dragStartLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: widget.child ?? Container()),
        if (widget.isActive)
          Center(
            child: GestureDetector(
              onHorizontalDragStart: (details) {
                if (widget.dragAllowed.call()) {
                  _isDragging = true;
                  _dragStartLocation = details.localPosition.dx;
                  widget.onDragStart?.call();
                }
              },
              onHorizontalDragEnd: (details) {
                if (_isDragging) {
                  widget.onDragEnd?.call();
                  if (widget.animationController.value != 0) {
                    widget.animationController.animateTo(0);
                  }
                }
                _isDragging = false;
              },
              onHorizontalDragCancel: () {
                _isDragging = false;
              },
              onHorizontalDragUpdate: (details) {
                if (_isDragging) {
                  widget.animationController.value = -(_currentDx(details) /
                          widget.animationControllerValueDivisor)
                      .clamp(-1.0, 1.0);

                  if ((widget.dragBackLocked?.call() ?? false) &&
                      _currentDx(details) > 0) {
                    // drag back not allowed, clamp to 0
                    widget.animationController.value = 0;
                    return;
                  }

                  if ((widget.dragForwardLocked?.call() ?? false) &&
                      _currentDx(details) < 0) {
                    // drag forward not allowed, clamp to 0
                    widget.animationController.value = 0;
                    return;
                  }

                  if (_currentDx(details) > widget.dragActionThreshold &&
                      widget.triggerDragBackAction != null) {
                    widget.triggerDragBackAction?.call();
                    widget.animationController.value = 0;
                    _isDragging = false;
                  }
                  if (_currentDx(details) < -widget.dragActionThreshold &&
                      widget.triggerDragForwardAction != null) {
                    widget.triggerDragForwardAction?.call();
                    widget.animationController.value = 0;
                    _isDragging = false;
                  }
                }
              },
              onTapUp: widget.onBackgroundTap?.call,
              child: Container(
                height: widget.gestureDetectorHeight,
                color: Colors.transparent,
              ),
            ),
          ),
      ],
    );
  }
}
