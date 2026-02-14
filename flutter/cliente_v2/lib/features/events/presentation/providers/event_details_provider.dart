import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_detail_model.dart';
import 'home_provider.dart';

// Family provider to fetch details for a specific event ID
final eventDetailsProvider = FutureProvider.family<EventDetailModel, int>((
  ref,
  eventId,
) async {
  final repository = ref.watch(eventRepositoryProvider);
  return await repository.getEventDetails(eventId);
});
