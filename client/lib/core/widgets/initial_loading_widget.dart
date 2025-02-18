import 'package:beamer/beamer.dart';
import 'package:client/app.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class InitialLoadingWidget extends StatefulWidget {
  final Widget child;

  const InitialLoadingWidget({required this.child});

  @override
  _InitialLoadingWidgetState createState() => _InitialLoadingWidgetState();
}

class _InitialLoadingWidgetState extends State<InitialLoadingWidget> {
  bool _initialized = false;
  bool _showedRedirectSignInError = false;
  Object? _initializationError;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (userService.redirectErrorMessage != null &&
        !_showedRedirectSignInError) {
      _showedRedirectSignInError = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showAlert(
          context,
          sanitizeError(userService.redirectErrorMessage!),
        ),
      );
    }
  }

  Future<void> _initialize() async {
    try {
      await initializeServices();

      _storeQueryParameters();
    } catch (e, stacktrace) {
      loggingService.log(
        '_InitialLoadingWidgetState._initialize error',
        logType: LogType.error,
        error: e,
        stackTrace: stacktrace,
      );
      setState(() => _initializationError = e);
      rethrow;
    }
    setState(() => _initialized = true);
  }

  void _storeQueryParameters() {
    var parameters = botJoinParameters ??
        Uri.tryParse(html.window.location.href)?.queryParameters;

    if (parameters != null && parameters.isNotEmpty) {
      final pathParameters =
          (routerDelegate.currentBeamLocation.state as BeamState)
              .queryParameters;
      final eventIdParameter =
          pathParameters[CommunityLocation.eventIdParameter];
      final allParameters = {
        ...parameters,
        if (eventIdParameter != null) 'eventId': eventIdParameter,
      };
      queryParametersService.addQueryParameters(allParameters);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<UserService>().signInState == SignInState.signedIn &&
        _initialized) {
      return widget.child;
    } else if (context.watch<UserService>().signInState ==
        SignInState.signedOut) {
      return Scaffold(
        body: Center(
          child: HeightConstrainedText(
            'You have been signed out. Please refresh to sign back in',
            style: AppTextStyle.subhead,
          ),
        ),
      );
    } else if (_initializationError != null) {
      final showError = (routerDelegate.currentBeamLocation.state as BeamState)
              .queryParameters['debug'] ==
          'true';
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeightConstrainedText(
                'There was an unexpected error during initialization.',
                style: AppTextStyle.subhead,
              ),
              if (showError) ...[
                SizedBox(height: 10),
                HeightConstrainedText(
                  _initializationError.toString(),
                  style: AppTextStyle.body,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: CustomLoadingIndicator(),
      ),
    );
  }
}
