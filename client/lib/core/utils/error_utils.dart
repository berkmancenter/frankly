import 'dart:math';

import 'package:client/core/data/services/logging_service.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:client/core/data/providers/dialog_provider.dart';

import 'dart:async';

String sanitizeError(String error) {
  error = error
      .replaceAll('FirebaseError: ', '')
      .replaceAll(RegExp(r'\(.*\)'), '')
      .replaceAll(RegExp(r'\[.*\]'), '')
      .trim();

  if (error.contains('An account already exists with the same email address')) {
    return 'An account exists with the same email address but a different sign in method. Use Sign in with Email and click Forgot Password if you don’t know it. Or, Sign Up again using a different email.';
  }
  if (error.contains('The password is invalid')) {
    return 'Password is invalid. Click Forgot Password to reset it. Or, Sign Up again using a different email.';
  }
  if (error.contains('There is no user record')) {
    return 'No account found. Try signing in using a different email address. Or, Sign Up using this one.';
  }
  if (error
      .contains('The email address is already in use by another account')) {
    return 'You already created an account tied to this email address. Use Sign in with Email and click Forgot Password if you don’t know it. Or, Sign Up again using a different email.';
  }
  if (error.contains('Missing or insufficient permission')) {
    return 'Sorry, you aren\'t authorized to do that.';
  }
  if (error.trim().toLowerCase() == 'INTERNAL'.toLowerCase()) {
    return 'Sorry, something went wrong.';
  }

  return error;
}

Future<void> showAlert(BuildContext context, String alert) =>
    showCustomDialog<void>(
      context: context,
      builder: (innerContext) => AlertDialog(
        content: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: HeightConstrainedText(
                    alert,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
                onPressed: () => Navigator.of(innerContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );

Future<T?> alertOnError<T>(
  BuildContext context,
  Future<T> Function() action, {
  String? errorMessage,
}) async {
  try {
    return await action();
  } catch (e, s) {
    loggingService.log(e, logType: LogType.error);
    loggingService.log(s, logType: LogType.error);

    final sanitizedError = sanitizeError(e.toString());

    await showAlert(context, errorMessage ?? sanitizedError);
    return null;
  }
}

// Return callback w/ both the sanitized error and either firebase error code or exception msg when action fails
Future<void> authMessageOnError<T>(
  Future<T> Function() action, {
  required Function(String errorMessage, String code) errorCallback,
Function()? callback ,
}) async {
  try {
    await action();
    callback!();
  } catch (e, s) {
    loggingService.log(e, logType: LogType.error);
    loggingService.log(s, logType: LogType.error);

    final sanitizedError = sanitizeError(e.toString());
    
    if (e is FirebaseAuthException) {
      errorCallback(sanitizedError, e.code);
    } else if (e is VisibleException) {
      errorCallback(sanitizedError, e.msg);
    }

  }
}

// Note: Consider not swallowing all errors. Only a subset of error types.
Future<T?> swallowErrors<T>(
  FutureOr<T> Function() action, {
  String? errorMessage,
}) async {
  try {
    return await action();
  } catch (e, stackTrace) {
    loggingService.log('Error swallowed in tryCatch utility.');
    if (errorMessage != null) {
      loggingService.log(errorMessage);
    }
    loggingService.log(stackTrace);
    loggingService.log(e, logType: LogType.error, stackTrace: stackTrace);
  }
  return null;
}

T? swallowErrorsSync<T>(T Function() action) {
  try {
    return action();
  } catch (e, stackTrace) {
    loggingService.log('Error swallowed in tryCatchSync utility.');
    loggingService.log(e, logType: LogType.error, stackTrace: stackTrace);
  }
  return null;
}

bool isNullOrEmpty(String? value) => (value?.trim() ?? '').isEmpty;
