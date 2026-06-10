import '../entities/sales_entry.dart';

abstract class SalesEntryRepository {
  Future<void> createEntry(SalesEntry entry);
  Future<void> updateEntry(SalesEntry entry);
  Future<void> deleteEntry(int id);
  Stream<List<SalesEntry>> getEntriesStream();
  Future<List<SalesEntry>> getAllEntries();
  Future<void> replaceAllEntries(List<SalesEntry> entries);
  Future<List<String>> fetchSuggestions(String type, String query);
}
