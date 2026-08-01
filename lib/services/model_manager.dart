import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

/// Handles downloading and caching the .gguf model file on-device so it
/// doesn't have to ship inside the app bundle.
class ModelManager {
  static const String modelFileName = 'qwen2.5-0.5b-instruct-q3_k_m.gguf';

  // Swap this for whichever quantized GGUF model you want to ship.
  // This one is a small, phone-friendly instruct model (~800MB).
  // Browse alternatives at https://huggingface.co/models?library=gguf
  
  static Future<String> getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$modelFileName';
  }

  static Future<void> copyModelFromAssets() async {
    final path = await getModelPath();
    final file = File(path);

    if (await file.exists()) {
      final length = await file.length();
      if (length>0){
        print('Model already exists, size: $length bytes');
        return;
      }
      await file.delete();
    }    
    print('Copying model from assets....');

    final data = await rootBundle.load(
      'assets/models/qwen2.5-0.5b-instruct-q3_k_m.gguf',
    );

    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
      );

      print("Model copied successfully");
      print("Copied size: ${await file.length()} bytes");
}

  /// Downloads the model with progress reporting (0.0 to 1.0)

  static Future<void> deleteModel() async {
    final path = await getModelPath();
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}
