import 'package:duty_client/features/scanner/domain/duty_scan_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DutyScanParser.parse', () {
    test('parses event qr links', () {
      final result = DutyScanParser.parse('duty://event/141');

      expect(result.type, DutyScanType.event);
      expect(result.eventId, 141);
    });

    test('parses event qr links behind a prefixed web path', () {
      final result = DutyScanParser.parse(
        'http://localhost/v2/open/event/141?source=event-qr',
      );

      expect(result.type, DutyScanType.event);
      expect(result.eventId, 141);
    });

    test('parses transfer recipient qr links', () {
      final result = DutyScanParser.parse('duty://transfer-recipient/44');

      expect(result.type, DutyScanType.transferRecipient);
      expect(result.recipientId, 44);
    });

    test('parses transfer recipient links behind a prefixed web path', () {
      final result = DutyScanParser.parse(
        'http://localhost/v2/open/transfer-recipient/44',
      );

      expect(result.type, DutyScanType.transferRecipient);
      expect(result.recipientId, 44);
    });

    test('parses transfer ticket qr links', () {
      final result = DutyScanParser.parse(
        'duty://transfer-ticket?token=secure-ticket-token',
      );

      expect(result.type, DutyScanType.transferTicket);
      expect(result.transferToken, 'secure-ticket-token');
    });

    test('marks unknown content as unsupported', () {
      final result = DutyScanParser.parse('hello-duty');

      expect(result.type, DutyScanType.unsupported);
    });
  });
}
