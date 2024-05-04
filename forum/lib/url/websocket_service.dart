import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:forum/constants.dart';
import 'package:web_socket_channel/io.dart';

import '../classes/message.dart';
import '../classes/notification_card.dart';
import '../storage/notificationInfo_storage.dart';

class WebSocketService extends ChangeNotifier{
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  static  List<String> _messages_text = <String>[];
  static List<Message> _messages = <Message>[];
  static List<NotificationInfo> _notificationInfos = <NotificationInfo>[];
  StreamController<String> _messageController = StreamController.broadcast();
  WebSocketService._internal();
  final notificationStorage = NotificationStorage();

  IOWebSocketChannel? _channel;
  Stream<dynamic>? get stream => _messageController.stream;

  void connect(String userId) {
    String url = "$WEBSOCKET_URL/$userId";
    _channel = IOWebSocketChannel.connect(url);
    _channel?.stream.listen(_onMessageReceived);
  }

  void _onMessageReceived(dynamic message) {
    // Add the received message to the stream
    Message message1 = Message.fromString(message);
    notificationStorage.saveNotification(NotificationInfo(
      friendId: message1.senderId,
      content: message1.content,
      info_num: 1,
      time: message1.time
    )).then((value){
      print("saved");
      _messageController.add(message);
      notifyListeners(); // 通知监听者，有新的消息
    });
  }

  Future<void> sendMessage(String message) async {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
    else{
      throw "Connection is not established";
    }
  }



  IOWebSocketChannel? get channel => _channel;

  void close() {
    _channel?.sink.close();
  }
}
