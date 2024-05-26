import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:better_player/better_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/message.dart';
import '../classes/notification_card.dart';
import '../components/chat_bubble.dart';
import '../components/notificationcard.dart';
import '../constants.dart';
import '../storage/notificationInfo_storage.dart';
import '../url/websocket_service.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:path_provider/path_provider.dart';
// TODO add websocket listener
class ChatPage extends StatefulWidget{
  final String userId;
  // TODO change self id
  String selfId = '';
  ChatPage({super.key, required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>{

  //{'name': 'chl','content': 'content','me?': true,'createdAt': '2024-03-07 15:56','status': 1},
  List<Map> messages = [];
  SharedPreferences? sharedPreferences;
  final _websocketService = WebSocketService();
  // String employeeNo;
  double contentMaxWidth = 500;
  late TextEditingController textEditingController;
  ScrollController _scrollController = ScrollController(); //listview的控制器
  late VideoPlayerController _controller;
  late final RecorderController recorderController;
  late FlickManager flickManager;

  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  late Directory appDirectory;
  final _player = AudioPlayer();
  StreamSubscription<dynamic>? _streamSubscription;


  void _initLocalStorage()async{
      widget.selfId = LocalStorage.getString('userId')!;
      LocalStorage.setString('currentUserId', widget.userId);
  }
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    _getDir();
    _initLocalStorage();
    // get chat history
    initData();
    // listen to websocket
    initWebSocket();
    _initialiseControllers();
  }
  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";
    isLoading = false;
    setState(() {});
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        recorderController.reset();
        path = await recorderController.stop(false);
        if (path != null) {
          isRecordingCompleted = true;
          debugPrint(path);
          debugPrint("Recorded file size: ${File(path!).lengthSync()}");
          addAudio(path!);
        }
      } else {
        await recorderController.record(path: path); // Path is optional
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void _refreshWave() {
    if (isRecording) recorderController.refresh();
  }

  @override
  void dispose() {
    recorderController.dispose();
    _streamSubscription?.cancel();
    LocalStorage.remove('currentUserId');
    // if(_betterPlayerController.i)
    // _betterPlayerController.dispose();
    super.dispose();
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  initWebSocket() async {
    _streamSubscription = _websocketService.stream!.listen((message) async {
      setState(() {
        Message message1 = Message.fromString(message);
        // print('chat');
        // print(message1);
        // 截取日期和时间部分
        String datePart = message1.time.substring(0, 10);
        String timePart = message1.time.substring(11, 19);

        // 格式化时间
        String formattedTime = '$datePart $timePart';
        if(message1.senderId == widget.userId){
          requestGet('/api/user/get_user', {
            'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
          },query: {
            'userId': message1.senderId,
          }).then((http.Response res2) {
            String decodedString = utf8.decode(res2.bodyBytes);
            Map body2 = jsonDecode(decodedString) as Map;
            setState(() {
              messages.insert(0, {
                'name': body2['content']['userName'],
                'content': message1.content,
                'me?': false,
                'createdAt': formattedTime,
                'status': 1,
                'show': true
              });
            });
          });

          if(messages.length > 1){
            DateTime current = DateTime.parse(formatTime(messages[0]['createdAt']));
            DateTime previous = DateTime.parse(formatTime(messages[1]['createdAt']));
            Duration difference = current.difference(previous);
            if (difference.inMinutes <= 5) {
              messages[0]['show'] = false;
            }
          }
        }
        else{
          // 定义正则表达式模式
          RegExp regex = RegExp(r'\((.*?)\)\[(.*?)\]');
          //print('content: '+ item['content']);
          Match? match = regex.firstMatch(message1.content);
          String content = message1.content;
          // 检查是否匹配成功
          if (match != null) {
            content = '暂不支持的消息格式，请跳转页面详细观看内容';
          }
          requestGet('/api/user/get_user', {
            'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
          },query: {
            'userId': message1.senderId,
          }).then((http.Response res2) {
            String decodedString = utf8.decode(res2.bodyBytes);
            Map body2 = jsonDecode(decodedString) as Map;
            AnimatedSnackBar(
              duration: Duration(seconds: 4),
              builder: ((context) {
                return NotificationCard(
                  friendname: body2['content']['userName'],
                  content: content,
                  url: '',
                  friendId: message1.senderId,
                  info_num: 0,
                  remove: true,
                  onPressed: () {

                  },
                );
              }),
            ).show(context);
          });
        }
      });
    });
  }

  initData() async {
    //print(LocalStorage.getString('token'));
    requestGet("/api/chat/get_all_messages", {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
      },query:  {
      "userId": widget.selfId,
      "anotherId": widget.userId
    }).then((response) {
      setState(() {
        //print(response.statusCode);
        if (response.statusCode == 200) {
          String decodedString = utf8.decode(response.bodyBytes);
          Map body = jsonDecode(decodedString) as Map;

          for(var item in body['messages']){
            // 截取日期和时间部分
            String datePart = item['time'].substring(0, 10);
            String timePart = item['time'].substring(11, 19);

            // 格式化时间
            String formattedTime = '$datePart $timePart';
            requestGet('/api/user/get_user', {
              'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
            },query: {
              'userId': item.senderId,
            }).then((http.Response res2) {
              String decodedString = utf8.decode(res2.bodyBytes);
              Map body2 = jsonDecode(decodedString) as Map;
              messages.insert(0, {
                'name': body2['content']['userName'],
                'content': item['content'],
                'createdAt': formattedTime,
                'me?': item['senderId'] == widget.selfId,
                'status': 1,
                'show': true
              });
            });
          }
        }
      });
    });
  }

  String formatTime(String time){
    String formatted = '$time.000';
    return formatted;
  }

  _renderList() {
    return GestureDetector(
      child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 27),
        itemBuilder: (context, index) {
          var item = messages[index];
          if(index != messages.length - 1){
            //if time difference is less than 5 minutes, don't show time
            DateTime current = DateTime.parse(formatTime(messages[index]['createdAt']));
            DateTime previous = DateTime.parse(formatTime(messages[index + 1]['createdAt']));
            Duration difference = current.difference(previous);
            if (difference.inMinutes <= 5) {
              messages[index]['show'] = false;
            }
          }
          return GestureDetector(
            child: item['me?'] == true
                ? _renderRowSendByMe(context, item)
                : _renderRowSendByOthers(context, item),
            onTap: () {},
          );
        },
        itemCount: messages.length,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );


  }
  late BetterPlayerController _betterPlayerController;

  Widget _renderRowSendByOthers(BuildContext context, item) {
    // 定义正则表达式模式
    RegExp regex = RegExp(r'\((.*?)\)\[(.*?)\]');
    String type = '';
    String url = '';
    String filename = '';
    String filepath = '';
    // 进行匹配
    //print('content: '+ item['content']);
    Match? match = regex.firstMatch(item['content']);

    // 检查是否匹配成功
    if (match != null) {
      // 输出第一个括号内的内容（第一个单词）
      //print('第一个单词: ${match.group(1)}');
      // 输出第二个括号内的内容（第二个单词）
      //print('第二个单词: ${match.group(2)}');
      type = match.group(1).toString();
      url = match.group(2).toString();
      print(url);
      if(type != picType && type != videoType && type != audioType){
        type = '';
      }

      if(type == videoType){
        BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            url);
        _betterPlayerController = BetterPlayerController(
            BetterPlayerConfiguration(
              fit: BoxFit.contain,
              handleLifecycle: false, // 禁用预加载
            ),
            betterPlayerDataSource: betterPlayerDataSource);
      }
      else if(type == audioType){
        filename = url.split('/').last;
        filepath = '${appDirectory.path}/$filename';
        if(!checkFileExists(filepath)){
          downloadFile(url, filepath);
        }
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        children: <Widget>[
          if(item['show'])
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                item['createdAt'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFA1A6BB),
                  fontSize: 14,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: 15,right: 45),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Color(0xFF464EB5),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Padding(
                    child: Text(
                      item['name'].toString().substring(0, 1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: 2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        child: Text(
                          item['name'],
                          softWrap: true,
                          style: TextStyle(
                            color: Color(0xFF677092),
                            fontSize: 14,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 20, right: 30),
                      ),
                      Stack(
                        children: <Widget>[
                          // TODO add arrow
                          // Container(
                          //   child: Image(
                          //       width: 11,
                          //       height: 20,
                          //       image: AssetImage(
                          //           "static/images/chat_white_arrow.png")),
                          //   margin: EdgeInsets.fromLTRB(2, 16, 0, 0),
                          // ),
                          if (type == picType)
                            ConstrainedBox(constraints: BoxConstraints(
                              maxWidth: 300,
                              maxHeight: 200,
                            ),
                              child: Image.network(
                                url,
                              ),
                            ),
                          if (type == videoType)
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 300,
                                maxHeight: 200,
                              ),
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 20, 10, 0),
                                  child: BetterPlayer(
                                    controller: _betterPlayerController,
                                  ),
                              ),
                            ),
                          if (type == audioType)
                            WaveBubble(
                              filename: filename,
                              isSender: false,
                              width: MediaQuery.of(context).size.width / 2,
                              appDirectory: appDirectory,
                            ),
                          if (type == '')
                          Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(4.0, 7.0),
                                    color: Color(0x04000000),
                                    blurRadius: 10,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                            margin: EdgeInsets.only(top: 8, left: 10),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                    Text(
                                      item['content'],
                                      style: TextStyle(
                                        color: Color(0xFF677092),
                                        fontSize: 14,
                                      ),
                                    ),
                              ],
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderRowSendByMe(BuildContext context, item) {
    // 定义正则表达式模式
    RegExp regex = RegExp(r'\((.*?)\)\[(.*?)\]');
    String type = '';
    String url = '';
    //print('content: '+ item['content']);
    Match? match = regex.firstMatch(item['content']);
    String filename = '';
    String filepath = '';
    // 检查是否匹配成功
    if (match != null) {
      // 输出第一个括号内的内容（第一个单词）
      //print('第一个单词: ${match.group(1)}');
      // 输出第二个括号内的内容（第二个单词）
      //print('第二个单词: ${match.group(2)}');
      type = match.group(1).toString();
      url = match.group(2).toString();
      if(type != picType && type != videoType && type != audioType){
        type = '';
      }
      print(url);
      if(type == videoType){
        BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            url);
        _betterPlayerController = BetterPlayerController(
            BetterPlayerConfiguration(
              fit: BoxFit.contain,
              handleLifecycle: false, // 禁用预加载
            ),
            betterPlayerDataSource: betterPlayerDataSource);
      }
      else if(type == audioType){
        filename = url.split('/').last;
        filepath = '${appDirectory.path}/$filename';
        if(!checkFileExists(filepath)){
          downloadFile(url, filepath);
        }
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        children: <Widget>[
          if(item['show'])
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                item['createdAt'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFA1A6BB),
                  fontSize: 14,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 15),
                alignment: Alignment.center,
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                    color: Color(0xFF464EB5),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    item['name'].toString().substring(0, 1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      item['name'],
                      softWrap: true,
                      style: TextStyle(
                        color: Color(0xFF677092),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      // TODO add arrow
                      // Container(
                      //   margin: EdgeInsets.fromLTRB(0, 16, 2, 0),
                      //   child: const Image(
                      //       width: 11,
                      //       height: 20,
                      //       image: AssetImage(
                      //           "static/images/chat_purple_arrow.png")),
                      // ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: contentMaxWidth + 10,
                        ),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: <Widget>[
                            if (type == picType)
                              ConstrainedBox(constraints: BoxConstraints(
                                maxWidth: 300,
                                maxHeight: 200,
                              ),
                                child: Image.network(
                                  url,
                                ),
                              ),
                            if (type == videoType)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 300,
                                  maxHeight: 200,
                                ),
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 20, 10, 0),
                                  child: BetterPlayer(
                                    controller: _betterPlayerController,
                                  ),
                                ),
                              ),
                            if (type == audioType)
                            // TODO add audio player
                              WaveBubble(
                                filename: filename,
                                isSender: true,
                                width: MediaQuery.of(context).size.width / 2,
                                appDirectory: appDirectory,
                              ),
                            if (type == '')
                              ConstrainedBox(
                                child: Container(
                                    margin: EdgeInsets.only(top: 8, right: 10),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(4.0, 7.0),
                                            color: Color(0x04000000),
                                            blurRadius: 10,
                                          ),
                                        ],
                                        color: Color(0xFF838CFF),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Text(
                                          item['content'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: contentMaxWidth,
                                ),
                              ),
                            Container(
                                margin: EdgeInsets.fromLTRB(0, 8, 8, 0),
                                child: item['status'] == SENDING_TYPE
                                    ? ConstrainedBox(
                                  constraints:
                                  BoxConstraints(maxWidth: 10, maxHeight: 10),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: new AlwaysStoppedAnimation<Color>(
                                          Colors.grey),
                                    ),
                                  ),
                                )
                                // : item['status'] == FAILED_TYPE
                                // ? Image(
                                // width: 11,
                                // height: 20,
                                // image: AssetImage(
                                //     "assets/images/1.jpg"))
                                // :
                                    :Container()),
                          ],
                        ),
                      )

                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  final int maxValue = 1<<32;

  sendTxt() async {
    if (textEditingController.text == '') {
      return;
    }
    // 获取当前时间
    DateTime now = DateTime.now().toLocal();
    // 将时间格式化为字符串，精确到秒
    // 转化时区
    now = now.add(Duration(hours: 8));
    String formattedTime = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
    String content = textEditingController.text;
    setState(() {
      messages.insert(0, {
        'name': widget.selfId,
        'content': textEditingController.text,
        'me?': true,
        'createdAt': formattedTime,
        'status': SENDING_TYPE,
        'show': true
      });
    });

    if(messages.length > 1){
      DateTime current = DateTime.parse(formatTime(messages[0]['createdAt']));
      DateTime previous = DateTime.parse(formatTime(messages[1]['createdAt']));
      Duration difference = current.difference(previous);
      if (difference.inMinutes <= 5) {
        messages[0]['show'] = false;
      }
    }
    Timer(Duration(milliseconds: 100),
            () => _scrollController.jumpTo(0));
    textEditingController.clear();
    _websocketService.sendMessage("SINGLE_SENDING:${widget.selfId}:${widget.userId}:${content}").then((value) {
      setState(() {
        messages[0]['status'] = SUCCESSED_TYPE;
      });
    }).catchError((e) {
      setState(() {
        messages[0]['status'] = FAILED_TYPE;
      });
    });

    // add to local storage
    NotificationInfo notification = NotificationInfo(friendId: widget.userId, time: formattedTime, content: content, info_num: 0);
    NotificationStorage().saveNotification(notification);
  }

  final random = Random();

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  void addAudio(String path) async {
    File file = File(path);
    var uri = Uri.parse('http://$BASEURL/api/cos/upload_chat_pictures');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${LocalStorage.getString('token') ?? ''}',
    });
    request.fields.addAll({
      'userId': LocalStorage.getString('userId') ?? '',
    });

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      LocalStorage.setString('token', json.decode(responseBody)['token']);
      var data = jsonDecode(responseBody);
      String url = data['content'][0];
      String content = "SINGLE_SENDING:${widget.selfId}:${widget.userId}:($audioType)[$url]";
      addMessage(content, 'audio');
    }
  }

  void addPicture() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path!);
      var uri = Uri.parse('http://$BASEURL/api/cos/upload_chat_pictures');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer ${LocalStorage.getString('token') ?? ''}',
      });
      request.fields.addAll({
        'userId': LocalStorage.getString('userId') ?? '',
      });

      DateTime now = DateTime.now().toLocal();
      // 将时间格式化为字符串，精确到秒
      // 转化时区
      now = now.add(Duration(hours: 8));
      String formattedTime = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
          '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
      setState(() {
        messages.insert(0, {
          'name': widget.selfId,
          'content': '正在发送中',
          'me?': true,
          'createdAt': formattedTime,
          'status': SENDING_TYPE,
          'show': true
        });
      });

      if(messages.length > 1){
        DateTime current = DateTime.parse(formatTime(messages[0]['createdAt']));
        DateTime previous = DateTime.parse(formatTime(messages[1]['createdAt']));
        Duration difference = current.difference(previous);
        if (difference.inMinutes <= 5) {
          messages[0]['show'] = false;
        }
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        LocalStorage.setString('token', json.decode(responseBody)['token']);
        var data = jsonDecode(responseBody);
        String url = data['content'][0];
        String content = "SINGLE_SENDING:${widget.selfId}:${widget.userId}:($picType)[$url]";
        messages.removeAt(0);
        addMessage(content, 'image');
      }
      else{
        var responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);
        String content = "SINGLE_SENDING:${widget.selfId}:${widget.userId}:${data}]";
        addErrorMessage(content);
        print(response.statusCode);
      }
    }
  }

  void addVideo()async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      File file = File(result.files.single.path!);
      var uri = Uri.parse('http://$BASEURL/api/cos/upload_chat_pictures');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer ${LocalStorage.getString('token') ?? ''}',
      });
      request.fields.addAll({
        'userId': LocalStorage.getString('userId') ?? '',
      });

      var response = await request.send();
      DateTime now = DateTime.now().toLocal();
      // 将时间格式化为字符串，精确到秒
      // 转化时区
      now = now.add(Duration(hours: 8));
      String formattedTime = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
          '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
      setState(() {
        messages.insert(0, {
          'name': widget.selfId,
          'content': '正在发送中',
          'me?': true,
          'createdAt': formattedTime,
          'status': SENDING_TYPE,
          'show': true
        });
      });

      if(messages.length > 1){
        DateTime current = DateTime.parse(formatTime(messages[0]['createdAt']));
        DateTime previous = DateTime.parse(formatTime(messages[1]['createdAt']));
        Duration difference = current.difference(previous);
        if (difference.inMinutes <= 5) {
          messages[0]['show'] = false;
        }
      }

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        LocalStorage.setString('token', json.decode(responseBody)['token']);
        var data = jsonDecode(responseBody);
        String url = data['content'][0];
        String content = "SINGLE_SENDING:${widget.selfId}:${widget.userId}:($videoType)[${url}]";
        messages.removeAt(0);
        addMessage(content, 'video');
      }
      else{
        var responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);
        String content = "SINGLE_SENDING:${widget.selfId}:${widget.userId}:${data}]";
        addErrorMessage(content);
        print(response.statusCode);
      }
    }
    else{
      print("no file selected");
    }
  }

  addMessage(content, tag) {
    // 获取当前时间
    DateTime now = DateTime.now().toLocal();
    // 将时间格式化为字符串，精确到秒
    // 转化时区
    now = now.add(Duration(hours: 8));
    String formattedTime = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
    setState(() {
      messages.insert(0, {
        'name': widget.selfId,
        'content': content,
        'me?': true,
        'createdAt': formattedTime,
        'status': SENDING_TYPE,
        'show': true
      });
    });

    if(messages.length > 1){
      DateTime current = DateTime.parse(formatTime(messages[0]['createdAt']));
      DateTime previous = DateTime.parse(formatTime(messages[1]['createdAt']));
      Duration difference = current.difference(previous);
      if (difference.inMinutes <= 5) {
        messages[0]['show'] = false;
      }
    }
    Timer(Duration(milliseconds: 100),
            () => _scrollController.jumpTo(0));
    textEditingController.clear();
    _websocketService.sendMessage("SINGLE_SENDING:${widget.selfId}:${widget.userId}:${content}").then((value) {
      setState(() {
        messages[0]['status'] = SUCCESSED_TYPE;
      });
    }).catchError((e) {
      setState(() {
        messages[0]['status'] = FAILED_TYPE;
      });
    });
    if(tag == 'image' || tag == 'video' || tag == 'audio') {
      content = '未支持的媒体类型 请进入页面详细观看';
    }
    // add to local storage
    NotificationInfo notification = NotificationInfo(friendId: widget.userId, time: formattedTime, content: content, info_num: 0);
    NotificationStorage().saveNotification(notification);
  }

  void addErrorMessage(content){
    // 获取当前时间
    DateTime now = DateTime.now().toLocal();
    // 将时间格式化为字符串，精确到秒
    // 转化时区
    now = now.add(Duration(hours: 8));
    String formattedTime = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
    setState(() {
      messages.insert(0, {
        'name': widget.selfId,
        'content': content,
        'me?': true,
        'createdAt': formattedTime,
        'status': FAILED_TYPE,
        'show': true
      });
    });

    if(messages.length > 1){
      DateTime current = DateTime.parse(formatTime(messages[0]['createdAt']));
      DateTime previous = DateTime.parse(formatTime(messages[1]['createdAt']));
      Duration difference = current.difference(previous);
      if (difference.inMinutes <= 5) {
        messages[0]['show'] = false;
      }
    }
    Timer(Duration(milliseconds: 100),
            () => _scrollController.jumpTo(0));
    textEditingController.clear();
  }

  static int SENDING_TYPE = 0;
  static int FAILED_TYPE = 1;
  static int SUCCESSED_TYPE = 2;

  static String picType = "Picture";
  static String videoType = "Video";
  static String audioType = "Audio";


  @override
  Widget build(BuildContext context){
    contentMaxWidth = MediaQuery.of(context).size.width - 90;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.userId),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFF1F5FB),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                //列表内容少的时候靠上
                alignment: Alignment.topCenter,
                child: _renderList(),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(isRecording ? Icons.stop : Icons.mic),
                            color: Color(0xFF838CFF),
                            iconSize: 30, // 调整图标大小
                            onPressed: () {
                              _startOrStopRecording();
                            },
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isRecording ?
                      AudioWaveforms(
                        enableGesture: true,
                        size: Size(
                            MediaQuery.of(context).size.width / 1.5,
                            50),
                        recorderController: recorderController,
                        waveStyle: const WaveStyle(
                          waveColor: Colors.white,
                          extendWaveform: true,
                          showMiddleLine: false,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: const Color(0xFF838CFF)
                        ),
                        padding: const EdgeInsets.only(left: 18),
                        margin: EdgeInsets.fromLTRB(5, 10, 0, 10),
                      ) : Container(

                        width:
                        MediaQuery.of(context).size.width / 2.1,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F6FF),
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                        padding: const EdgeInsets.only(left: 18),
                        margin: EdgeInsets.fromLTRB(5, 10, 0, 10),
                          child: TextField(
                            controller: textEditingController,
                            cursorColor:Color(0xFF464EB5),
                            maxLines: null,
                            maxLength: 200,
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              hintText: "回复",
                              hintStyle: TextStyle(
                                  color: Color(0xFFADB3BA),
                                  fontSize:15
                              ),
                           ),
                          ),
                      ),
                            // Container(
                            //   margin: EdgeInsets.fromLTRB(5, 10, 0, 10),
                            //   constraints: const BoxConstraints(
                            //     maxHeight: 100.0,
                            //     minHeight: 50.0,
                            //   ),
                            //   decoration: const BoxDecoration(
                            //       color:  Color(0xFFF5F6FF),
                            //       borderRadius: BorderRadius.all(Radius.circular(2))
                            //   ),
                            //   child: TextField(
                            //     controller: textEditingController,
                            //     cursorColor:Color(0xFF464EB5),
                            //     maxLines: null,
                            //     maxLength: 200,
                            //     decoration: const InputDecoration(
                            //       counterText: '',
                            //       border: InputBorder.none,
                            //       contentPadding: EdgeInsets.only(
                            //           left: 16.0, right: 16.0, top: 10.0, bottom:10.0),
                            //       hintText: "回复",
                            //       hintStyle: TextStyle(
                            //           color: Color(0xFFADB3BA),
                            //           fontSize:15
                            //       ),
                            //    ),
                            //     style: const TextStyle(
                            //         color: Color(0xFF03073C),
                            //         fontSize:15
                            //     ),
                            //   ),
                            // ),
                    ),
                    if(!isRecording)
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.photo),
                              color: Color(0xFF838CFF),
                              iconSize: 30, // 调整图标大小
                              onPressed: () {
                                addPicture();
                              },
                            ),
                          ],
                        ),
                      ),
                      if(!isRecording)
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.videocam),
                              color: Color(0xFF838CFF),
                              iconSize: 30, // 调整图标大小
                              onPressed: () {
                                // TODO: 添加按钮点击后的操作
                                addVideo();
                              },
                            ),
                          ],
                        ),
                      ),
                    if(!isRecording)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.send),
                                color: Color(0xFF838CFF),
                                iconSize: 26, // 调整图标大小
                                onPressed: () {
                                  sendTxt();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    if(isRecording)
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.restart_alt),
                              color: Color(0xFF838CFF),
                              iconSize: 30, // 调整图标大小
                              onPressed: () {
                                // TODO: 重新录制
                                _refreshWave();
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
              )
            ),
          ],
        ),
      ),
    );
  }
}


class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
            color: Colors.black26,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
                semanticLabel: 'Play',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
