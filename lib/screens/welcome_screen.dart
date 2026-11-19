import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/design_credit.dart';
import '../widgets/message_card.dart';
import 'shell_screen.dart';

/// Screen 1: welcome + loading screen while the model loads.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Icon(Icons.center_focus_strong_rounded,
                  size: AppSpacing.iconXl, color: scheme.primary),
              const SizedBox(height: AppSpacing.lg),
              Text('Teach It, Ship It', style: text.displaySmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Point your phone at one of your trained objects and see which '
                'one it is, with a percentage for every label. Everything runs '
                'offline on this device.',
                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (app.isLoading) ...[
                Row(children: [
                  const SizedBox(
                    width: AppSpacing.lg,
                    height: AppSpacing.lg,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('Loading the model…', style: text.bodyLarge),
                ]),
              ] else if (app.loadError != null) ...[
                MessageCard(title: 'Model not loaded', message: app.loadError!),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: app.init,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ] else ...[
                Text('It recognises', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final label in app.classifier!.labels) Chip(label: Text(label)),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: app.isReady
                    ? () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const ShellScreen()),
                        )
                    : null,
                child: const Text('Get started'),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(DesignCredit.summary,
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
