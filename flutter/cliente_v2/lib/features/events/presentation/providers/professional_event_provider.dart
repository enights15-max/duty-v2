import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/professional_event_remote_data_source.dart';
import '../../data/models/professional_collaboration_summary_model.dart';
import '../../data/models/professional_dashboard_model.dart';
import '../../data/models/professional_event_inventory_detail_model.dart';
import '../../data/models/professional_event_ticket_model.dart';
import '../../data/repositories/professional_event_repository.dart';

final professionalEventRemoteDataSourceProvider =
    Provider<ProfessionalEventRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return ProfessionalEventRemoteDataSource(apiClient);
    });

final professionalEventRepositoryProvider =
    Provider<ProfessionalEventRepository>((ref) {
      final dataSource = ref.watch(professionalEventRemoteDataSourceProvider);
      return ProfessionalEventRepository(dataSource);
    });

final professionalDashboardProvider =
    FutureProvider.autoDispose<ProfessionalDashboardModel>((ref) async {
      final repository = ref.watch(professionalEventRepositoryProvider);
      return repository.getDashboard();
    });

final professionalDashboardRangeProvider = FutureProvider.autoDispose
    .family<ProfessionalDashboardModel, String>((ref, range) async {
      final repository = ref.watch(professionalEventRepositoryProvider);
      return repository.getDashboard(range: range);
    });

final professionalEventInventoryProvider = FutureProvider.autoDispose
    .family<ProfessionalEventInventoryDetailModel, int>((ref, eventId) async {
      final repository = ref.watch(professionalEventRepositoryProvider);
      return repository.getInventoryDetail(eventId);
    });

final professionalEventTicketsProvider = FutureProvider.autoDispose
    .family<ProfessionalEventTicketsPayload, int>((ref, eventId) async {
      final repository = ref.watch(professionalEventRepositoryProvider);
      return repository.getTickets(eventId);
    });

final professionalEventCollaboratorsProvider = FutureProvider.autoDispose
    .family<ProfessionalEventCollaborationSummary, int>((ref, eventId) async {
      final repository = ref.watch(professionalEventRepositoryProvider);
      return repository.getEventCollaborators(eventId);
    });

final professionalCollaborationsProvider =
    FutureProvider.autoDispose<ProfessionalCollaborationSummary>((ref) async {
      final repository = ref.watch(professionalEventRepositoryProvider);
      return repository.getCollaborations();
    });
