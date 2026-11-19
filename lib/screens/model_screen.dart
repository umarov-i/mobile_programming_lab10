import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/classifier.dart';
import '../theme/app_theme.dart';
import '../theme/design_credit.dart';

/// Screen 5: facts about the loaded model. Labels come from the Classifier
/// instance (the exact list the model uses for pairing), not from re-reading the file.
class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final labels = app.classifier?.labels ?? const <String>[];
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final last = app.latest;

    return Scaffold(
      appBar: AppBar(title: const Text('Model')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _InfoRow('Model file', Classifier.modelAsset.split('/').last),
                  _InfoRow('Classes', '${labels.length}'),
                  _InfoRow('Input size',
                      '${Classifier.inputSize} × ${Classifier.inputSize} × 3'),
                  _InfoRow('Last inference',
                      last == null ? '–' : '${last.inferenceTime.inMilliseconds} ms'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Labels', style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [for (final l in labels) Chip(label: Text(l))],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Design credit', style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${DesignCredit.name}\nby ${DesignCredit.author}\n'
            '${DesignCredit.license}\n${DesignCredit.link}',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          Flexible(
            child: Text(value,
                style: text.titleMedium, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
