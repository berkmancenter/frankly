import 'dart:math';

import 'package:client/core/data/services/logging_service.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/data/providers/dialog_provider.dart';

import 'dart:async';

String sanitizeError(String error) {
  error = error
      .replaceAll('FirebaseError: ', '')
      .replaceAll(RegExp(r'\(.*\)'), '')
      .replaceAll(RegExp(r'\[.*\]'), '')
      .trim();

  if (error.contains('An account already exists with the same email address')) {
    return appLocalizationService.getLocalization().accountExistsWithSameEmail;
  }
  if (error.contains('The password is invalid')) {
    return appLocalizationService.getLocalization().passwordInvalid;
  }
  if (error.contains('There is no user record')) {
    return appLocalizationService.getLocalization().noAccountFound;
  }
  if (error
      .contains('The email address is already in use by another account')) {
    return appLocalizationService.getLocalization().emailAddressAlreadyInUse;
  }
  if (error.contains('Missing or insufficient permission')) {
    return appLocalizationService.getLocalization().notAuthorized;
  }
  if (error.trim().toLowerCase() == 'INTERNAL'.toLowerCase()) {
    return appLocalizationService.getLocalization().somethingWentWrong;
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
