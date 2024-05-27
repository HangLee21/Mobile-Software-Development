import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:forum/constants.dart';
import 'package:forum/url/user.dart';
import 'package:web_socket_channel/io.dart';

import '../classes/localStorage.dart';
import '../classes/message.dart';
import '../classes/notification_card.dart';
import '../storage/notificationInfo_storage.dart';

class WebSocketService extends ChangeNotifier{
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketService._internal();
  final notificationStorage = NotificationStorage();

  IOWebSocketChannel? _channel;
  StreamController<String> _messageController = StreamController.broadcast();
  Stream<dynamic>? get stream => _messageController.stream;

  Timer? _reconnectTimer; // 定时器
  bool _isConnected = false; // WebSocket 连接状态
  int _reconnectDelay = 5; // 重连延迟时间（秒）
  String userId = '';

  void _onError(dynamic error) {
    print('WebSocket error: $error');
    _isConnected = false; // 连接出现错误，标记为未连接状态
    _startReconnectTimer(); // 启动定时器，准备重新连接
  }

  void _onDone() {
    print('WebSocket connection closed');
    _isConnected = false; // WebSocket 连接关闭，标记为未连接状态
    _startReconnectTimer(); // 启动定时器，准备重新连接
  }

  void _startReconnectTimer() {
    if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
      _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), _reconnect);
    }
  }

  void _reconnect() {
    if (!_isConnected) {
      connect(LocalStorage.getString('userId') ?? userId); // 尝试重新连接
    }
  }

  void connect(String userId) {
    this.userId = userId;
    String url = "$WEBSOCKET_URL/$userId";
    _channel = IOWebSocketChannel.connect(url);
    _channel?.stream.listen(_onMessageReceived, onError: _onError, onDone: _onDone);
    _isConnected = true; // 连接建立成功
  }


  void _onMessageReceived(dynamic message) {
    // Add the received message to the stream
    Message message1 = Message.fromString(message);
    requestGet("/api/user/get_user",
        {
          'Authorization': 'Bearer ${LocalStorage.getString('token')}',
        },query: {
          'userId': message1.senderId
        }
    ).then((res){
      String decodedString = utf8.decode(res.bodyBytes);
      Map body = jsonDecode(decodedString) as Map;
      notificationStorage.findNotification(body['content']['userId']).then((value) => {
        if(value == null){
          notificationStorage.saveNotification(NotificationInfo(
              friendId: body['content']['userId'],
              content: message1.content,
              info_num: 1,
              time: message1.time
          )).then((value){
            _messageController.add(message);
            notifyListeners(); // 通知监听者，有新的消息
          })
        }
        else{
          notificationStorage.saveNotification(NotificationInfo(
              friendId: body['content']['userId'],
              content: message1.content,
              info_num: value.info_num + 1,
              time: message1.time
          )).then((value){
            _messageController.add(message);
            notifyListeners(); // 通知监听者，有新的消息
          })
        }
      });
    });
  }

  Future<void> sendMessage(String message) async {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
    else{
      // _reconnect();
      throw "Connection is not established";
    }
  }

  IOWebSocketChannel? get channel => _channel;

  void close() {
    _channel?.sink.close();
  }
}
