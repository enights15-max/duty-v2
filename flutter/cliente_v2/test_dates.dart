import 'package:intl/intl.dart';

void main() {
  String dateStr = 'Sat, Jan 03, 2026 08:00pm';
  // Replace am/pm with AM/PM to match DateFormat 'a'
  dateStr = dateStr.replaceAll('pm', 'PM').replaceAll('am', 'AM');

  try {
    DateTime date = DateFormat('EEE, MMM dd, yyyy hh:mma').parse(dateStr);
    print('SUCCESS! $date');
  } catch (e) {
    print('FAIL: $e');
  }
}
