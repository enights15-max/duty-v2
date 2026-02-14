import 'package:cliente_v2/core/constants/app_constants.dart';

class EventModel {
  final int id;
  final String title;
  final String thumbnail;
  final String? address;
  final String? date;
  final String? time;
  final String? organizer;
  final dynamic startPrice; // Can be int or string 'free'

  EventModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.address,
    this.date,
    this.time,
    this.organizer,
    this.startPrice,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'] ?? '',
      thumbnail:
          (json['thumbnail'] != null &&
              !json['thumbnail'].toString().startsWith('http'))
          ? '${AppConstants.imageBaseUrl}${json['thumbnail']}'
          : json['thumbnail'] ?? '',
      address: json['address'],
      date: json['date'],
      time: json['time'],
      organizer: json['organizer'],
      startPrice: json['start_price'],
    );
  }
  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, thumbnail: $thumbnail, address: $address, date: $date, time: $time, organizer: $organizer, startPrice: $startPrice)';
  }
}
