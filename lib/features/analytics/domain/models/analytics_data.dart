class AnalyticsData {
  final double totalSales;
  final double totalCollections;
  final int totalShops;
  final int entryCount;
  final double cashCollection;
  final double checkCollection;
  final List<TrendPoint> salesTrend;
  final List<PerformanceData> areaPerformance;
  final List<PerformanceData> salesmanPerformance;
  final List<String> insights;

  const AnalyticsData({
    required this.totalSales,
    required this.totalCollections,
    required this.totalShops,
    required this.entryCount,
    required this.cashCollection,
    required this.checkCollection,
    required this.salesTrend,
    required this.areaPerformance,
    required this.salesmanPerformance,
    required this.insights,
  });

  static AnalyticsData empty() {
    return const AnalyticsData(
      totalSales: 0,
      totalCollections: 0,
      totalShops: 0,
      entryCount: 0,
      cashCollection: 0,
      checkCollection: 0,
      salesTrend: [],
      areaPerformance: [],
      salesmanPerformance: [],
      insights: [],
    );
  }
}

class TrendPoint {
  final String label;
  final double value;
  final DateTime date;

  const TrendPoint({
    required this.label,
    required this.value,
    required this.date,
  });
}

class PerformanceData {
  final String name;
  final double value;
  final int count;

  const PerformanceData({
    required this.name,
    required this.value,
    required this.count,
  });

  double get productivity => count > 0 ? value / count : 0;
}

enum TimePeriod { today, week, month, year }
