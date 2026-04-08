import '../../../core/services/app_link_service.dart';

enum DutyScanType { event, transferRecipient, transferTicket, unsupported }

class DutyScanResult {
  const DutyScanResult._({
    required this.type,
    this.eventId,
    this.recipientId,
    this.transferToken,
    required this.rawValue,
  });

  final DutyScanType type;
  final int? eventId;
  final int? recipientId;
  final String? transferToken;
  final String rawValue;

  factory DutyScanResult.event({
    required int eventId,
    required String rawValue,
  }) {
    return DutyScanResult._(
      type: DutyScanType.event,
      eventId: eventId,
      rawValue: rawValue,
    );
  }

  factory DutyScanResult.transferRecipient({
    required int recipientId,
    required String rawValue,
  }) {
    return DutyScanResult._(
      type: DutyScanType.transferRecipient,
      recipientId: recipientId,
      rawValue: rawValue,
    );
  }

  factory DutyScanResult.transferTicket({
    required String transferToken,
    required String rawValue,
  }) {
    return DutyScanResult._(
      type: DutyScanType.transferTicket,
      transferToken: transferToken,
      rawValue: rawValue,
    );
  }

  factory DutyScanResult.unsupported(String rawValue) {
    return DutyScanResult._(type: DutyScanType.unsupported, rawValue: rawValue);
  }
}

class DutyScanParser {
  DutyScanParser._();

  static DutyScanResult parse(String rawValue) {
    final raw = rawValue.trim();
    if (raw.isEmpty) {
      return DutyScanResult.unsupported(rawValue);
    }

    final uri = Uri.tryParse(raw);
    if (uri == null) {
      return DutyScanResult.unsupported(rawValue);
    }

    final eventId = AppLinkParser.eventIdFromUri(uri);
    if (eventId != null && eventId > 0) {
      return DutyScanResult.event(eventId: eventId, rawValue: rawValue);
    }

    final recipientId = AppLinkParser.transferRecipientIdFromUri(uri);
    if (recipientId != null && recipientId > 0) {
      return DutyScanResult.transferRecipient(
        recipientId: recipientId,
        rawValue: rawValue,
      );
    }

    final transferToken = AppLinkParser.transferTicketTokenFromUri(uri);
    if (transferToken != null && transferToken.isNotEmpty) {
      return DutyScanResult.transferTicket(
        transferToken: transferToken,
        rawValue: rawValue,
      );
    }

    return DutyScanResult.unsupported(rawValue);
  }
}
