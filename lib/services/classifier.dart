import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'labels.dart';

class Prediction {
  const Prediction(this.label, this.confidence);
  final String label;
  final double confidence; // 0.0 to 1.0
}

class ModelLoadException implements Exception {
  const ModelLoadException(this.message);
  final String message;
  @override
  String toString() => message;
}

class Classifier {
  Classifier._(this._interpreter, this.labels);

  final Interpreter _interpreter;
  final List<String> labels;

  static const modelAsset = 'assets/model/model_unquant.tflite';
  static const labelsAsset = 'assets/model/labels.txt';
  static const inputSize = 224;

  static Future<Classifier> load() async {
    final Interpreter interpreter;
    try {
      interpreter = await Interpreter.fromAsset(modelAsset);
    } catch (e) {
      throw ModelLoadException(
        'The model could not be loaded.\n'
        'Expected file: $modelAsset\n'
        'Check the file name and the "assets/model/" entry in pubspec.yaml.\n'
        'Details: $e',
      );
    }

    final String raw;
    try {
      raw = await rootBundle.loadString(labelsAsset);
    } catch (e) {
      interpreter.close();
      throw ModelLoadException(
        'The labels could not be loaded.\nExpected file: $labelsAsset\nDetails: $e',
      );
    }

    final labels = parseLabels(raw);
    final outputClasses = interpreter.getOutputTensor(0).shape.last;
    if (labels.isEmpty || labels.length != outputClasses) {
      interpreter.close();
      throw ModelLoadException(
        'labels.txt has ${labels.length} lines but the model outputs '
        '$outputClasses classes. Re-export both files together.',
      );
    }
    return Classifier._(interpreter, labels);
  }

  List<Prediction> classify(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('Not a readable image');

    // Same centre crop Teachable Machine used for training. bakeOrientation
    // applies the EXIF rotation stored by phone cameras.
    final square = img.copyResizeCropSquare(
      img.bakeOrientation(decoded),
      size: inputSize,
    );

    // Input tensor: [1, 224, 224, 3], floats from -1 to 1.
    final input = [
      List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final p = square.getPixel(x, y);
          return [p.r / 127.5 - 1, p.g / 127.5 - 1, p.b / 127.5 - 1];
        }),
      ),
    ];

    // Output tensor: [1, classes]
    final output = [List<double>.filled(labels.length, 0)];
    _interpreter.run(input, output);

    // Pair first, sort afterwards.
    return [
      for (var i = 0; i < labels.length; i++)
        Prediction(labels[i], output.first[i]),
    ]..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  void close() => _interpreter.close();
}
