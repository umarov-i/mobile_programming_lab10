import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/image_sources.dart';
import '../theme/app_theme.dart';

/// Asks for an image address, downloads it with progress, pops the bytes.
class DownloadDialog extends StatefulWidget {
  const DownloadDialog({super.key, required this.sources});
  final ImageSources sources;

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  final _controller = TextEditingController();
  bool _loading = false;
  double? _progress;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    setState(() {
      _loading = true;
      _progress = null;
      _error = null;
    });
    try {
      final Uint8List bytes = await widget.sources.fromUrl(
        _controller.text,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (mounted) Navigator.of(context).pop(bytes);
    } on ImageSourceException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'The download failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Download an image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            enabled: !_loading,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Image address',
              hintText: 'https://example.com/mug.jpg',
            ),
            onSubmitted: (_) => _loading ? null : _download(),
          ),
          if (_loading) ...[
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(value: _progress), // null = indeterminate
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: text.bodyMedium?.copyWith(color: scheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
          onPressed: _loading ? null : _download,
          child: const Text('Download'),
        ),
      ],
    );
  }
}
