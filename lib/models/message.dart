class Message {
  final String text;
  final String senderId;
  final String sednerEmail;
  final String receiverId;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.sednerEmail,
    required this.receiverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp.toIso8601String(),
      'senderEmail': sednerEmail,
      'receiverId': receiverId,
    };
  }
}
