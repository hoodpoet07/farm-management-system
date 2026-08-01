import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Handles downloading and caching the .gguf model file on-device so it
/// doesn't have to ship inside the app bundle.
class ModelManager {
  static const String modelFileName = 'model.gguf';

  // Swap this for whichever quantized GGUF model you want to ship.
  // This one is a small, phone-friendly instruct model (~800MB).
  // Browse alternatives at https://huggingface.co/models?library=gguf
  static const String modelUrl =
      'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q3_k_m.gguf?download=true';

  static Future<String> getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$modelFileName';
  }

  static Future<bool> isModelDownloaded() async {
    final path = await getModelPath();
    final file = File(path);
    // Basic sanity check: file exists and isn't a truncated/partial download.
    return file.existsSync() && (await file.length()) > 1024 * 1024;
  }

  /// Downloads the model with progress reporting (0.0 to 1.0).
  static Future<void> downloadModel({
    required void Function(double progress) onProgress,
  }) async {
    final path = await getModelPath();
    final tmpFile = File('$path.part');

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(modelUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to download model (HTTP ${response.statusCode})');
      }

      final total = response.contentLength ?? 0;
      var received = 0;
      final sink = tmpFile.openWrite();

      await for (final chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0) onProgress(received / total);
      }
      await sink.flush();
      await sink.close();

      // Verify we actually got the full file before trusting it. Catches
      // cases where the server returned an error/redirect page instead of
      // the real model (which would otherwise silently "succeed").
      final downloadedSize = await tmpFile.length();
      if (total > 0 && downloadedSize != total) {
        await tmpFile.delete();
        throw Exception(
            'Download incomplete: got $downloadedSize of $total bytes. '
            'Check your connection and the model URL, then try again.');
      }
      if (downloadedSize < 1024 * 1024) {
        await tmpFile.delete();
        throw Exception(
            'Downloaded file is too small ($downloadedSize bytes) to be a '
            'valid model — the URL likely returned an error page instead '
            'of the .gguf file.');
      }

      // Only move into place once the download is verified complete.
      await tmpFile.rename(path);
    } finally {
      client.close();
    }
  }

  static Future<void> deleteModel() async {
    final path = await getModelPath();
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}
