class NormalizedDominicanPhone {
  final String areaCode;
  final String localNumber;
  final String e164;

  const NormalizedDominicanPhone({
    required this.areaCode,
    required this.localNumber,
    required this.e164,
  });
}

class PhoneAuthUtils {
  static const List<String> supportedAreaCodes = ['809', '829', '849'];

  static NormalizedDominicanPhone? normalizeDominicanPhone({
    required String selectedAreaCode,
    required String rawInput,
  }) {
    var digits = rawInput.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return null;
    }

    if (digits.length == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }

    String areaCode = selectedAreaCode;
    String localNumber = digits;

    if (digits.length == 10) {
      final inferredPrefix = digits.substring(0, 3);
      if (!supportedAreaCodes.contains(inferredPrefix)) {
        return null;
      }
      areaCode = '+1 $inferredPrefix';
      localNumber = digits.substring(3);
    }

    if (localNumber.length != 7) {
      return null;
    }

    final compactAreaCode = areaCode.replaceAll(' ', '');
    return NormalizedDominicanPhone(
      areaCode: areaCode,
      localNumber: localNumber,
      e164: '$compactAreaCode$localNumber',
    );
  }

  static String prettyPhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }

    if (digits.length == 10) {
      final prefix = digits.substring(0, 3);
      final middle = digits.substring(3, 6);
      final suffix = digits.substring(6);
      return '+1 $prefix $middle-$suffix';
    }

    return phone;
  }

  static String? extractOtpCode(String? rawInput) {
    if (rawInput == null || rawInput.trim().isEmpty) {
      return null;
    }

    final digits = rawInput.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) {
      return null;
    }

    return digits.substring(0, 6);
  }

  static String codeSendErrorMessage(String code, String? fallbackMessage) {
    switch (code) {
      case 'invalid-phone-number':
        return 'That phone number looks invalid. Check it and try again.';
      case 'quota-exceeded':
        return 'We hit the SMS limit for now. Please try again in a bit.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment before trying again.';
      case 'network-request-failed':
        return 'We could not reach Firebase. Check your connection and try again.';
      default:
        return fallbackMessage?.trim().isNotEmpty == true
            ? fallbackMessage!
            : 'We could not send the verification code right now.';
    }
  }

  static String codeVerifyErrorMessage(String code, String? fallbackMessage) {
    switch (code) {
      case 'invalid-verification-code':
        return 'That verification code is incorrect. Please try again.';
      case 'session-expired':
        return 'This code expired. Request a new one and try again.';
      case 'invalid-verification-id':
        return 'This verification session is no longer valid. Request a new code.';
      case 'network-request-failed':
        return 'We could not verify the code right now. Check your connection and try again.';
      default:
        return fallbackMessage?.trim().isNotEmpty == true
            ? fallbackMessage!
            : 'We could not verify that code. Please try again.';
    }
  }
}
