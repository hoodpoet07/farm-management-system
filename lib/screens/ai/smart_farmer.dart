import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import 'package:farm_management_system/services/groq_chat_service.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/typing_indicator.dart';
import '../../services/chat_history_service.dart';
import '../../models/chat_session.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GroqChatService _chatService = GroqChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHistoryService _historyService = ChatHistoryService();
  final List<ChatMessage> _messages = [];
  int? _currentSessionId;
  bool _isTyping = false;
  List<ChatSession> _sessions =[];
  bool _loadingChats = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _messages.add(
      ChatMessage(
        text:
            "👋 Hello! I'm RIMAI.\n\nHow can I help you today?",
        isUser: false,
      ),
    );
  }

  Future<void> _createNewChat() async {
    _currentSessionId = await _historyService.createNewChat();
    await _loadSessions();
    setState((){
      _messages.clear();
      _messages.add(
        ChatMessage(
          text: "👋 Hello! I'm RIMAI.\n\nHow can I help you today?",
          isUser: false,
        ),
      );
    });
    await _loadChatSessions();
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Chat Session"),
            content: const Text(
              "Are you sure you want to delete this chat session? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text("Delete"),
              ),
            ],
          );
        },
      ) ??
      false;
  }

  Future<void> _loadSessions() async{
    setState((){
      _loadingChats = true;
    });
    if (mounted){
      setState((){
        _loadingChats = false;
      });
    }
  }
  Future<void> _openSession(int id) async {
    _currentSessionId = id;
    _chatService.clearConversation();
    final history = await _historyService.getMessages(id);
    setState(() {
      _messages.clear();
      _messages.addAll(history.map((item)=> ChatMessage(
        text: item.message,
        isUser: item.isUser,
      )));
    });
  }
  Future<void> _loadChatSessions() async {
    setState(() {
      _loadingChats = true;
    });

    _sessions = await _historyService.getChats();

    if(mounted){
      setState((){
        _loadingChats = false;
      });
    }
  }
  Future<void> _initializeChat() async {
      await _loadChatSessions();
      //final chats = await _historyService.getChats();
      if(_sessions.isEmpty){
         _currentSessionId = await _historyService.createNewChat();
        await _historyService.saveMessage(
          sessionId: _currentSessionId!,
          message: "👋 Hello! I'm RIMAI.\n\nHow can I help you today?",
          isUser: false,
        );
        await _loadChatSessions();
      }else{
        _currentSessionId = _sessions.first.id;
        final history = await _historyService.getMessages(_currentSessionId!,        );

        setState((){
          _messages.clear();
          _messages.addAll(
            history.map(
              (e) => ChatMessage(
                text: e.message,
                isUser: e.isUser,
              ),
            ),
          );
        });
      }
    }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),);
        _isTyping=true;
    });
    await _historyService.saveMessage(
      sessionId: _currentSessionId!,
      message: text,
      isUser: true,
    );

    final currentMessages = await _historyService.getMessages(_currentSessionId!);
    final userMessages = currentMessages.where((m)=> m.isUser).toList();

    if (userMessages.length==1){
      final dynamicTitle = text.length>30?'${text.substring(0, 30)}...':text;
      await _historyService.updateSessionTitle(_currentSessionId!, dynamicTitle);
      await _loadChatSessions();
    }
    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await _chatService.sendMessage(text);

      setState(() {
        _messages.add(
          ChatMessage(
            text: reply,
            isUser: false,
          ),
        );
        _isTyping = false;
      });

      await _historyService.saveMessage(
        sessionId: _currentSessionId!,
        message: reply,
        isUser: false,
      );
      _scrollToBottom();
    } catch (e) {

      setState(() {

        _messages.add(
          ChatMessage(
            text: "Error \n\n${e.toString()}",
            isUser: false,
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();

    }

  }

  void _scrollToBottom() {

    Future.delayed(
      const Duration(milliseconds: 150),
      () {

        if (_scrollController.hasClients) {

          _scrollController.animateTo(

            _scrollController.position.maxScrollExtent,

            duration:
                const Duration(milliseconds: 300),

            curve: Curves.easeOut,

          );

        }

      },
    );

  }

  void _clearChat() {

    setState(() {

      _messages.clear();

      _messages.add(
        ChatMessage(
          text:
              "👋 Hello! I'm RIMAI.\n\nHow can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

    });

    _chatService.clearConversation();

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
                child: _loadingChats ? const Center(child: CircularProgressIndicator(),)
                  :ListView.builder(
                    itemCount: _sessions.length,
                    itemBuilder: (context, index){
                      final session = _sessions[index];
                      final formattedDate = session.createdAt.length>=10
                      ? session.createdAt.substring(0, 10)
                      : session.createdAt;

                      return ListTile(
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

                            if (confirm){
                              await _historyService.deleteChat(session.id!);
                              await _loadChatSessions();
                              if(_currentSessionId == session.id){
                                await _createNewChat();
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
            ]
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(
        color: Colors.white, 
        ),
        title: const Text(
          "RIMAI",
          style: TextStyle(
            color: Colors.white,
          )
        ),
        backgroundColor: Color.fromRGBO(16, 6, 51, 1),
        centerTitle: true,

      ),

      body: Column(

        children: [

          Expanded(

            child: ListView.builder(

              controller: _scrollController,

              padding: const EdgeInsets.all(12),

              itemCount:
                  _messages.length + (_isTyping ? 1 : 0),

              itemBuilder: (context, index) {

                if (_isTyping &&
                    index == _messages.length) {
                  return const TypingIndicator();
                }

                return ChatBubble(
                  message: _messages[index],
                );

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

                    decoration:
                        const InputDecoration(

                      hintText:
                          "Ask RIMAI AI...",

                      border:
                          OutlineInputBorder(),

                    ),

                    onSubmitted: (_) =>
                        _sendMessage(),

                  ),

                ),

                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,

                  onPressed:
                      _isTyping ? null : _sendMessage,
                  child:
                      const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

