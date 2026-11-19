import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../theme/app_theme.dart';

/// label name | bar | percentage. The top row is emphasised.
class PredictionRow extends StatelessWidget {
  const PredictionRow({super.key, required this.prediction, required this.isTop});

  final Prediction prediction;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = isTop
        ? text.titleMedium?.copyWith(color: scheme.primary)
        : text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final percent = '${(prediction.confidence * 100).toStringAsFixed(1)} %';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.labelWidth,
            child: Text(prediction.label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: LinearProgressIndicator(
                value: prediction.confidence.clamp(0.0, 1.0),
                minHeight: AppSpacing.barHeight,
                color: isTop ? scheme.primary : scheme.outline,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          SizedBox(
            width: AppSpacing.percentWidth,
            child: Text(percent, style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
