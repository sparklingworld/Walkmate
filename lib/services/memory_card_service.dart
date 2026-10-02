import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Captures, exports, and shares the Walk Memory Card widget as a high-resolution PNG image.
class MemoryCardService {
  /// Captures a RepaintBoundary key as a PNG byte buffer and saves to a temporary file.
  static Future<File?> captureMemoryCardImage(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Render at 3.0 pixel ratio for crisp high-resolution photo quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'walkmate_memory_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      debugPrint("Error capturing memory card: $e");
      return null;
    }
  }

  /// Shares the generated memory card image via the native Android share sheet.
  static Future<bool> shareMemoryCard(GlobalKey boundaryKey, {required String caption}) async {
    final imageFile = await captureMemoryCardImage(boundaryKey);
    if (imageFile == null) return false;

    try {
      final xFile = XFile(imageFile.path, mimeType: 'image/png');
      final result = await Share.shareXFiles(
        [xFile],
        text: caption,
        subject: 'My Walk with WalkMate 🌱',
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint("Error sharing memory card: $e");
      return false;
    }
  }

  /// Saves the memory card to the local Application Documents or Download directory.
  static Future<String?> saveMemoryCardLocally(GlobalKey boundaryKey) async {
    final imageFile = await captureMemoryCardImage(boundaryKey);
    if (imageFile == null) return null;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final destinationPath = '${appDir.path}/WalkMate_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedFile = await imageFile.copy(destinationPath);
      return savedFile.path;
    } catch (e) {
      debugPrint("Error saving memory card locally: $e");
      return null;
    }
  }
}
