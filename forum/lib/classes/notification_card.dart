import 'dart:core';

class NotificationInfo {
  final String friendId;
  final String time;
  final String content;
  final int info_num;

  NotificationInfo({
    required this.friendId,
    required this.time,
    required this.content,
    required this.info_num,
  });


  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'time': time,
      'content': content,
      'info_num': info_num,
    };
  }

  factory NotificationInfo .fromJson(Map<String, dynamic> json) {
    return NotificationInfo (
      friendId: json['friendId'],
      time: json['time'],
      content: json['content'],
      info_num: json['info_num'],
    );
  }
}