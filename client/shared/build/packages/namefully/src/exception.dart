import 'name.dart';

/// The [Exception] types supported by [Namefully].
enum NameExceptionType {
  /// Thrown when a name entry/argument is incorrect.
  ///
  /// For example, a name should have a minimum of 2 characters, so an empty
  /// string or a string of one character would cause this kind of exception.
  input,

  /// Thrown when the name components don't match the validation rules if the
  /// [Config.bypass] is not flagged up. This bypass option skips the validation
  /// rules.
  ///
  /// See also:
  ///   * [ValidationException]
  validation,

  /// Thrown by not allowed operations such as in NameBuilder or name formatting.
  ///
  /// See also:
  ///   * [NotAllowedException]
  ///   * [NameBuilder]
  ///   * [Namefully.format]
  notAllowed,

  /// Thrown by any other unknown sources or unexpected situation.
  unknown,
}

/// Base class for all name-related exceptions.
///
/// An [Exception] is intended to convey information to the user about a failure,
/// so that the error can be addressed programmatically.
///
/// A name handling failure is not considered an error that should cause a program
/// failure. Au contraire, it is expected that a programmer using this utility
/// would consider validating a name using its own business rules. That is not
/// this utility's job to guess those rules. So, the predefined `ValidationRules`
/// obey some common validation techniques when it comes to sanitizing a person
/// name. For this reason, the [Config.bypass] is set to `true` by default,
/// indicating that those predefined rules should be skipped for the sake of the
/// program.
///
/// A programmer may leverage [Parser]s to indicate business-tailored rules if
/// he or she wants this utility to perform those safety checks behind the
/// scenes.
///
/// A name exception intends to provide useful information about what causes
/// the error and let the user take initiative on what happens next to the given
/// name: reconstructing it or skipping it.
abstract class NameException implements Exception {
  /// Enables const constructors.
  const NameException._([
    this.message = '',
    this.source,
    this.type = NameExceptionType.unknown,
  ]);

  /// Creates a concrete `NameException` with an optional error [message].
  const factory NameException([String message, Object? src]) = _NameException;

  /// Creates a new `InputException` with an optional error [message].
  const factory NameException.input({
    required Object source,
    String message,
  }) = InputException;

  /// Creates an error containing the invalid [nameType] and a [message] that
  /// briefly describes the problem if provided.
  const factory NameException.validation({
    required Object source,
    required String nameType,
    String message,
  }) = ValidationException;

  /// Creates a new `NotAllowedException` with an optional error [message].
  const factory NameException.notAllowed({
    required Object source,
    String message,
    String operation,
  }) = NotAllowedException;

  /// Creates a new `UnknownException` with an optional error [message].
  ///
  /// Optionally, a [stackTrace] and an [error] revealing the true nature of
  /// the failure.
  factory NameException.unknown({
    required Object source,
    StackTrace? stackTrace,
    Object? error,
    String message,
  }) = UnknownException;

  /// The message describing the failure.
  final String message;

  /// The actual source input which caused the error.
  final dynamic source;

  /// The name exception type.
  final NameExceptionType type;

  /// The string value from the name source input.
  String get sourceAsString {
    var input = '';
    if (source == null) input = 'null';
    if (source is String) input = source;
    if (source is List<String>) input = source.join(' ');
    if (source is Name) input = source.toString();
    if (source is List<Name>) input = source.map((n) => n.toString()).join(' ');
    return input;
  }

  @override
  String toString() {
    var report = '$runtimeType ($sourceAsString)';
    if (message.isNotEmpty) report = '$report: $message';
    return report;
  }
}

/// Concrete name exception for convenience with a [message] and a [source].
class _NameException extends NameException {
  const _NameException([String message = '', Object? source])
      : super._(message, source);
}

/// An exception thrown when a name source input is incorrect.
///
/// A [Name] is a name for this utility under certain criteria (i.e., 2+ chars),
/// hence, a wrong input will cause this kind of exception. Another common reason
/// may be a wrong key in a Json name parsing mechanism.
///
/// Keep in mind that this exception is different from a [ValidationException].
class InputException extends NameException {
  /// Creates a new `InputException` with an optional error [message].
  ///
  /// The [source] is by nature a string content, maybe wrapped up in a different
  /// type. This string value may be extracted to form the following output:
  ///   "InputException (stringName)",
  ///   "InputException (stringName): message".
  const InputException({required Object source, String message = ''})
      : super._(message, source, NameExceptionType.input);
}

/// An exception thrown to indicate that a name fails the validation rules.
class ValidationException extends NameException {
  /// Creates error containing the invalid [nameType] and a [message] that
  /// briefly describes the problem if provided.
  ///
  /// For example, a validation error can be interpreted as:
  ///     "ValidationException (nameType='stringName')",
  ///     "ValidationException (nameType='stringName'): message"
  const ValidationException({
    required Object source,
    required this.nameType,
    String message = '',
  }) : super._(message, source, NameExceptionType.validation);

  /// Name of the invalid `nameType` if available.
  final String nameType;

  @override
  String toString() {
    var report = "$runtimeType ($nameType='$sourceAsString')";
    if (message.isNotEmpty) report = '$report: $message';
    return report;
  }
}

/// Thrown by not allowed operations such as in [NameBuilder] or name formatting.
///
/// For example, this exception is thrown when a [NameBuilder] tries to perform
/// an operation while its current status is marked as closed. Another cause for
/// this exception is when trying to [Namefully.format] a name accordingly using
/// a non-supported key.
class NotAllowedException extends NameException {
  /// Creates a new `NotAllowedException` with an optional error [message] and
  /// the [operation] name.
  ///
  /// For example, an exception of this can be interpreted as:
  ///     "NotAllowedException (stringName)",
  ///     "NotAllowedException (stringName) - operationName",
  ///     "NotAllowedException (stringName) - operationName: message"
  const NotAllowedException({
    required Object source,
    String message = '',
    this.operation = '',
  }) : super._(message, source, NameExceptionType.notAllowed);

  /// The revoked operation name.
  final String operation;

  @override
  String toString() {
    var report = '$runtimeType ($sourceAsString)';
    if (operation.isNotEmpty) report = '$report - $operation';
    if (message.isNotEmpty) report = '$report: $message';
    return report;
  }
}

/// A fallback exception thrown by any unknown sources or unexpected failure
/// that are not [NameException]s.
///
/// In this particular case, a [stackTrace] remains useful as it provides details
/// on the sources and the true nature of the [error].
/// At this point, deciding whether to exit the program or not depends on the
/// programmer.
class UnknownException extends NameException {
  /// Creates a new `UnknownException` with an optional error [message].
  ///
  /// Optionally, a [stackTrace] and an [error] revealing the true nature of
  /// the failure. The [Error.stackTrace], if any, is considered as fallback if
  /// [stackTrace] is provided.
  UnknownException({
    required Object source,
    StackTrace? stackTrace,
    this.error,
    String message = '',
  })  : stackTrace = stackTrace ?? (error is Error ? error.stackTrace : null),
        super._(message, source);

  /// Trace revealing the source of that error.
  final StackTrace? stackTrace;

  /// The possible unknown error.
  final Object? error;

  @override
  String toString() {
    var report = super.toString();
    if (stackTrace != null && error == null) report += '\n$stackTrace';
    if (error != null) report += '\n$error';
    return report;
  }
}
