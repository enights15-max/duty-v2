import 'package:duty_client/core/services/app_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLinkParser.eventIdFromUri', () {
    test('parses custom duty scheme links', () {
      final uri = Uri.parse('duty://event/321');

      expect(AppLinkParser.eventIdFromUri(uri), 321);
    });

    test('parses shared web bridge links', () {
      final uri = Uri.parse('https://duty.do/open/event/654/after-brunch');

      expect(AppLinkParser.eventIdFromUri(uri), 654);
    });

    test('parses query based fallback links', () {
      final uri = Uri.parse('https://duty.do/download-app?event=987');

      expect(AppLinkParser.eventIdFromUri(uri), 987);
    });
  });

  group('AppLinkParser.transferRecipientIdFromUri', () {
    test('parses custom transfer recipient links', () {
      final uri = Uri.parse('duty://transfer-recipient/321');

      expect(AppLinkParser.transferRecipientIdFromUri(uri), 321);
    });

    test('parses shared transfer recipient bridge links', () {
      final uri = Uri.parse('https://duty.do/open/transfer-recipient/654');

      expect(AppLinkParser.transferRecipientIdFromUri(uri), 654);
    });
  });

  group('AppLinkParser.transferTicketTokenFromUri', () {
    test('parses custom transfer ticket links', () {
      final uri = Uri.parse('duty://transfer-ticket?token=abc123');

      expect(AppLinkParser.transferTicketTokenFromUri(uri), 'abc123');
    });
  });
}
