// // import 'dart:async';
// // import 'dart:convert';
// //
// // import 'package:flutter/cupertino.dart';
// // import 'package:forum/constants.dart';
// // import 'package:forum/url/user.dart';
// // import 'package:web_socket_channel/io.dart';
// // import 'package:web_socket_channel/web_socket_channel.dart';
// //
// // import '../classes/localStorage.dart';
// // import '../classes/message.dart';
// // import '../classes/notification_card.dart';
// // import '../storage/notificationInfo_storage.dart';
// //
// // class WebSocketService extends ChangeNotifier{
// //
// //   static final WebSocketService _instance = WebSocketService._internal();
// //   factory WebSocketService() => _instance;
// //
// //   WebSocketService._internal();
// //   final notificationStorage = NotificationStorage();
// //
// //   IOWebSocketChannel? _channel;
// //   StreamController<String> _messageController = StreamController.broadcast();
// //   Stream<dynamic>? get stream => _messageController.stream;
// //
// //   Timer? _reconnectTimer; // 定时器
// //   bool _isConnected = false; // WebSocket 连接状态
// //   bool _needReconnect = false; // 是否需要重新连接
// //   int _reconnectDelay = 5; // 重连延迟时间（秒）
// //   String userId = '';
// //
// //   void _onError(dynamic error) {
// //     print('WebSocket error: $error');
// //     _isConnected = false; // 连接出现错误，标记为未连接状态
// //     _needReconnect = true;
// //     _startReconnectTimer(); // 启动定时器，准备重新连接
// //   }
// //
// //   void _onDone() {
// //     print('WebSocket connection closed');
// //     _isConnected = false; // WebSocket 连接关闭，标记为未连接状态
// //     _startReconnectTimer(); // 启动定时器，准备重新连接
// //   }
// //
// //   void _startReconnectTimer() {
// //     if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
// //       _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), _reconnect);
// //     }
// //   }
// //
// //   void _reconnect() {
// //     if (!_isConnected) {
// //       connect(LocalStorage.getString('userId') ?? userId); // 尝试重新连接
// //     }
// //   }
// //
// //   void connect(String userId) {
// //     this.userId = userId;
// //     String url = "$WEBSOCKET_URL/$userId";
// //
// //     // _channel = IOWebSocketChannel.connect(url);
// //     // _channel?.stream.listen(_onMessageReceived);
// //     // _isConnected = true; // 连接建立成功
// //   }
// //
// //
// //   void _onMessageReceived(dynamic message) {
// //     // Add the received message to the stream
// //     Message message1 = Message.fromString(message);
// //     requestGet("/api/user/get_user",
// //         {
// //           'Authorization': 'Bearer ${LocalStorage.getString('token')}',
// //         },query: {
// //           'userId': message1.senderId
// //         }
// //     ).then((res){
// //       String decodedString = utf8.decode(res.bodyBytes);
// //       Map body = jsonDecode(decodedString) as Map;
// //       notificationStorage.findNotification(body['content']['userId']).then((value) => {
// //         if(value == null){
// //           notificationStorage.saveNotification(NotificationInfo(
// //               friendId: body['content']['userId'],
// //               content: message1.content,
// //               info_num: 1,
// //               time: message1.time
// //           )).then((value){
// //             _messageController.add(message);
// //             notifyListeners(); // 通知监听者，有新的消息
// //           })
// //         }
// //         else{
// //           notificationStorage.saveNotification(NotificationInfo(
// //               friendId: body['content']['userId'],
// //               content: message1.content,
// //               info_num: value.info_num + 1,
// //               time: message1.time
// //           )).then((value){
// //             _messageController.add(message);
// //             notifyListeners(); // 通知监听者，有新的消息
// //           })
// //         }
// //       });
// //     });
// //   }
// //
// //   Future<void> sendMessage(String message) async {
// //     if (_channel != null) {
// //       _channel!.sink.add(message);
// //     }
// //     else{
// //       throw "Connection is not established";
// //     }
// //   }
// //
// //   IOWebSocketChannel? get channel => _channel;
// //
// //   void close() {
// //     _channel?.sink.close();
// //     _messageController.close();
// //     _reconnectTimer?.cancel();
// //     _needReconnect = false;
// //   }
// // }
//
// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:forum/url/user.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../storage/notificationInfo_storage.dart';
// import '../classes/localStorage.dart';
// import '../classes/message.dart';
// import '../classes/notification_card.dart';
// import '../constants.dart';
// import 'package:web_socket_channel/status.dart' as status;
//
// class WebSocketService extends ChangeNotifier {
//   static final WebSocketService _instance = WebSocketService._internal();
//   factory WebSocketService() => _instance;
//   WebSocketService._internal();
//
//   final notificationStorage = NotificationStorage();
//   late  WebSocketChannel channel;
//   StreamController<String> _messageController = StreamController.broadcast();
//
//    void connect(String userId) {
//      try{
//        channel.sink.close(status.goingAway);
//      }
//      catch(e){
//        print(e.toString());
//      }
//      channel = WebSocketChannel.connect(Uri.parse("$WEBSOCKET_URL/${userId}"));
//      channel.ready.then((value){
//        print('websocket  ready');
//        channel.stream.listen(_onMessageReceived);
//      });
//    }
//
//   void _onMessageReceived(dynamic message) {
//     // Add the received message to the stream
//     Message message1 = Message.fromString(message);
//
//     requestGet("/api/user/get_user",
//         {
//           'Authorization': 'Bearer ${LocalStorage.getString('token')}',
//         },query: {
//           'userId': message1.senderId
//         }
//     ).then((res){
//       String decodedString = utf8.decode(res.bodyBytes);
//       Map body = jsonDecode(decodedString) as Map;
//       notificationStorage.findNotification(body['content']['userId']).then((value) => {
//         if(value == null){
//           notificationStorage.saveNotification(NotificationInfo(
//               friendId: body['content']['userId'],
//               content: message1.content,
//               info_num: 1,
//               time: message1.time
//           )).then((value){
//             _messageController.add(message);
//             notifyListeners(); // 通知监听者，有新的消息
//           })
//         }
//         else{
//           notificationStorage.saveNotification(NotificationInfo(
//               friendId: body['content']['userId'],
//               content: message1.content,
//               info_num: value.info_num + 1,
//               time: message1.time
//           )).then((value){
//             _messageController.add(message);
//             notifyListeners(); // 通知监听者，有新的消息
//           })
//         }
//       });
//     });
//   }
//
//   Future<void> sendMessage(String message) async {
//     try{
//       channel.sink.add(message);
//     }
//     catch(e){
//       print(e.toString());
//       print("Connection is not established");
//       throw "Connection is not established";
//     }
//   }
//
//   void close() {
//      try{
//        channel.sink.close(status.goingAway);
//      }
//      catch(e){
//        print('close');
//        print(e.toString());
//      }
//     _messageController.close();
//   }
//
//   Stream<dynamic>? get stream => _messageController.stream;
// }


import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/url/user.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../classes/message.dart';
import '../classes/notification_card.dart';
import '../constants.dart';
import '../storage/notificationInfo_storage.dart';

class WebSocketService extends ChangeNotifier {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IOWebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  late String _url = "$WEBSOCKET_URL/${LocalStorage.getString('userId')}";
  final notificationStorage = NotificationStorage();
  StreamController<String> _messageController = StreamController.broadcast();

  Stream<dynamic>? get stream => _messageController.stream;

  Future<void> sendMessage(String message) async {
    try{
      _channel?.sink.add(message);
    }
    catch(e){
      print(e.toString());
      print("Connection is not established");
      throw "Connection is not established";
    }
  }

  void connect(String userId) {
    _url = "$WEBSOCKET_URL/${userId}";
    print(_channel);
    if (_channel != null) {
      print('WebSocket already initialized');
      return;
    }

    _channel = IOWebSocketChannel.connect(_url);

    _channel?.stream.listen(
      _onMessageReceived,
      onDone: _onDone,
      onError: _onError,
    );

    // 发送心跳包
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_channel != null) {
        _channel?.sink.add('ping');
      }
    });
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

  void _onDone() {
    print('WebSocket closed');
    _reconnect();
  }

  void _onError(error) {
    print('WebSocket error: $error');
    _reconnect();
  }

  void _reconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      print('Attempting to reconnect...');
      connect(LocalStorage.getString('userId') ?? '');
    });
  }

  void close() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  bool isInitialized() {
    return _channel != null;
  }
}

