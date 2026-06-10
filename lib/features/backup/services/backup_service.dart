import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/error/exceptions.dart';
import '../../sales_entry/domain/entities/sales_entry.dart';
import '../../sales_entry/providers/sales_entry_providers.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref);
});

class BackupService {
  final Ref ref;

  BackupService(this.ref);

  Future<Directory> _backupDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'backups'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Map<String, Object?> _entryToJson(SalesEntry entry) {
    return {
      'id': entry.id,
      'date': entry.date.toIso8601String(),
      'salesmanName': entry.salesmanName,
      'area': entry.area,
      'value': entry.value,
      'shopCount': entry.shopCount,
      'cashCollection': entry.cashCollection,
      'checkCollection': entry.checkCollection,
      'createdAt': entry.createdAt?.toIso8601String(),
      'updatedAt': entry.updatedAt?.toIso8601String(),
      'isDeleted': entry.isDeleted,
      'syncStatus': entry.syncStatus,
      'lastSyncedAt': entry.lastSyncedAt?.toIso8601String(),
      'deviceId': entry.deviceId,
    };
  }

  SalesEntry _entryFromJson(Map<String, dynamic> json) {
    return SalesEntry(
      id: json['id'] as int?,
      date: DateTime.parse(json['date'] as String),
      salesmanName: json['salesmanName'] as String? ?? '',
      area: json['area'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      shopCount: (json['shopCount'] as num?)?.toInt() ?? 0,
      cashCollection: (json['cashCollection'] as num?)?.toDouble() ?? 0,
      checkCollection: (json['checkCollection'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      deviceId: json['deviceId'] as String?,
    );
  }

  Future<List<File>> listBackups() async {
    final directory = await _backupDirectory();
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  Future<String> exportData() async {
    final entries = await ref.read(getAllEntriesProvider).call();
    final directory = await _backupDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File(p.join(directory.path, 'eikon_backup_$timestamp.json'));

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'entryCount': entries.length,
      'entries': entries.map(_entryToJson).toList(growable: false),
    };

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
    return file.path;
  }

  Future<String> importLatestBackup() async {
    final backups = await listBackups();
    if (backups.isEmpty) {
      throw ValidationException('No backup files were found.');
    }

    final latestFile = backups.first;
    final raw = await latestFile.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw ValidationException('The latest backup file is invalid.');
    }

    final entriesJson = decoded['entries'];
    if (entriesJson is! List) {
      throw ValidationException('The latest backup file does not contain data.');
    }

    final entries = entriesJson
        .whereType<Map>()
        .map((item) => _entryFromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    await ref.read(replaceAllEntriesProvider).call(entries);
    return latestFile.path;
  }
}
