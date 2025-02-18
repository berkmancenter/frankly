import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CustomListView extends HookWidget {
  final EdgeInsets padding;
  final bool shrinkWrap;
  final List<Widget> children;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const CustomListView({
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    required this.children,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController =
        useMemoized(() => controller ?? ScrollController());
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.hasBoundedHeight) {
          return Scrollbar(
            controller: scrollController,
            child: ListView(
              shrinkWrap: shrinkWrap,
              controller: scrollController,
              padding: padding,
              physics: physics,
              children: children,
            ),
          );
        }

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      },
    );
  }
}
