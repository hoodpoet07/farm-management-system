import '../database/database_helper.dart';
import '../models/chat_history.dart';
import '../models/chat_session.dart';

class ChatHistoryService{
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> createNewChat()async{
    final session = ChatSession(
      title: 'New Chat',
      createdAt: DateTime.now().toIso8601String(),
    );
    return _db.createChatSession(session);
  }

  Future<List<ChatSession>> getChats() async{
    return await _db.getChatSessions();
  }

  Future<List<ChatHistory>> getMessages(int sessionId) async {
    return await _db.getChatMessages(sessionId);
  }

  Future<void> updateSessionTitle(int sessionId, String title) async {
    final db = await _db.database;
    await db.update(
      'chat_sessions',
      {'title': title},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> saveMessage({
    required int sessionId,
    required String message,
    required bool isUser,
  }) async {
    await _db.insertChatMessage(
      ChatHistory(
        sessionId: sessionId,
        message: message,
        isUser: isUser,
        timestamp: DateTime.now().toIso8601String(),
      )
    );
  }

  Future<void> deleteChat(int sessionId) async {
    await _db.deleteChatSession(sessionId);
  }
}