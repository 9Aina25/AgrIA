class ChatMessage {
  final String userMessage;
  final String botMessage;
  final DateTime timestamp;

  ChatMessage({
    required this.userMessage,
    required this.botMessage,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      userMessage: json['user_message'] ?? '',
      botMessage: json['bot_message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_message': userMessage,
      'bot_message': botMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}