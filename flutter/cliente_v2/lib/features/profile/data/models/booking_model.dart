class BookingModel {
  final int id;
  final String bookingId;
  final double total;
  final String status;
  final String paymentStatus;
  final String eventTitle;
  final String? eventDate;
  final String? eventImage;
  final int quantity;
  final String? qrCodeUrl; // URL or path to QR code image if available directly

  BookingModel({
    required this.id,
    required this.bookingId,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.eventTitle,
    this.eventDate,
    this.eventImage,
    required this.quantity,
    this.qrCodeUrl,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Mapping based on typical Laravel API resource structure
    // Needs adjustment if actual API differs significantly
    return BookingModel(
      id: json['id'],
      bookingId: json['booking_id'] ?? '',
      total: double.tryParse(json['price'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      eventTitle: json['event'] != null
          ? json['event']['title']
          : (json['event_title'] ?? 'Unknown Event'),
      eventDate: json['event_date'],
      eventImage: json['event'] != null
          ? json['event']['thumbnail']
          : null, // Assuming relation loaded
      quantity: json['quantity'] ?? 1,
      qrCodeUrl: json['qr_image'], // Check if API provides this directly
    );
  }
}
