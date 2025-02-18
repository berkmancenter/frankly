import 'dart:async';

import 'package:flutter/material.dart';

class PeriodicBuilder extends StatefulWidget {
  final Duration period;
  final WidgetBuilder builder;

  const PeriodicBuilder({required this.period, required this.builder});

  @override
  _PeriodicBuilderState createState() => _PeriodicBuilderState();
}

class _PeriodicBuilderState extends State<PeriodicBuilder> {
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(widget.period, (_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: widget.builder);
  }
}
