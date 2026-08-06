import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:farm_management_system/services/groq_chat_service.dart';
import '../../database/database_helper.dart';
import '../../models/chat_message.dart';
import '../../models/chat_session.dart';
import '../../models/expense.dart';
import '../../models/chicken_batch.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/typing_indicator.dart';
import '../../services/chat_history_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHistoryService _historyService = ChatHistoryService();
  final List<ChatMessage> _messages = [];
  int? _currentSessionId;
  bool _isTyping = false;
  List<ChatSession> _sessions = [];
  bool _loadingChats = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _loadChatSessions() async {
    setState(() {
      _loadingChats = true;
    });

    final sessions = await _historyService.getChats();

    if (mounted) {
      setState(() {
        _sessions = sessions;
        _loadingChats = false;
      });
    }
  }

  Future<void> _initializeChat() async {
    await _loadChatSessions();
    if (_sessions.isEmpty) {
      await _createNewChat();
    } else {
      await _openSession(_sessions.first.id!);
    }
  }

  Future<void> _createNewChat() async {
    _currentSessionId = await _historyService.createNewChat();
    await _historyService.saveMessage(
      sessionId: _currentSessionId!,
      message: "👋 Hello! I'm RIMAI.\n\nHow can I help you today?",
      isUser: false,
    );
    await _loadChatSessions();
    await _openSession(_currentSessionId!);
  }

  Future<void> _openSession(int id) async {
    _currentSessionId = id;
    final history = await _historyService.getMessages(id);

    if (mounted) {
      setState(() {
        _messages.clear();
        _messages.addAll(
          history.map(
            (item) => ChatMessage(
              text: item.message,
              isUser: item.isUser,
            ),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _currentSessionId == null) return;

    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    await _historyService.saveMessage(
      sessionId: _currentSessionId!,
      message: text,
      isUser: true,
    );

    // Dynamic Title Update: Rename session using user's first prompt if title is "New Chat"
    final currentSession = _sessions.firstWhere(
      (s) => s.id == _currentSessionId,
      orElse: () => ChatSession(title: 'New Chat', createdAt: ''),
    );

    if (currentSession.title == 'New Chat') {
      final newTitle = text.length > 25 ? '${text.substring(0, 25)}...' : text;
      await _historyService.updateSessionTitle(_currentSessionId!, newTitle);
      await _loadChatSessions();
    }

    try {
      final rawAiReply = await _chatService.sendMessage(text);
      String displayReply = rawAiReply;

      // Parse JSON response actions
      if (rawAiReply.trim().startsWith('{') && rawAiReply.trim().endsWith('}')) {
        try {
          final actionData = jsonDecode(rawAiReply);
          if (actionData['action'] == 'ADD_EXPENSE') {
            await DatabaseHelper.instance.insertExpense(
              Expense(
                title: actionData['title'],
                category: actionData['category'] ?? 'General',
                amount: (actionData['amount'] as num).toDouble(),
                description: 'Added via RIMAI Assistant',
                date: DateTime.now().toIso8601String().substring(0, 10),
              ),
            );
            displayReply = "Successfully added expense: **${actionData['title']}** for \$${actionData['amount']}.";
          } else if (actionData['action'] == 'ADD_BATCH') {
            await DatabaseHelper.instance.insertChickenBatch(
              ChickenBatch(
                batchName: actionData['batchName'],
                breed: actionData['breed'],
                quantity: actionData['quantity'],
                costPerBird: (actionData['costPerBird'] as num).toDouble(),
                arrivalDate: DateTime.now().toIso8601String(),
              ),
            );
            displayReply = "Successfully registered new batch: **${actionData['batchName']}** (${actionData['quantity']} ${actionData['breed']} birds).";
          }
        } catch (_) {
          displayReply = rawAiReply;
        }
      }

      await _historyService.saveMessage(
        sessionId: _currentSessionId!,
        message: displayReply,
        isUser: false,
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: displayReply, isUser: false));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: "Error: ${e.toString()}", isUser: false));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Delete Chat Session"),
              content: const Text("Are you sure you want to delete this chat session?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("New Chat"),
                onTap: () async {
                  Navigator.pop(context);
                  await _createNewChat();
                },
              ),
              const Divider(),
              Expanded(
                child: _loadingChats
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          final formattedDate = session.createdAt.length >= 10
                              ? session.createdAt.substring(0, 10)
                              : session.createdAt;

                          final isSelected = session.id == _currentSessionId;

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.grey.shade200,
                            leading: const Icon(Icons.chat),
                            title: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(formattedDate),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await _showDeleteConfirmationDialog(context);
                                if (confirm) {
                                  await _historyService.deleteChat(session.id!);
                                  await _loadChatSessions();
                                  if (_currentSessionId == session.id) {
                                    if (_sessions.isNotEmpty) {
                                      await _openSession(_sessions.first.id!);
                                    } else {
                                      await _createNewChat();
                                    }
                                  }
                                }
                              },
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              await _openSession(session.id!);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("RIMAI", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(16, 6, 51, 1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const TypingIndicator();
                }
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "Ask RIMAI AI...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _isTyping ? null : _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}