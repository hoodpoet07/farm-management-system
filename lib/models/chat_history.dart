class ChatHistory {
  final int? id;
  final int sessionId;
  final String message;
  final bool isUser;
  final String timestamp;

  ChatHistory({
    this.id,
    required this.sessionId,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'message': message,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp,
    };
  }

  factory ChatHistory.fromMap(Map<String, dynamic> map) {
    return ChatHistory(
      id: map['id'],
      sessionId: map['sessionId'],
      message: map['message'],
      isUser: map['isUser']==1,
      timestamp: map['timestamp'],
    );
  }
}