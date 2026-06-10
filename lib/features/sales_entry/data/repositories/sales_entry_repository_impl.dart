import '../../domain/entities/sales_entry.dart';
import '../../domain/repositories/sales_entry_repository.dart';
import '../../../../data/database/daos/sales_entry_dao.dart';
import '../mappers/sales_entry_mapper.dart';
import '../../../../core/error/exceptions.dart';

class SalesEntryRepositoryImpl implements SalesEntryRepository {
  final SalesEntryDao dao;

  SalesEntryRepositoryImpl(this.dao);

  @override
  Future<void> createEntry(SalesEntry entry) async {
    try {
      await dao.insertEntry(SalesEntryMapper.toDb(entry));
    } catch (e) {
      throw DatabaseException('Failed to create entry: $e');
    }
  }

  @override
  Future<void> updateEntry(SalesEntry entry) async {
    try {
      final updated = await dao.updateEntry(SalesEntryMapper.toDb(entry));
      if (!updated) {
        throw DatabaseException('Entry not found for update.');
      }
    } catch (e) {
      if (e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Failed to update entry: $e');
    }
  }

  @override
  Future<void> deleteEntry(int id) async {
    try {
      final deletedCount = await dao.deleteEntry(id);
      if (deletedCount == 0) {
        throw DatabaseException('Entry not found for deletion.');
      }
    } catch (e) {
      if (e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Failed to delete entry: $e');
    }
  }

  @override
  Stream<List<SalesEntry>> getEntriesStream() {
    return dao.watchAllEntries().map(
      (list) => list.map(SalesEntryMapper.fromDb).toList(),
    );
  }

  @override
  Future<List<SalesEntry>> getAllEntries() async {
    try {
      final entries = await dao.getAllEntriesFuture();
      return entries.map(SalesEntryMapper.fromDb).toList(growable: false);
    } catch (e) {
      throw DatabaseException('Failed to load entries: $e');
    }
  }

  @override
  Future<void> replaceAllEntries(List<SalesEntry> entries) async {
    try {
      await dao.replaceAllEntries(
        entries.map(SalesEntryMapper.toDb).toList(growable: false),
      );
    } catch (e) {
      throw DatabaseException('Failed to restore entries: $e');
    }
  }

  @override
  Future<List<String>> fetchSuggestions(String type, String query) async {
    try {
      return await dao.getSuggestions(type, query);
    } catch (e) {
      throw DatabaseException('Failed to fetch suggestions: $e');
    }
  }
}
