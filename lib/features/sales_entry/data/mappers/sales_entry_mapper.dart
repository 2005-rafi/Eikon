import 'package:drift/drift.dart';
import '../../../../data/database/app_database.dart' as db;
import '../../domain/entities/sales_entry.dart' as domain;

class SalesEntryMapper {
  static domain.SalesEntry fromDb(db.SalesEntry data) {
    return domain.SalesEntry(
      id: data.id,
      date: data.date,
      salesmanName: data.salesmanName,
      area: data.area,
      value: data.value,
      shopCount: data.shopCount,
      cashCollection: data.cashCollection,
      checkCollection: data.checkCollection,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isDeleted: data.isDeleted,
      syncStatus: data.syncStatus,
      lastSyncedAt: data.lastSyncedAt,
      deviceId: data.deviceId,
    );
  }

  static db.SalesEntriesCompanion toDb(domain.SalesEntry entity) {
    return db.SalesEntriesCompanion(
      id: entity.id == null ? const Value.absent() : Value(entity.id!),
      date: Value(entity.date),
      salesmanName: Value(entity.salesmanName),
      area: Value(entity.area),
      value: Value(entity.value),
      shopCount: Value(entity.shopCount),
      cashCollection: Value(entity.cashCollection),
      checkCollection: Value(entity.checkCollection),
      createdAt: entity.createdAt == null
          ? const Value.absent()
          : Value(entity.createdAt!),
      updatedAt: entity.updatedAt == null
          ? const Value.absent()
          : Value(entity.updatedAt!),
      isDeleted: Value(entity.isDeleted),
      syncStatus: Value(entity.syncStatus),
      lastSyncedAt: entity.lastSyncedAt == null
          ? const Value.absent()
          : Value(entity.lastSyncedAt!),
      deviceId: entity.deviceId == null
          ? const Value.absent()
          : Value(entity.deviceId!),
    );
  }
}
