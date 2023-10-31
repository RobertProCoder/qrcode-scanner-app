import 'package:intl/intl.dart';

class Time {
  static String convertTimeToStandartTime(String militaryTime) {
    final militaryTimeFormat = DateFormat('HH:mm');
    final militaryTimeParsed = militaryTimeFormat.parse(militaryTime);

    // Format the parsed time in standard time format
    final standardTimeFormat = DateFormat('h:mm a');
    final standardTime = standardTimeFormat.format(militaryTimeParsed);

    return standardTime;
  }
}
