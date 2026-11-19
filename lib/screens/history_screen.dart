import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/entry_thumbnail.dart';
import 'result_screen.dart';

/// Screen 4: every classification of this session, newest first.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppScope.of(context).history;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: AppSpacing.iconXl, color: scheme.outline),
                    const SizedBox(height: AppSpacing.md),
                    Text('No classifications yet', style: text.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Take a photo, pick one from the gallery or download an image and it will show up here.',
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final e = history[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    // Reopens the stored result: the model is NOT run again.
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ResultScreen(entry: e)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          EntryThumbnail(bytes: e.bytes),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.top.label, style: text.titleMedium),
                                Text(
                                  '${(e.top.confidence * 100).toStringAsFixed(1)} %',
                                  style: text.bodyMedium
                                      ?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Icon(e.origin.icon, color: scheme.primary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
