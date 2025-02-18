/// Class for an exception with a message that will be shown directly to
/// the user.
class VisibleException implements Exception {
  final String msg;

  const VisibleException(this.msg);

  @override
  String toString() => msg;
}
