import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../services/app_state.dart';
import '../services/image_sources.dart';
import '../theme/app_theme.dart';
import '../widgets/entry_thumbnail.dart';
import '../widgets/message_card.dart';
import 'download_dialog.dart';
import 'result_screen.dart';

/// Screen 2: three actions + latest result.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sources = ImageSources();
  bool _busy = false;
  String? _error;

  /// The single path for all three sources: bytes -> classify -> Result -> History.
  Future<void> _run(ImageOrigin origin, Future<Uint8List?> Function() fetch) async {
    setState(() => _error = null);
    try {
      final bytes = await fetch();
      if (bytes == null || !mounted) return; // cancelled: stay quietly

      setState(() => _busy = true);
      // Let the spinner paint before the (synchronous) model run blocks the UI.
      await Future<void>.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      final entry = AppScope.of(context).classify(bytes, origin);

      setState(() => _busy = false);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultScreen(entry: entry)),
      );
    } on ImageSourceException catch (e) {
      _error = e.message;
    } on FormatException {
      _error = 'That file is not a readable image. Choose a JPEG or PNG picture.';
    } catch (e) {
      _error = 'The picture could not be classified: $e';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List?> _askForUrl() => showDialog<Uint8List>(
        context: context,
        builder: (_) => DownloadDialog(sources: _sources),
      );

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final latest = app.latest;

    return Scaffold(
      appBar: AppBar(title: const Text('Classify')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (_error != null) ...[
                MessageCard(message: _error!),
                const SizedBox(height: AppSpacing.md),
              ],
              _ActionCard(
                icon: Icons.photo_camera_outlined,
                title: 'Take a photo',
                subtitle: 'Use the phone camera',
                onTap: () => _run(ImageOrigin.camera, _sources.fromCamera),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionCard(
                icon: Icons.photo_library_outlined,
                title: 'Choose from gallery',
                subtitle: 'Pick an existing picture',
                onTap: () => _run(ImageOrigin.gallery, _sources.fromGallery),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionCard(
                icon: Icons.cloud_download_outlined,
                title: 'Download an image',
                subtitle: 'Paste a link to a picture',
                onTap: () => _run(ImageOrigin.download, _askForUrl),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Latest result', style: text.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              if (latest == null)
                Text('Nothing classified yet.',
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))
              else
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ResultScreen(entry: latest)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          EntryThumbnail(bytes: latest.bytes),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(latest.top.label, style: text.titleMedium),
                                Text(
                                  '${(latest.top.confidence * 100).toStringAsFixed(1)} % · ${latest.origin.label}',
                                  style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: scheme.outline),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_busy)
            Positioned.fill(
              child: ColoredBox(
                color: scheme.surface.withValues(alpha: 0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppSpacing.md),
                      Text('Classifying…', style: text.bodyLarge),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap, // InkWell gives the pressed (ripple) state
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: AppSpacing.lg,
                backgroundColor: scheme.primaryContainer,
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleMedium),
                    Text(subtitle,
                        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
