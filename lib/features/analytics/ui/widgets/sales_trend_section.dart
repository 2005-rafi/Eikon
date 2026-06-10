import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/analytics_data.dart';

class SalesTrendSection extends StatelessWidget {
  final AnalyticsData data;

  const SalesTrendSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (data.salesTrend.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No trend data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Trend',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calculateInterval(data.salesTrend),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            interval: _calculateInterval(data.salesTrend),
                            getTitlesWidget: (value, meta) {
                              if (value < 0) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  _formatCurrency(value),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= data.salesTrend.length) {
                                return const SizedBox();
                              }
                              
                              final label = data.salesTrend[index].label;
                              final shouldShow = _shouldShowLabel(index, data.salesTrend.length);
                              
                              if (!shouldShow) return const SizedBox();
                              
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  label,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                      ),
                      minX: 0,
                      maxX: (data.salesTrend.length - 1).toDouble(),
                      minY: 0,
                      maxY: _calculateMaxY(data.salesTrend),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.salesTrend
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                              .toList(),
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: theme.colorScheme.primary,
                                strokeWidth: 2,
                                strokeColor: theme.colorScheme.surface,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.3),
                                theme.colorScheme.primary.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final index = spot.x.toInt();
                              if (index >= 0 && index < data.salesTrend.length) {
                                return LineTooltipItem(
                                  '${data.salesTrend[index].label}\n${_formatCurrency(spot.y)}',
                                  TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return null;
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (data.salesTrend.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total: ${_formatCurrency(_calculateTotal(data.salesTrend))}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _shouldShowLabel(int index, int totalCount) {
    if (totalCount <= 7) return true;
    if (totalCount <= 15) return index % 2 == 0;
    if (totalCount <= 30) return index % 3 == 0;
    return index % 5 == 0;
  }

  double _calculateInterval(List<TrendPoint> trend) {
    if (trend.isEmpty) return 1000;
    final maxValue = trend.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return 1000;
    
    final magnitude = (maxValue / 5).ceil();
    final power = magnitude.toString().length - 1;
    final base = (magnitude / (10 ^ power)).ceil() * (10 ^ power);
    
    return base.toDouble();
  }

  double _calculateMaxY(List<TrendPoint> trend) {
    if (trend.isEmpty) return 100;
    final maxValue = trend.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final interval = _calculateInterval(trend);
    return ((maxValue / interval).ceil() * interval) * 1.1;
  }

  double _calculateTotal(List<TrendPoint> trend) {
    return trend.fold(0.0, (sum, point) => sum + point.value);
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${value.toStringAsFixed(0)}';
    }
  }
}
