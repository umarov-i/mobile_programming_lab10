import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/prediction_row.dart';

/// Screen 3: same widget for camera, gallery and download, and for History.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final maxImageHeight = MediaQuery.sizeOf(context).height * 0.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Chip(
              avatar: Icon(entry.origin.icon, size: AppSpacing.md),
              label: Text(entry.origin.label),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('CLASSIFIED IMAGE',
                style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxImageHeight),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.memory(entry.bytes, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    for (var i = 0; i < entry.predictions.length; i++)
                      PredictionRow(prediction: entry.predictions[i], isTop: i == 0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Source: ${entry.origin.label} · model time ${entry.inferenceTime.inMilliseconds} ms',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
