import 'package:cliente_v2/core/constants/app_constants.dart';
import 'event_model.dart';

class EventDetailModel extends EventModel {
  final String description;
  final String? refundPolicy;
  final List<String> images;
  final List<TicketModel> tickets;
  final OrganizerModel? organizerModel;

  EventDetailModel({
    required super.id,
    required super.title,
    required super.thumbnail,
    super.address,
    super.date,
    super.time,
    super.organizer,
    required this.description,
    this.refundPolicy,
    required this.images,
    required this.tickets,
    this.organizerModel,
    this.coverImage,
    this.latitude,
    this.longitude,
  });

  final double? latitude;
  final double? longitude;
  final String? coverImage;

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    final organizerData = json['organizer'] ?? json['admin'];
    final organizerObj = organizerData != null
        ? OrganizerModel.fromJson(organizerData)
        : null;

    return EventDetailModel(
      id: content['id'],
      title: content['title'],
      thumbnail: () {
        final thumb =
            content['cover'] ?? content['image'] ?? content['thumbnail'] ?? '';
        return (thumb.isNotEmpty && !thumb.toString().startsWith('http'))
            ? '${AppConstants.imageBaseUrl}$thumb'
            : thumb;
      }(),
      address: content['address'],
      date: content['start_date'],
      time: content['start_time'],
      organizer: organizerObj?.name, // Pass name string to parent
      description: content['description'] ?? '',
      refundPolicy: content['refund_policy'],
      images:
          (json['images'] as List?)?.map((e) {
            final img = e['image'] as String;
            return (img.isNotEmpty && !img.startsWith('http'))
                ? '${AppConstants.eventCoverBaseUrl}$img'
                : img;
          }).toList() ??
          [],
      tickets:
          (json['tickets'] as List?)
              ?.map((e) => TicketModel.fromJson(e))
              .toList() ??
          [],
      coverImage: () {
        final cover = content['images'] ?? content['image'] ?? '';
        return (cover.isNotEmpty && !cover.toString().startsWith('http'))
            ? '${AppConstants.eventCoverBaseUrl}$cover'
            : cover;
      }(),
      organizerModel: organizerObj,
      latitude: double.tryParse(
        content['latitude']?.toString() ?? content['lat']?.toString() ?? '',
      ),
      longitude: double.tryParse(
        content['longitude']?.toString() ?? content['lng']?.toString() ?? '',
      ),
    );
  }
  @override
  String toString() {
    return 'EventDetailModel(id: $id, title: $title, thumbnail: $thumbnail, address: $address, date: $date, time: $time, organizer: $organizer, description: $description, refundPolicy: $refundPolicy, images: $images, tickets: $tickets, organizerModel: $organizerModel, coverImage: $coverImage, lat: $latitude, lng: $longitude)';
  }
}

class TicketModel {
  final int id;
  final String title;
  final double price;
  final String? pricingType;
  final bool available;

  TicketModel({
    required this.id,
    required this.title,
    required this.price,
    this.pricingType,
    required this.available,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      title: json['title'] ?? 'Ticket',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      pricingType: json['pricing_type'],
      available:
          (json['ticket_stock'] == null ||
          (json['ticket_stock'] is int && json['ticket_stock'] > 0)),
    );
  }
}

class OrganizerModel {
  final String name;
  final String? email;
  final String? photo;

  OrganizerModel({required this.name, this.email, this.photo});

  factory OrganizerModel.fromJson(Map<String, dynamic> json) {
    return OrganizerModel(
      name: json['name'] ?? json['username'] ?? 'Organizer',
      email: json['email'],
      photo: json['photo'],
    );
  }
}
