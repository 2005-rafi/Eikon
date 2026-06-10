import '../entities/sales_entry.dart';
import '../repositories/sales_entry_repository.dart';

class CreateSalesEntryUseCase {
  final SalesEntryRepository repository;
  CreateSalesEntryUseCase(this.repository);

  Future<void> call(SalesEntry entry) async {
    // Domain rules applied inside the entity's constructor via ValidationException
    return await repository.createEntry(entry);
  }
}

class UpdateSalesEntryUseCase {
  final SalesEntryRepository repository;
  UpdateSalesEntryUseCase(this.repository);

  Future<void> call(SalesEntry entry) async {
    if (entry.id == null) throw ArgumentError('Entry ID required for update');
    return await repository.updateEntry(entry);
  }
}

class DeleteSalesEntryUseCase {
  final SalesEntryRepository repository;
  DeleteSalesEntryUseCase(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteEntry(id);
  }
}

class GetEntriesStreamUseCase {
  final SalesEntryRepository repository;
  GetEntriesStreamUseCase(this.repository);

  Stream<List<SalesEntry>> call() {
    return repository.getEntriesStream();
  }
}

class GetAllEntriesUseCase {
  final SalesEntryRepository repository;
  GetAllEntriesUseCase(this.repository);

  Future<List<SalesEntry>> call() {
    return repository.getAllEntries();
  }
}

class ReplaceAllEntriesUseCase {
  final SalesEntryRepository repository;
  ReplaceAllEntriesUseCase(this.repository);

  Future<void> call(List<SalesEntry> entries) {
    return repository.replaceAllEntries(entries);
  }
}

class FetchSuggestionsUseCase {
  final SalesEntryRepository repository;
  FetchSuggestionsUseCase(this.repository);

  Future<List<String>> call(String type, String query) async {
    return await repository.fetchSuggestions(type, query);
  }
}
