import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

import '../models/history_entry.dart';
import 'classifier.dart';

/// Owns the single Classifier instance and the session history.
/// Injected into the tree with [AppScope]; no screen calls Classifier.load().
class AppState extends ChangeNotifier {
  Classifier? classifier;
  String? loadError;
  bool isLoading = true;

  final List<HistoryEntry> _history = [];
  UnmodifiableListView<HistoryEntry> get history => UnmodifiableListView(_history);
  HistoryEntry? get latest => _history.isEmpty ? null : _history.first;

  bool get isReady => classifier != null;

  Future<void> init() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      classifier = await Classifier.load();
      await _smokeTest();
    } on ModelLoadException catch (e) {
      loadError = e.message;
    } catch (e) {
      loadError = 'Unexpected error while starting the app:\n$e';
    }
    isLoading = false;
    notifyListeners();
  }

  /// T10: classify assets/model/sample.jpg once in debug builds.
  Future<void> _smokeTest() async {
    if (!kDebugMode) return;
    try {
      final data = await rootBundle.load('assets/model/sample.jpg');
      final preds = classifier!.classify(data.buffer.asUint8List());
      var sum = 0.0;
      for (final p in preds) {
        sum += p.confidence;
        debugPrint('${p.label}: ${(p.confidence * 100).toStringAsFixed(1)} %');
      }
      debugPrint('Smoke test: ${preds.length} labels, sum = ${sum.toStringAsFixed(3)}');
    } catch (_) {
      debugPrint('Smoke test skipped (assets/model/sample.jpg not found).');
    }
  }

  /// bytes -> classify -> History. The only classification path in the app.
  HistoryEntry classify(Uint8List bytes, ImageOrigin origin) {
    final c = classifier;
    if (c == null) throw StateError('The model is not loaded yet.');
    final watch = Stopwatch()..start();
    final predictions = c.classify(bytes);
    watch.stop();
    debugPrint('classify() took ${watch.elapsedMilliseconds} ms');

    final entry = HistoryEntry(
      bytes: bytes,
      origin: origin,
      predictions: predictions,
      inferenceTime: watch.elapsed,
      createdAt: DateTime.now(),
    );
    _history.insert(0, entry);
    notifyListeners();
    return entry;
  }

  @override
  void dispose() {
    classifier?.close();
    super.dispose();
  }
}

class _AppStateInherited extends InheritedNotifier<AppState> {
  const _AppStateInherited({required AppState super.notifier, required super.child});
}

/// Creates AppState once, loads the model, closes it when the app is torn down.
class AppScope extends StatefulWidget {
  const AppScope({super.key, required this.child});
  final Widget child;

  /// Rebuilds the caller whenever AppState changes.
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AppStateInherited>();
    assert(scope != null, 'No AppScope above this context');
    return scope!.notifier!;
  }

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final AppState _state = AppState()..init();

  @override
  void dispose() {
    _state.dispose(); // closes the interpreter
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _AppStateInherited(notifier: _state, child: widget.child);
}
