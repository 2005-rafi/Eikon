import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/daos/sales_entry_dao.dart';
import '../data/repositories/sales_entry_repository_impl.dart';
import '../domain/entities/sales_entry.dart' as entity;
import '../domain/repositories/sales_entry_repository.dart';
import '../domain/use_cases/sales_entry_use_cases.dart';

// Providers for foundational layers
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase(); // Global singleton instantiation (should ideally be overridden in ProviderScope if testing)
});

final salesEntryDaoProvider = Provider<SalesEntryDao>((ref) {
  return ref.watch(databaseProvider).salesEntryDao;
});

final salesEntryRepositoryProvider = Provider<SalesEntryRepository>((ref) {
  return SalesEntryRepositoryImpl(ref.watch(salesEntryDaoProvider));
});

// Use case providers
final createSalesEntryProvider = Provider<CreateSalesEntryUseCase>((ref) {
  return CreateSalesEntryUseCase(ref.watch(salesEntryRepositoryProvider));
});

final updateSalesEntryProvider = Provider<UpdateSalesEntryUseCase>((ref) {
  return UpdateSalesEntryUseCase(ref.watch(salesEntryRepositoryProvider));
});

final deleteSalesEntryProvider = Provider<DeleteSalesEntryUseCase>((ref) {
  return DeleteSalesEntryUseCase(ref.watch(salesEntryRepositoryProvider));
});

final getEntriesStreamProvider = Provider<GetEntriesStreamUseCase>((ref) {
  return GetEntriesStreamUseCase(ref.watch(salesEntryRepositoryProvider));
});

final getAllEntriesProvider = Provider<GetAllEntriesUseCase>((ref) {
  return GetAllEntriesUseCase(ref.watch(salesEntryRepositoryProvider));
});

final replaceAllEntriesProvider = Provider<ReplaceAllEntriesUseCase>((ref) {
  return ReplaceAllEntriesUseCase(ref.watch(salesEntryRepositoryProvider));
});

final fetchSuggestionsProvider = Provider<FetchSuggestionsUseCase>((ref) {
  return FetchSuggestionsUseCase(ref.watch(salesEntryRepositoryProvider));
});

// Streams
final salesEntriesStreamProvider = StreamProvider<List<entity.SalesEntry>>((ref) {
  return ref.watch(getEntriesStreamProvider).call();
});
