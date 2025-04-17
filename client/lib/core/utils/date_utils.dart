import 'package:intl/intl.dart';

String dateTimeFormat({required DateTime date}) {
  var formattedDate = DateFormat('MMM d yyyy, h:mma').format(date);
  return formattedDate;
}

int differenceInDays(DateTime a, DateTime b) {
  return dateTimeWithoutTime(a).difference(dateTimeWithoutTime(b)).inDays;
}

DateTime dateTimeWithoutTime(DateTime d) {
  return DateTime(d.year, d.month, d.day);
}

String durationString(Duration duration, {bool readAsHuman = false}) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  if (duration.inHours > 0) {
    final timeString = readAsHuman
        ? '${duration.inHours} hr ${int.parse(twoDigitMinutes) > 0 ? '$twoDigitMinutes min' : ''}'
        : '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';

    return timeString;
  } else {
    return readAsHuman
        ? '$twoDigitMinutes min'
        : '$twoDigitMinutes:$twoDigitSeconds';
  }
}
