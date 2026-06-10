import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../backup/services/backup_service.dart';
import '../../../../core/error/exceptions.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
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
                _buildThemeModeSection(context, ref, themeState),
                const Divider(height: 32),
                _buildSeedColorSection(context, ref, themeState),
                const Divider(height: 32),
                _buildDataManagementSection(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeSection(
    BuildContext context,
    WidgetRef ref,
    ThemeState themeState,
  ) {
    final theme = Theme.of(context);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto, size: 16),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode, size: 16),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode, size: 16),
            ),
          ],
          selected: {themeState.mode},
          onSelectionChanged: (selection) {
            themeNotifier.setThemeMode(selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildSeedColorSection(
    BuildContext context,
    WidgetRef ref,
    ThemeState themeState,
  ) {
    final theme = Theme.of(context);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Color',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: themeSeedColors.map((color) {
            final isSelected = themeState.seedColor.toARGB32() == color.toARGB32();
            return InkWell(
              onTap: () => themeNotifier.setSeedColor(color),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.outline,
                          width: 3,
                        )
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Management',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportBackup(context, ref),
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Export'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _restoreBackup(context, ref),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Restore'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final backupService = ref.read(backupServiceProvider);

    try {
      final path = await backupService.exportData();
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Backup exported to $path'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(error.toUserMessage()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final backupService = ref.read(backupServiceProvider);

    try {
      final path = await backupService.importLatestBackup();
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Backup restored from $path'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(error.toUserMessage()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
