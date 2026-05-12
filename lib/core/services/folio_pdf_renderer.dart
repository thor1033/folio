import 'dart:typed_data';

import 'package:flutter/services.dart';

class FolioPdfRenderer {
  static const _channel = MethodChannel('com.thorsimonsen.folio/pdf');

  Future<int> openDocument(String path) async {
    final count = await _channel.invokeMethod<int>(
      'openDocument',
      {'path': path},
    );
    return count ?? 0;
  }

  Future<Uint8List> renderPage({
    required int index,
    required int width,
  }) async {
    final bytes = await _channel.invokeMethod<Uint8List>(
      'renderPage',
      {'index': index, 'width': width},
    );
    if (bytes == null) throw Exception('Null bytes for page $index');
    return bytes;
  }

  Future<void> closeDocument() async {
    await _channel.invokeMethod<void>('closeDocument');
  }
}
