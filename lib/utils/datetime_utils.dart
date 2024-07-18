import 'package:intl/intl.dart';

class DateTimeUtils {
  static final dateFormat = DateFormat('d MMM, y');

  static String minuteToHHMM(int totalMinutes, {bool? showHourAndMinute}) {
    final hh = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final mm = (totalMinutes % 60).toString().padLeft(2, '0');

    final showHourAndMinutePostText = showHourAndMinute ?? true;
    return "$hh:$mm ${showHourAndMinutePostText ? "hh:mm" : ""}";
  }
}
