import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sales_entries.dart';

part 'sales_entry_dao.g.dart';

@DriftAccessor(tables: [SalesEntries])
class SalesEntryDao extends DatabaseAccessor<AppDatabase>
    with _$SalesEntryDaoMixin {
  SalesEntryDao(super.db);

  Stream<List<SalesEntry>> watchAllEntries() {
    return (select(salesEntries)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(100))
        .watch();
  }

  Future<List<SalesEntry>> getAllEntriesFuture() {
    return (select(salesEntries)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<int> insertEntry(SalesEntriesCompanion entry) {
    return transaction(() async {
      return await into(salesEntries).insert(entry);
    });
  }

  Future<bool> updateEntry(SalesEntriesCompanion entry) {
    return transaction(() async {
      final toUpdate = entry.copyWith(updatedAt: Value(DateTime.now()));
      return await update(salesEntries).replace(toUpdate);
    });
  }

  Future<int> deleteEntry(int id) {
    return transaction(() async {
      return await (update(
        salesEntries,
      )..where((tbl) => tbl.id.equals(id))).write(
        SalesEntriesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> replaceAllEntries(List<SalesEntriesCompanion> entries) {
    return transaction(() async {
      await delete(salesEntries).go();
      if (entries.isEmpty) {
        return;
      }

      await batch((batch) {
        batch.insertAll(
          salesEntries,
          entries,
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<List<String>> getSuggestions(String field, String query) async {
    if (query.trim().isEmpty) {
      return const [];
    }

    final queryLower = '%${query.toLowerCase()}%';

    Expression<String> column;
    if (field == 'salesman') {
      column = salesEntries.salesmanName;
    } else if (field == 'area') {
      column = salesEntries.area;
    } else {
      return [];
    }

    final queryRequest = selectOnly(salesEntries, distinct: true)
      ..addColumns([column])
      ..where(
        column.lower().like(queryLower) & salesEntries.isDeleted.equals(false),
      )
      ..orderBy([OrderingTerm.asc(column)])
      ..limit(10);

    final results = await queryRequest.get();
    return results
        .map((row) => row.read(column))
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getAnalytics(DateTime startDate, DateTime endDate) async {
    final entries = await (select(salesEntries)
      ..where((tbl) => tbl.isDeleted.equals(false) & tbl.date.isBiggerOrEqualValue(startDate) & tbl.date.isSmallerOrEqualValue(endDate))).get();
    
    if (entries.isEmpty) {
      return {
        'totalSales': 0.0,
        'totalCollections': 0.0,
        'totalShops': 0,
        'entryCount': 0,
        'cashCollection': 0.0,
        'checkCollection': 0.0,
        'entries': <SalesEntry>[],
      };
    }
    
    double totalSales = 0;
    double totalCash = 0;
    double totalCheck = 0;
    int totalShops = 0;
    
    for (final entry in entries) {
      totalSales += entry.value;
      totalCash += entry.cashCollection;
      totalCheck += entry.checkCollection;
      totalShops += entry.shopCount;
    }
    
    return {
      'totalSales': totalSales,
      'totalCollections': totalCash + totalCheck,
      'totalShops': totalShops,
      'entryCount': entries.length,
      'cashCollection': totalCash,
      'checkCollection': totalCheck,
      'entries': entries,
    };
  }
}
