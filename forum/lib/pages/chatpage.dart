import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/message.dart';
import '../classes/notification_card.dart';
import '../constants.dart';
import '../storage/notificationInfo_storage.dart';
import '../url/websocket_service.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
// TODO add websocket listener
class ChatPage extends StatefulWidget{
  final String userId;
  // TODO change self id
  String selfId = "test23456";
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

  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  late Directory appDirectory;

  void _initLocalStorage()async{

  }
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    _initLocalStorage();
    // get chat history
    initData();
    // listen to websocket
    initWebSocket();
    _initialiseControllers();
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      musicFile = result.files.single.path;
      setState(() {});
    } else {
      debugPrint("File not picked");
    }
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
    _controller.dispose();
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
    _websocketService.stream?.listen((message) async {
      setState(() {
        Message message1 = Message.fromString(message);
        // 截取日期和时间部分
        String datePart = message1.time.substring(0, 10);
        String timePart = message1.time.substring(11, 19);

        // 格式化时间
        String formattedTime = '$datePart $timePart';
        messages.insert(0, {
          'name': message1.senderId,
          'content': message1.content,
          'me?': false,
          'createdAt': formattedTime,
          'status': 1,
          'show': true
        });

        if(messages.length > 1){
          DateTime current = DateTime.parse(formatTime(messages[0]['createdAt']));
          DateTime previous = DateTime.parse(formatTime(messages[1]['createdAt']));
          Duration difference = current.difference(previous);
          if (difference.inMinutes <= 5) {
            messages[0]['show'] = false;
          }
        }
      });
    });
  }

  initData() async {
    print(LocalStorage.getString('token'));
    requestGet("/api/chat/get_all_messages", {
        'Content-Type': 'application/json',
        'Authorization': LocalStorage.getString('token') ?? ''
      },query:  {
      "userId": widget.selfId,
      "anotherId": widget.userId
    }).then((response) {
      setState(() {
        print(response.statusCode);
        if (response.statusCode == 200) {
          String decodedString = utf8.decode(response.bodyBytes);
          Map body = jsonDecode(decodedString) as Map;

          for(var item in body['messages']){
            // 截取日期和时间部分
            String datePart = item['time'].substring(0, 10);
            String timePart = item['time'].substring(11, 19);

            // 格式化时间
            String formattedTime = '$datePart $timePart';
            messages.insert(0, {
              'name': item['senderId'],
              'content': item['content'],
              'createdAt': formattedTime,
              'me?': item['senderId'] == widget.selfId,
              'status': 1,
              'show': true
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

  Widget _renderRowSendByOthers(BuildContext context, item) {
    // 定义正则表达式模式
    RegExp regex = RegExp(r'\((\w+)\)\[(\w+)\]');
    String type = '';
    String url = '';
    // 进行匹配
    Match? match = regex.firstMatch(item['content']);

    // 检查是否匹配成功
    if (match != null) {
      // 输出第一个括号内的内容（第一个单词）
      print('第一个单词: ${match.group(1)}');
      // 输出第二个括号内的内容（第二个单词）
      print('第二个单词: ${match.group(2)}');
      type = match.group(1).toString();
      url = match.group(2).toString();
      if(type != picType && type != videoType && type != audioType){
        type = '';
      }

      if(type == videoType){
        _controller = VideoPlayerController.networkUrl(Uri.parse(
          // TODO change url
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
      }
      else if(type == audioType){
        recorderController = RecorderController();
      }
    } else {
      // 如果没有匹配成功
      print('没有找到匹配的模式');
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
                                  if (type == picType)
                                    Image.network(
                                      url,
                                      width: 200,
                                      height: 200,
                                    ),
                                  if (type == videoType)
                                    Container(
                                      child: AspectRatio(
                                        aspectRatio: _controller.value.aspectRatio,
                                        child: VideoPlayer(_controller),
                                      ),
                                    ),
                                  if (type == audioType)
                                    // TODO add audio player
                                    Container(),
                                  if (type == '')
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
    RegExp regex = RegExp(r'\((\w+)\)\[(\w+)\]');
    String type = '';
    String url = '';
    // 进行匹配
    Match? match = regex.firstMatch(item['content']);

    // 检查是否匹配成功
    if (match != null) {
      // 输出第一个括号内的内容（第一个单词）
      print('第一个单词: ${match.group(1)}');
      // 输出第二个括号内的内容（第二个单词）
      print('第二个单词: ${match.group(2)}');
      type = match.group(1).toString();
      url = match.group(2).toString();
      if(type != picType && type != videoType && type != audioType){
        type = '';
      }

      if(type == videoType){
        _controller = VideoPlayerController.networkUrl(Uri.parse(
          // TODO change url
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
      }
      else if(type == audioType){
        recorderController = RecorderController();
      }
    } else {
      // 如果没有匹配成功
      print('没有找到匹配的模式');
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
                      Row(
                        textDirection: TextDirection.rtl,
                        children: <Widget>[
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
                                  if (type == picType)
                                    Image.network(
                                      url,
                                      width: 200,
                                      height: 200,
                                    ),
                                  if (type == videoType)
                                    Container(
                                      child: AspectRatio(
                                        aspectRatio: _controller.value.aspectRatio,
                                        child: VideoPlayer(_controller),
                                      ),
                                    ),
                                  if (type == audioType)
                                  // TODO add audio player
                                    Container(),
                                  if (type == '')
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
      // TODO change token
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': LocalStorage.getString('token') ?? '',
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
        _websocketService.sendMessage("SINGLE_SENDING:${widget.selfId}:${widget.userId}:($picType)[${url}]").then((value) {
          addMessage(url, 'image');
        });
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
      // TODO change token
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': LocalStorage.getString('token') ?? '',
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
        _websocketService.sendMessage("SINGLE_SENDING:${widget.selfId}:${widget.userId}:($videoType)[${url}]").then((value) {
          addMessage(url, 'video');
        });
      }
    }
  }

  addMessage(content, tag) {
    // 获取当前时间
    DateTime now = DateTime.now();

    // 将时间格式化为字符串，精确到秒
    String formattedTime = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
    setState(() {
      messages.insert(0, {
        'name': widget.selfId,'content': 'content','me?': true,'createdAt': formattedTime
      });
    });
    Timer(
        Duration(milliseconds: 100),
            () => _scrollController.jumpTo(0));
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
        title: const Text('friend'),
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isRecording
                    ? AudioWaveforms(
                  enableGesture: true,
                  size: Size(
                      MediaQuery.of(context).size.width / 2,
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
                  margin: const EdgeInsets.symmetric(
                      horizontal: 15),
                )
                  : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        // TODO start record
                        _startOrStopRecording();
                      },
                      onLongPress: (){
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              color: Color(0xFF838CFF),
                              iconSize: 30, // 调整图标大小
                              onPressed: () {
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child:Container(
                        margin: EdgeInsets.fromLTRB(5, 10, 0, 10),
                        constraints: const BoxConstraints(
                          maxHeight: 100.0,
                          minHeight: 50.0,
                        ),
                        decoration: const BoxDecoration(
                            color:  Color(0xFFF5F6FF),
                            borderRadius: BorderRadius.all(Radius.circular(2))
                        ),
                        child: TextField(
                          controller: textEditingController,
                          cursorColor:Color(0xFF464EB5),
                          maxLines: null,
                          maxLength: 200,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 10.0, bottom:10.0),
                            hintText: "回复",
                            hintStyle: TextStyle(
                                color: Color(0xFFADB3BA),
                                fontSize:15
                            ),
                          ),
                          style: const TextStyle(
                              color: Color(0xFF03073C),
                              fontSize:15
                          ),
                        ),
                      ),
                    ),
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
                              // TODO: 添加按钮点击后的操作
                              addPicture();
                            },
                          ),
                        ],
                      ),
                    ),
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
                  ],
                )

              )
            ),
          ],
        ),
      ),
    );
  }
}
