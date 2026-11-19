import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// A problem with getting the image; [message] is safe to show to the user.
class ImageSourceException implements Exception {
  const ImageSourceException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Camera, gallery and download differ only in how the bytes arrive.
class ImageSources {
  final _picker = ImagePicker();
  static const _timeout = Duration(seconds: 15);

  Future<Uint8List?> fromCamera() => _pick(ImageSource.camera);
  Future<Uint8List?> fromGallery() => _pick(ImageSource.gallery);

  /// null means the user cancelled: not an error.
  Future<Uint8List?> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1024);
      return file == null ? null : await file.readAsBytes();
    } on PlatformException catch (e) {
      throw ImageSourceException(
        source == ImageSource.camera
            ? 'The camera is not available or permission was denied (${e.code}).'
            : 'The gallery is not available or permission was denied (${e.code}).',
      );
    }
  }

  Future<Uint8List> fromUrl(
    String url, {
    void Function(double? progress)? onProgress,
  }) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const ImageSourceException(
        'That is not a valid address. It must start with http:// or https://',
      );
    }

    final client = http.Client();
    try {
      final response = await client.send(http.Request('GET', uri)).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ImageSourceException(
          'The server answered with status ${response.statusCode} instead of 200. '
          'Check the address.',
        );
      }
      final type = (response.headers['content-type'] ?? '').toLowerCase();
      if (!type.startsWith('image/')) {
        throw ImageSourceException(
          'That address is not a picture (content type: '
          '${type.isEmpty ? 'unknown' : type}). '
          'Use the direct link to an image file.',
        );
      }

      final total = response.contentLength;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response.stream.timeout(_timeout)) {
        builder.add(chunk);
        onProgress?.call(total != null && total > 0 ? builder.length / total : null);
      }
      return builder.takeBytes();
    } on ImageSourceException {
      rethrow;
    } on TimeoutException {
      throw const ImageSourceException('The download took too long (timeout). Try again.');
    } on SocketException {
      throw const ImageSourceException('No network connection or the server cannot be reached.');
    } on HandshakeException {
      throw const ImageSourceException('A secure connection to that server could not be made.');
    } on http.ClientException catch (e) {
      throw ImageSourceException('The download failed: ${e.message}');
    } finally {
      client.close();
    }
  }
}
