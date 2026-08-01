import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'dart:io';
/// Thin wrapper around llama_cpp_dart's isolate-based LlamaParent,
/// so the rest of the app only deals with init / sendPrompt / responseStream.
class LlamaChatService {
  LlamaParent? _llamaParent;
  Future<void>? _initFuture;

  bool get isReady => _llamaParent != null;

  

  Future<void> init(String modelPath) async {
    // Validate model path early to give a clearer error
    if (!File(modelPath).existsSync()) {
      throw FileSystemException('Model file not found', modelPath);
    }

    final loadCommand = LlamaLoad(
      path: modelPath,
      modelParams: ModelParams(),
      contextParams: ContextParams()..nCtx = 512,
      samplingParams: SamplerParams()
        ..temp = 0.7
        ..topP = 0.9,
    );

    // If there's an existing instance, dispose it first to avoid leaks.
    if (_llamaParent != null) {
      try {
        await _llamaParent!.dispose();
      } catch (_) {}
      _llamaParent = null;
    }

    // Init a temporary parent and only assign to the field after successful init.
    final tempParent = LlamaParent(loadCommand);
    _initFuture = tempParent.init();
    try {
      await _initFuture;
      _llamaParent = tempParent;
    } catch (e, st) {
      // Log error and stack trace for easier diagnosis, then ensure cleanup.
      try {
        // Using stdout to ensure it shows up in native logs as well as Flutter logs.
        stdout.writeln('Llama init failed: $e');
        stdout.writeln(st.toString());
      } catch (_) {}
      try {
        await tempParent.dispose();
      } catch (_) {}
      rethrow;
    } finally {
      _initFuture = null;
    }
  }

  /// Streams tokens as they're generated. Runs on a background isolate so
  /// the UI thread never blocks during generation.
  Stream<String> get responseStream {
    _assertReady();
    return _llamaParent!.stream;
  }

  void sendPrompt(String prompt) {
    _assertReady();
    _llamaParent!.sendPrompt(prompt);
  }

  void _assertReady() {
    if (_llamaParent == null) {
      throw StateError('LlamaChatService.init() must complete before use.');
    }
  }

  Future<void> dispose() async {
    // If an init is in progress, wait for it to complete to avoid races.
    if (_initFuture != null) {
      try {
        await _initFuture;
      } catch (_) {}
    }
    await _llamaParent?.dispose();
    _llamaParent = null;
  }
}
