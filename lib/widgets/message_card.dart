import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Designed error / info message (never a red screen).
class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message, this.title = 'Something went wrong'});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleMedium?.copyWith(color: scheme.onErrorContainer)),
                const SizedBox(height: AppSpacing.xs),
                Text(message, style: text.bodyMedium?.copyWith(color: scheme.onErrorContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
