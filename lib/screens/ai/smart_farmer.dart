import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../services/model_manager.dart';
import '../../services/llama_chat_service.dart';

/// Drop this into your existing app, e.g.:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
/// or wire it up as a tab/route like any other screen.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

enum _SetupState { checking, downloading, loading, ready, error }

class _ChatScreenState extends State<ChatScreen> {
  final _service = LlamaChatService();
  final _messages = <ChatMessage>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  _SetupState _setupState = _SetupState.checking;
  final double _downloadProgress = 0;
  String _errorMessage = '';
  bool _isGenerating = false;
  StreamSubscription<String>? _streamSub;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
  try {
    setState(() {
      _setupState = _SetupState.loading;
    });

    await ModelManager.copyModelFromAssets();

    if (!mounted) return;

    final modelPath = await ModelManager.getModelPath();

    print("Model path: $modelPath");

    await _service.init(modelPath);

    if (!mounted) {
      // If the widget was disposed while initializing, clean up service and exit.
      try {
        await _service.dispose();
      } catch (_) {}
      return;
    }

    _streamSub = _service.responseStream.listen((token) {
      _appendToLastAiMessage(token);
      _scrollToBottom();
    }, onError: (e, st) {
      // Log stream errors and show an error state if still mounted.
      print('Llama stream error: $e');
      print(st);
      if (mounted) {
        setState(() {
          _setupState = _SetupState.error;
          _errorMessage = e.toString();
        });
      }
    });

    if (!mounted) return;

    setState(() {
      _setupState = _SetupState.ready;
    });

  } catch (e, st) {
    print(e);
    print(st);

    if (mounted) {
      setState(() {
        _setupState = _SetupState.error;
        _errorMessage = e.toString();
      });
    }
  }
 }
 
  void _appendToLastAiMessage(String token) {
    if (_messages.isEmpty || _messages.last.isUser) return;
    setState(() {
      _messages.last.text += token;
      // NOTE: llama_cpp_dart's stream currently just emits tokens.
      // If your version exposes a "generation complete" event, listen for
      // it here and set _isGenerating = false. Otherwise this simple
      // idle-timeout approach re-enables input a moment after tokens stop.
      _isGenerating = true;
    });
    _scheduleGenerationIdleCheck();
  }

  Timer? _idleTimer;
  void _scheduleGenerationIdleCheck() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isGenerating = false);
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _setupState != _SetupState.ready || _isGenerating) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messages.add(ChatMessage(text: '', isUser: false)); // AI placeholder
      _isGenerating = true;
    });

    _textController.clear();
    _service.sendPrompt(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _idleTimer?.cancel();
    _service.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline AI Chat')),
      body: switch (_setupState) {
        _SetupState.checking => const _CenteredMessage(text: 'Checking model...'),
        _SetupState.downloading => _CenteredMessage(
            text:
                'Downloading model... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
            progress: _downloadProgress,
          ),
        _SetupState.loading => const _CenteredMessage(text: 'Loading model into memory...'),
        _SetupState.error => _CenteredMessage(
            text: 'Something went wrong:\n$_errorMessage',
            isError: true,
          ),
        _SetupState.ready => _buildChatUi(),
      },
    );
  }

  Widget _buildChatUi() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return Align(
                alignment:
                    msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    msg.text.isEmpty ? '...' : msg.text,
                    style: TextStyle(
                      color: msg.isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    enabled: !_isGenerating,
                    decoration: const InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: _isGenerating ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String text;
  final double? progress;
  final bool isError;

  const _CenteredMessage({required this.text, this.progress, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress != null) ...[
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(value: progress),
              ),
              const SizedBox(height: 16),
            ] else if (!isError) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: isError ? Colors.red : null),
            ),
          ],
        ),
      ),
    );
  }
}
