import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EntryThumbnail extends StatelessWidget {
  const EntryThumbnail({super.key, required this.bytes});
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Image.memory(
        bytes,
        width: AppSpacing.thumb,
        height: AppSpacing.thumb,
        fit: BoxFit.cover,
        cacheWidth: 160, // decode small; this is only a thumbnail
        gaplessPlayback: true,
      ),
    );
  }
}
