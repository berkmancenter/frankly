import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:rxdart/rxdart.dart';

/// This class wraps CustomStreamBuilder, and manages the lifecycle of the stream including
/// rebuilding if any parameter within `keys` changes
class CustomStreamGetterBuilder<T> extends HookWidget {
  const CustomStreamGetterBuilder({
    required this.streamGetter,
    required this.builder,
    this.keys = const [],
    Key? key,
    this.errorMessage = 'Something went wrong. Please try again!',
    this.errorBuilder,
    this.loadingMessage,
    this.textStyle,
    this.height = 200,
    this.width,
    this.entryFrom = 'CustomStreamGetterBuilder.build',
    this.showLoading = true,
  }) : super(key: key);

  final String errorMessage;
  final WidgetBuilder? errorBuilder;
  final String? loadingMessage;
  final TextStyle? textStyle;
  final double height;
  final double? width;
  final bool showLoading;
  final String entryFrom;

  final Stream<T> Function() streamGetter;
  final Widget Function(BuildContext, T?) builder;
  final List<Object> keys;

  @override
  Widget build(BuildContext context) {
    return CustomStreamBuilder<T>(
      stream: useMemoized(streamGetter, keys),
      builder: builder,
      errorMessage: errorMessage,
      errorBuilder: errorBuilder,
      loadingMessage: loadingMessage,
      textStyle: textStyle,
      height: height,
      width: width,
      showLoading: showLoading,
      entryFrom: entryFrom,
    );
  }
}

/// This class wraps a stream with BehaviorSubject (internally using `wrapInBehaviorSubject`), and
/// handles renewing it if its dependent parameters change and disposing it when no longer needed.
class BehaviorSubjectWrapperWidget<T> extends HookWidget {
  const BehaviorSubjectWrapperWidget({
    required this.streamGetter,
    required this.builder,
    required this.keys,
    Key? key,
  }) : super(key: key);

  final Stream<T> Function() streamGetter;
  final Widget Function(BuildContext, BehaviorSubjectWrapper<T>?) builder;
  final List<Object> keys;

  @override
  Widget build(BuildContext context) {
    final stream = useBehaviorSubjectWrapper<T>(streamGetter, keys);
    return builder(context, stream);
  }
}

/// Hook which wraps a Stream in BehaviorSubjectWrapper, and disposes and recreates as needed,
/// consistent with changes to `keys`
BehaviorSubjectWrapper<T> useBehaviorSubjectWrapper<T>(
  Stream<T> Function() valueBuilder, [
  List<Object?> keys = const <Object>[],
]) {
  return use(
    _BehaviorSubjectWrapperHook(
      valueBuilder,
      keys: keys,
    ),
  );
}

class _BehaviorSubjectWrapperHook<T> extends Hook<BehaviorSubjectWrapper<T>> {
  const _BehaviorSubjectWrapperHook(
    this.valueBuilder, {
    required List<Object?> keys,
  }) : super(keys: keys);

  final Stream<T> Function() valueBuilder;

  @override
  _BehaviorSubjectWrapperHookState<T> createState() =>
      _BehaviorSubjectWrapperHookState<T>();
}

class _BehaviorSubjectWrapperHookState<T> extends HookState<
    BehaviorSubjectWrapper<T>, _BehaviorSubjectWrapperHook<T>> {
  late final BehaviorSubjectWrapper<T> value =
      wrapInBehaviorSubject(hook.valueBuilder());

  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }

  @override
  BehaviorSubjectWrapper<T> build(BuildContext context) {
    return value;
  }

  @override
  String get debugLabel => 'useBehaviorSubjectWrapper<$T>';
}

/// Returns a listener to a stream which will be cleaned up automatically
void useStreamListener<T>({
  required Stream<T> stream,
  required void Function(T) function,
  List<Object>? keys,
}) {
  useEffect(
    () {
      final listener = stream.listen(function);
      return () => listener.cancel();
    },
    [stream, ...?keys],
  );
}

/// Class used by Stream.withPrevious extension method to hold previous and current stream values
class WithPreviousData<T> {
  T? current;
  T? previous;
  WithPreviousData(this.previous, this.current);
}

extension StreamExtensions<T> on Stream<T?> {
  /// Map each element to an object containing current and previous values. For the first element,
  /// `previous` will be null.
  Stream<WithPreviousData<T>> withPrevious() {
    return startWith(null)
        .bufferCount(2, 1)
        .map((pair) => WithPreviousData(pair[0], pair[1]));
  }
}
