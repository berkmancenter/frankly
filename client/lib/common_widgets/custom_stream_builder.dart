import 'package:flutter/material.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/services.dart';

class CustomStreamBuilder<T> extends StatelessWidget {
  final Widget Function(BuildContext, T?) builder;
  final String entryFrom;
  final String errorMessage;
  final WidgetBuilder? errorBuilder;
  final String? loadingMessage;
  final TextStyle? textStyle;
  final double height;
  final double? width;
  final bool showLoading;
  final bool buildWhileLoading;
  final Stream<T>? stream;

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

  @override
  Widget build(BuildContext context) {
    final localErrorBuilder = errorBuilder;
    final localLoadingMessage = loadingMessage;
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

          if (localErrorBuilder != null) {
            return localErrorBuilder(context);
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
                if (localLoadingMessage != null &&
                    localLoadingMessage.isNotEmpty) ...[
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
