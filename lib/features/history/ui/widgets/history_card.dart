import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../sales_entry/domain/entities/sales_entry.dart';
import '../../../../core/widgets/custom_card.dart';

class HistoryCard extends StatelessWidget {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  final SalesEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  DateFormat('MMM dd, yyyy - HH:mm').format(entry.date),
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
          Text(
            '${entry.salesmanName} (${entry.area})',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildMetric(context, 'Value', _currencyFormatter.format(entry.value)),
              _buildMetric(context, 'Shops', entry.shopCount.toString()),
              _buildMetric(
                context,
                'Cash',
                _currencyFormatter.format(entry.cashCollection),
              ),
              _buildMetric(
                context,
                'Check',
                _currencyFormatter.format(entry.checkCollection),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
