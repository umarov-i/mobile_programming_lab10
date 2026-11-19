import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/classifier.dart';

enum ImageOrigin {
  camera('Camera', Icons.photo_camera_outlined),
  gallery('Gallery', Icons.photo_library_outlined),
  download('Download', Icons.cloud_download_outlined);

  const ImageOrigin(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// One finished classification. Stored in History and reopened without
/// running the model again.
class HistoryEntry {
  const HistoryEntry({
    required this.bytes,
    required this.origin,
    required this.predictions,
    required this.inferenceTime,
    required this.createdAt,
  });

  final Uint8List bytes;
  final ImageOrigin origin;
  final List<Prediction> predictions; // already sorted, highest first
  final Duration inferenceTime;
  final DateTime createdAt;

  Prediction get top => predictions.first;
}
