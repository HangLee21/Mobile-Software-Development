import 'dart:core';

class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final String time;
  final String ownerId;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.time,
    required this.ownerId,
  });



  factory Message.fromString(String messageString) {
    // 使用正则表达式提取消息中的各个字段
    print(messageString);
    final RegExp regExp = RegExp(r"Message\(messageId=(.+), senderId=(.+), receiverId=(\w+), content=(.*), time=(.*), ownerId=(\w+)\)");
    final match = regExp.firstMatch(messageString);
    if (match != null) {
      final messageId = match.group(1)!;
      final senderId = match.group(2)!;
      final receiverId = match.group(3)!;
      final content = match.group(4)!;
      final time = match.group(5)!;
      final ownerId = match.group(6)!;
      return Message(
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        time: time,
        ownerId: ownerId,
      );
    } else {
      throw FormatException("Invalid message format");
    }
  }
}