import '../../../../core/error/exceptions.dart';

class SalesEntry {
  static const double maxAmount = 999999999.99;
  static const int maxShopCount = 100000;

  final int? id;
  final DateTime date;
  final String salesmanName;
  final String area;
  final double value;
  final int shopCount;
  final double cashCollection;
  final double checkCollection;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final int syncStatus;
  final DateTime? lastSyncedAt;
  final String? deviceId;

  SalesEntry({
    this.id,
    required this.date,
    required String salesmanName,
    required String area,
    required this.value,
    required this.shopCount,
    required this.cashCollection,
    required this.checkCollection,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = 0,
    this.lastSyncedAt,
    this.deviceId,
  }) : salesmanName = salesmanName.trim(),
       area = area.trim() {
    _validate();
  }

  void _validate() {
    if (salesmanName.isEmpty) {
      throw ValidationException('Salesman name cannot be empty');
    }
    if (area.isEmpty) {
      throw ValidationException('Area cannot be empty');
    }
    if (value < 0) {
      throw ValidationException('Value cannot be negative');
    }
    if (value > maxAmount) {
      throw ValidationException('Value is too large');
    }
    if (shopCount < 0) {
      throw ValidationException('Shop count cannot be negative');
    }
    if (shopCount > maxShopCount) {
      throw ValidationException('Shop count is too large');
    }
    if (cashCollection < 0) {
      throw ValidationException('Cash collection cannot be negative');
    }
    if (cashCollection > maxAmount) {
      throw ValidationException('Cash collection is too large');
    }
    if (checkCollection < 0) {
      throw ValidationException('Check collection cannot be negative');
    }
    if (checkCollection > maxAmount) {
      throw ValidationException('Check collection is too large');
    }
  }

  SalesEntry copyWith({
    int? id,
    DateTime? date,
    String? salesmanName,
    String? area,
    double? value,
    int? shopCount,
    double? cashCollection,
    double? checkCollection,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? syncStatus,
    DateTime? lastSyncedAt,
    String? deviceId,
  }) {
    return SalesEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      salesmanName: salesmanName ?? this.salesmanName,
      area: area ?? this.area,
      value: value ?? this.value,
      shopCount: shopCount ?? this.shopCount,
      cashCollection: cashCollection ?? this.cashCollection,
      checkCollection: checkCollection ?? this.checkCollection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
