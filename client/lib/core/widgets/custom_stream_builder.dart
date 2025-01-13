import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';

/// Provides loading and error utilities for StreamBuilder.
class CustomStreamBuilder<T> extends StatelessWidget {
  const CustomStreamBuilder({
    Key? key,
    required this.builder,
    required this.entryFrom,
    this.errorMessage = 'Something went wrong. Please try again!',
    this.errorBuilder,
    this.loadingMessage,
    this.textStyle,
    this.height = 200,
    this.width,
    this.showLoading = true,
    this.buildWhileLoading = false,
    this.stream,
  }) : super(key: key);

  final Widget Function(BuildContext, T?) builder;

  /// For logging purposes, the widget/function that this is called from.
  final String entryFrom;
  final String errorMessage;
  final WidgetBuilder? errorBuilder;
  final String? loadingMessage;
  final TextStyle? textStyle;
  final double height;
  final double? width;
  final bool showLoading;

  /// If true, the builder will be called even if the snapshot is still loading.
  /// Defaults to false, i.e. a loading indicator / placeholder will be shown.
  final bool buildWhileLoading;

  final Stream<T>? stream;

  @override
  Widget build(BuildContext context) {
    final stackTraceCurrent = StackTrace.current;

    return StreamBuilder<T>(
      stream: stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          loggingService.log(
            'CustomStreamBuilder.build : $entryFrom',
            logType: LogType.error,
            error: error,
            stackTrace: error is Error ? error.stackTrace : stackTraceCurrent,
          );
          loggingService.log(errorMessage);

          if (errorBuilder != null) {
            return errorBuilder!(context);
          }
          return SizedBox(
            height: height,
            width: width,
            child: Text(
              errorMessage,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.merge(textStyle ?? TextStyle()),
            ),
          );
        } else if (!buildWhileLoading &&
            snapshot.data == null &&
            snapshot.connectionState == ConnectionState.waiting) {
          if (!showLoading) return SizedBox.shrink();

          return SizedBox(
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomLoadingIndicator(),
                if (loadingMessage != null &&
                    (loadingMessage?.isNotEmpty ?? false)) ...[
                  SizedBox(height: 16),
                  Text(
                    localLoadingMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.merge(textStyle ?? TextStyle()),
                  ),
                ],
              ],
            ),
          );
        }

        return builder(context, snapshot.data);
      },
    );
  }
}
