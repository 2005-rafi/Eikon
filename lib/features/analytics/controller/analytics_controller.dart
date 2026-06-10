import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/models/analytics_data.dart';
import '../../sales_entry/providers/sales_entry_providers.dart';
import '../../../data/database/app_database.dart';

class AnalyticsController extends AsyncNotifier<AnalyticsData> {
  TimePeriod _currentPeriod = TimePeriod.today;

  TimePeriod get currentPeriod => _currentPeriod;

  @override
  Future<AnalyticsData> build() async {
    return _fetchAnalytics(_currentPeriod);
  }

  Future<void> changePeriod(TimePeriod period) async {
    _currentPeriod = period;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAnalytics(period));
  }

  Future<AnalyticsData> _fetchAnalytics(TimePeriod period) async {
    final dao = ref.read(salesEntryDaoProvider);
    final dateRange = _getDateRange(period);
    final data = await dao.getAnalytics(dateRange.start, dateRange.end);

    final entries = data['entries'] as List<SalesEntry>;
    
    return AnalyticsData(
      totalSales: data['totalSales'] as double,
      totalCollections: data['totalCollections'] as double,
      totalShops: data['totalShops'] as int,
      entryCount: data['entryCount'] as int,
      cashCollection: data['cashCollection'] as double,
      checkCollection: data['checkCollection'] as double,
      salesTrend: _calculateTrend(entries, period),
      areaPerformance: _calculateAreaPerformance(entries),
      salesmanPerformance: _calculateSalesmanPerformance(entries),
      insights: _generateInsights(data, entries),
    );
  }

  DateTimeRange _getDateRange(TimePeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (period) {
      case TimePeriod.today:
        return DateTimeRange(start: today, end: now);
      case TimePeriod.week:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(start: weekStart, end: now);
      case TimePeriod.month:
        final monthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: monthStart, end: now);
      case TimePeriod.year:
        final yearStart = DateTime(now.year, 1, 1);
        return DateTimeRange(start: yearStart, end: now);
    }
  }

  List<TrendPoint> _calculateTrend(List<SalesEntry> entries, TimePeriod period) {
    if (entries.isEmpty) return [];

    final Map<String, double> grouped = {};
    final DateFormat formatter;
    
    switch (period) {
      case TimePeriod.today:
        formatter = DateFormat('HH:00');
        break;
      case TimePeriod.week:
      case TimePeriod.month:
        formatter = DateFormat('MMM dd');
        break;
      case TimePeriod.year:
        formatter = DateFormat('MMM');
        break;
    }

    for (final entry in entries) {
      final key = formatter.format(entry.date);
      grouped[key] = (grouped[key] ?? 0) + entry.value;
    }

    return grouped.entries
        .map((e) => TrendPoint(
              label: e.key,
              value: e.value,
              date: entries.first.date,
            ))
        .toList();
  }

  List<PerformanceData> _calculateAreaPerformance(List<SalesEntry> entries) {
    if (entries.isEmpty) return [];

    final Map<String, Map<String, num>> grouped = {};
    
    for (final entry in entries) {
      if (!grouped.containsKey(entry.area)) {
        grouped[entry.area] = {'value': 0.0, 'count': 0};
      }
      grouped[entry.area]!['value'] = (grouped[entry.area]!['value'] as num) + entry.value;
      grouped[entry.area]!['count'] = (grouped[entry.area]!['count'] as num) + entry.shopCount;
    }

    final list = grouped.entries
        .map((e) => PerformanceData(
              name: e.key,
              value: (e.value['value'] as num).toDouble(),
              count: (e.value['count'] as num).toInt(),
            ))
        .toList();

    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(5).toList();
  }

  List<PerformanceData> _calculateSalesmanPerformance(List<SalesEntry> entries) {
    if (entries.isEmpty) return [];

    final Map<String, Map<String, num>> grouped = {};
    
    for (final entry in entries) {
      if (!grouped.containsKey(entry.salesmanName)) {
        grouped[entry.salesmanName] = {'value': 0.0, 'count': 0};
      }
      grouped[entry.salesmanName]!['value'] = (grouped[entry.salesmanName]!['value'] as num) + entry.value;
      grouped[entry.salesmanName]!['count'] = (grouped[entry.salesmanName]!['count'] as num) + entry.shopCount;
    }

    final list = grouped.entries
        .map((e) => PerformanceData(
              name: e.key,
              value: (e.value['value'] as num).toDouble(),
              count: (e.value['count'] as num).toInt(),
            ))
        .toList();

    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  List<String> _generateInsights(Map<String, dynamic> data, List<SalesEntry> entries) {
    final insights = <String>[];
    
    final totalSales = data['totalSales'] as double;
    final totalCollections = data['totalCollections'] as double;
    final entryCount = data['entryCount'] as int;
    
    if (entryCount == 0) {
      insights.add('No entries recorded for this period');
      return insights;
    }

    final avgSales = totalSales / entryCount;
    insights.add('Average sales per entry: \$${avgSales.toStringAsFixed(2)}');

    if (totalSales > 0) {
      final collectionRate = (totalCollections / totalSales * 100);
      insights.add('Collection efficiency: ${collectionRate.toStringAsFixed(1)}%');
    }

    if (entries.isNotEmpty) {
      final topArea = _calculateAreaPerformance(entries).firstOrNull;
      if (topArea != null) {
        insights.add('Top performing area: ${topArea.name}');
      }
    }

    return insights;
  }
}

final analyticsControllerProvider = AsyncNotifierProvider<AnalyticsController, AnalyticsData>(
  AnalyticsController.new,
);

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  DateTimeRange({required this.start, required this.end});
}

extension FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
