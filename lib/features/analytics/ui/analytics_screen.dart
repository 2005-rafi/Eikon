import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/analytics_controller.dart';
import '../domain/models/analytics_data.dart';
import 'widgets/quick_summary_section.dart';
import 'widgets/sales_trend_section.dart';
import 'widgets/collections_section.dart';
import 'widgets/performance_section.dart';
import 'widgets/insights_section.dart';
import 'widgets/settings_section.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsControllerProvider);
    final controller = ref.read(analyticsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(analyticsControllerProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: analyticsAsync.when(
          data: (data) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(analyticsControllerProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: _buildContent(context, ref, data, controller),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load analytics',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(analyticsControllerProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AnalyticsData data,
    AnalyticsController controller,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimePeriodFilter(context, ref, controller),
          const SizedBox(height: 24),
          QuickSummarySection(data: data),
          const SizedBox(height: 24),
          SalesTrendSection(data: data),
          const SizedBox(height: 24),
          CollectionsSection(data: data),
          const SizedBox(height: 24),
          PerformanceSection(
            title: 'Top Areas',
            data: data.areaPerformance,
          ),
          const SizedBox(height: 24),
          PerformanceSection(
            title: 'Salesman Performance',
            data: data.salesmanPerformance,
          ),
          const SizedBox(height: 24),
          InsightsSection(insights: data.insights),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const SettingsSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTimePeriodFilter(
    BuildContext context,
    WidgetRef ref,
    AnalyticsController controller,
  ) {
    return SegmentedButton<TimePeriod>(
      segments: const [
        ButtonSegment(
          value: TimePeriod.today,
          label: Text('Today'),
        ),
        ButtonSegment(
          value: TimePeriod.week,
          label: Text('Week'),
        ),
        ButtonSegment(
          value: TimePeriod.month,
          label: Text('Month'),
        ),
        ButtonSegment(
          value: TimePeriod.year,
          label: Text('Year'),
        ),
      ],
      selected: {controller.currentPeriod},
      onSelectionChanged: (selection) {
        controller.changePeriod(selection.first);
      },
    );
  }
}
