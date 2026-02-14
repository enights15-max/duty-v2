import 'scan_remote_data_source.dart';

class ScanResult {
  final bool success;
  final String message;
  final String? bookingId;
  final String type; // success, error, warning

  ScanResult({
    required this.success,
    required this.message,
    this.bookingId,
    required this.type,
  });
}

class ScanRepository {
  final ScanRemoteDataSource _remoteDataSource;

  ScanRepository(this._remoteDataSource);

  Future<ScanResult> verifyTicket(String qrCode) async {
    try {
      final response = await _remoteDataSource.verifyTicket(qrCode);

      // Analyze response based on AdminScannerController
      // 'alert_type' => 'success' | 'error'
      // 'message' => 'Verified' | 'Already Scanned' | 'Unverified'

      final alertType = response['alert_type'] ?? 'error';
      final message = response['message'] ?? 'Unknown Error';
      final bookingId = response['booking_id'];

      return ScanResult(
        success: alertType == 'success',
        message: message,
        bookingId: bookingId,
        type: alertType,
      );
    } catch (e) {
      return ScanResult(
        success: false,
        message: 'Error de conexión: $e',
        type: 'error',
      );
    }
  }
}
