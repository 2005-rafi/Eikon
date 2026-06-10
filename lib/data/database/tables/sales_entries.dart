import 'package:drift/drift.dart';

@TableIndex(name: 'idx_sales_entries_date', columns: {#date})
@TableIndex(name: 'idx_sales_entries_salesman', columns: {#salesmanName})
@TableIndex(name: 'idx_sales_entries_area', columns: {#area})
class SalesEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get salesmanName => text()();
  TextColumn get area => text()();
  RealColumn get value => real().customConstraint('CHECK (value >= 0)')();
  IntColumn get shopCount =>
      integer().customConstraint('CHECK (shop_count >= 0)')();
  RealColumn get cashCollection =>
      real().customConstraint('CHECK (cash_collection >= 0)')();
  RealColumn get checkCollection =>
      real().customConstraint('CHECK (check_collection >= 0)')();

  // Audit & Future-ready Backend Integration fields
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get syncStatus =>
      integer().withDefault(const Constant(0))(); // 0 = unsynced
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
}
