import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Memoizes the value returned by `getter` and provides it to `builder`. Rebuilds the value when
/// any element in `keys` changes.
class MemoizedBuilder<T> extends HookWidget {
  final T Function() getter;
  final Widget Function(BuildContext, T) builder;
  final List<Object> keys;

  const MemoizedBuilder({
    required this.getter,
    required this.builder,
    this.keys = const [],
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, useMemoized(getter, keys));
  }
}

/// Wraps FutureBuilder in MemoizedBuilder, for convenience. `getter` will be re-run whenever an
/// element of `keys` changes, and will provide the new value to `builder`.
class MemoizedFutureBuilder<T> extends StatelessWidget {
  final Future<T> Function() getter;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;
  final List<Object> keys;

  const MemoizedFutureBuilder({
    required this.getter,
    required this.builder,
    this.keys = const [],
  });

  @override
  Widget build(BuildContext context) {
    return MemoizedBuilder<Future<T>>(
      getter: getter,
      keys: [keys],
      builder: (_, future) => FutureBuilder<T>(
        future: future,
        builder: builder,
      ),
    );
  }
}
