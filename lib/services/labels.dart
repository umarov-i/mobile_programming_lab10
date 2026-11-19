/// "0 Mug\n1 Bottle\n" becomes ['Mug', 'Bottle'].
/// Pure Dart, so it can be unit-tested without a device.
List<String> parseLabels(String raw) => [
      for (final line in raw.split('\n'))
        if (line.trim().isNotEmpty)
          line.trim().replaceFirst(RegExp(r'^\d+\s+'), ''),
    ];
