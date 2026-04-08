import 'package:intl/intl.dart';
void main() {
  var d1 = DateFormat('EEE, MMM dd, yyyy hh:mma').parse('Sat, Jan 03, 2026 08:00pm');
  print('Parsed 1: $d1');
  
  var d2 = DateTime.tryParse('2026-03-01');
  print('Parsed 2: $d2');
}
