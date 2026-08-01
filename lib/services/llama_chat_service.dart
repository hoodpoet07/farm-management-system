import 'package:llama_cpp_dart/llama_cpp_dart.dart';

/// Thin wrapper around llama_cpp_dart's isolate-based LlamaParent,
/// so the rest of the app only deals with init / sendPrompt / responseStream.
class LlamaChatService {
  LlamaParent? _llamaParent;

  bool get isReady => _llamaParent != null;

  Future<void> init(String modelPath) async {
    final loadCommand = LlamaLoad(
      path: modelPath,
      modelParams: ModelParams(),
      contextParams: ContextParams(),
      samplingParams: SamplerParams()
        ..temp = 0.7
        ..topP = 0.9,
      // ChatMLFormat works for most instruct-tuned models (Llama, Qwen, etc).
      // If you use a Llama-2 or raw-completion model, check llama_cpp_dart's
      // docs for the matching format class.
      /*format: ChatMLFormat(),*/
    );

    _llamaParent = LlamaParent(loadCommand);
    await _llamaParent!.init();
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
    await _llamaParent?.dispose();
    _llamaParent = null;
  }
}
