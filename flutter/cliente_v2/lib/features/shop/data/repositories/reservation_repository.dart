import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../datasources/reservation_remote_data_source.dart';
import '../models/reservation_model.dart';

final reservationRemoteDataSourceProvider =
    Provider<ReservationRemoteDataSource>((ref) {
      return ReservationRemoteDataSource(ref.watch(apiClientProvider));
    });

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository(ref.watch(reservationRemoteDataSourceProvider));
});

class ReservationRepository {
  final ReservationRemoteDataSource _remoteDataSource;

  ReservationRepository(this._remoteDataSource);

  Future<List<ReservationModel>> getReservations() async {
    final rows = await _remoteDataSource.getReservations();
    return rows
        .whereType<Map>()
        .map(
          (item) => ReservationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<ReservationModel> getReservation(int id) async {
    final payload = await _remoteDataSource.getReservation(id);
    return ReservationModel.fromJson(payload);
  }

  Future<ReservationModel> createReservation(
    Map<String, dynamic> payload,
  ) async {
    final json = await _remoteDataSource.createReservation(payload);
    return ReservationModel.fromJson(json);
  }

  Future<Map<String, dynamic>> previewReservation(
    Map<String, dynamic> payload,
  ) async {
    return _remoteDataSource.previewReservation(payload);
  }

  Future<ReservationModel> payReservation(
    int reservationId,
    Map<String, dynamic> payload,
  ) async {
    final json = await _remoteDataSource.payReservation(reservationId, payload);
    return ReservationModel.fromJson(json);
  }

  Future<Map<String, dynamic>> previewReservationPayment(
    int reservationId,
    Map<String, dynamic> payload,
  ) async {
    return _remoteDataSource.previewReservationPayment(reservationId, payload);
  }
}
