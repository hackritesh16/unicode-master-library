import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/unicode_db_provider.dart';
import '../../../shared/widgets/glass_widgets.dart';

String _statusLine(UnicodeDbState s) {
  switch (s.status) {
    case UnicodeDbStatus.checking:
      return 'Checking installed data...';
    case UnicodeDbStatus.notInstalled:
      return 'Not installed. Download the official Unicode data once; '
          'after that the app works offline.';
    case UnicodeDbStatus.installing:
      return s.stage;
    case UnicodeDbStatus.ready:
      return 'Unicode ${s.installedVersion} installed '
          '(${s.characterCount} explicit characters).';
    case UnicodeDbStatus.failed:
      return 'Unicode data is not available.';
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(unicodeDbControllerProvider);
    final controller = ref.read(unicodeDbControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    final canInstall = state.installedVersion == null &&
        (state.status == UnicodeDbStatus.notInstalled ||
            state.status == UnicodeDbStatus.failed);
    final updateAvailable = state.status == UnicodeDbStatus.ready &&
        state.latestVersion != null &&
        state.latestVersion != state.installedVersion;

    return Scaffold(
      appBar: const GlassAppBar(title: Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unicode database', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _statusLine(state),
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                if (state.status == UnicodeDbStatus.installing) ...[
                  const SizedBox(height: AppSpacing.md),
                  LinearProgressIndicator(value: state.progress),
                ],
                if (state.error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    state.error!,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (canInstall)
                      FilledButton(
                        onPressed: controller.install,
                        child: const Text('Download Unicode data'),
                      ),
                    if (state.status == UnicodeDbStatus.ready)
                      OutlinedButton(
                        onPressed: controller.checkForUpdate,
                        child: const Text('Check for updates'),
                      ),
                    if (updateAvailable)
                      FilledButton(
                        onPressed: controller.install,
                        child: Text('Update to ${state.latestVersion}'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Unicode data: \u00a9 Unicode, Inc., distributed under the Unicode '
            'License. Source: unicode.org/Public/UCD/latest.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
