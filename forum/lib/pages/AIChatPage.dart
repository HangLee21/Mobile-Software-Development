import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:forum/pages/personspace.dart';

import 'package:http/http.dart' as http;
import '../classes/localStorage.dart';
import '../constants.dart';
import '../url/user.dart';

class AIChatPage extends StatefulWidget{
  final String userId;
  late String selfId;
  AIChatPage({super.key, required this.userId});

  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage>{
  List<Map> messages = [

  ];
  late int currentIndex = 0;
  late StreamController<String> _streamController;
  late String text = '';
  // String employeeNo;
  double contentMaxWidth = 500;
  late TextEditingController textEditingController;
  ScrollController _scrollController = ScrollController(); //listview的控制器
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    _initLocalStorage();
    initData();
    _streamController = StreamController<String>();
  }

  void _initLocalStorage()async{
    widget.selfId = LocalStorage.getString('userId')!;
    LocalStorage.setString('currentUserId', widget.userId);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  initData() async {
      messages.clear();
      requestGet("/api/chat/get_all_messages", {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
      },query:  {
        "userId": widget.selfId,
        "anotherId": widget.userId,
        'pageSize': 10,
        'pageIndex': currentIndex,
      }).then((response) {
        setState(() {
          print(response.statusCode);
          if (response.statusCode == 200) {
            String decodedString = utf8.decode(response.bodyBytes);
            Map body = jsonDecode(decodedString) as Map;

            Map tmp = {
              'name': LocalStorage.getString('userName') ?? '',
              'content': '',
              'createdAt': '',
              'me?': true,
              'status': 1,
            };
            for(var item in body['messages']){
              // 截取日期和时间部分
              String datePart = item['time'].substring(0, 10);
              String timePart = item['time'].substring(11, 19);

              // 格式化时间
              String formattedTime = '$datePart $timePart';

              if(item['senderId'] == widget.userId){
                messages.add({
                  'name': 'AI助手',
                  'content': item['content'],
                  'createdAt': formattedTime,
                  'me?': false,
                  'status': 1,
                });
                messages.add(tmp);
              }
              else{
                tmp = {
                  'name': LocalStorage.getString('userName') ?? '',
                  'content': item['content'],
                  'createdAt': formattedTime,
                  'me?': true,
                  'status': 1,
                };
              }
            }
          }
        });
        print('end');
      });
  }

  _renderList() {
    return GestureDetector(
      child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 27),
        itemBuilder: (context, index) {
          var item = messages[index];
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
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        children: <Widget>[
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
                  child: GestureDetector(
                    onTap: (){

                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage('https://android-1324918669.cos.ap-beijing.myqcloud.com/AI_avatar.png'),
                      radius: 20,
                    ),
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
                            child: SelectableText(
                              item['content'],
                              style: TextStyle(
                                color: Color(0xFF03073C),
                                fontSize: 15,
                              ),
                            ),
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
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        children: <Widget>[
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
                child: GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PersonalSpace(LocalStorage.getString('userId') ?? '')));
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(LocalStorage.getString('userAvatar') ?? ''),
                    radius: 20,
                  ),
                )
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
                              child: SelectableText(
                                item['content'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
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

  final random = Random();

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  String formatTime(String time){
    String formatted = '$time.000';
    return formatted;
  }

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
        'name': LocalStorage.getString('userName')??'',
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
    text = '';
    var client = http.Client();
    var url = Uri.parse('http://$BASEURL/api/ai/chat?userId=${widget.selfId}&content=${content}');
    var requestBody = jsonEncode({
      'userId': LocalStorage.getString('userId')??'',
      'content': 'hello'
    });

    var request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = requestBody;


    request.headers.addAll({
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? '',
    });

    var response = await client.send(request);

    if(response.statusCode == 200){
      setState(() {
        messages[0]['status'] = SUCCESSED_TYPE;
        messages.insert(0, {
          'name': 'AI助手',
          'content': text,
          'me?': false,
          'createdAt': formattedTime,
          'status': SENDING_TYPE,
          'show': false
        });
      });

      response.stream
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((data) {
        if(data.isNotEmpty){
          text += data.trim().substring(5);
          setState(() {
            messages[0]['content'] = text;
          });
        }
        _streamController.add(data);
      }, onError: (error) {
        _streamController.addError(error);
      }, onDone: () {
        _streamController.close();
      });
    }
  }

  void clearHistory(){
    requestDelete("/api/ai/clear", {

    },{
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? '',
    },query: {
      'userId': LocalStorage.getString('userId')
    }).then((http.Response res) => {
      if(res.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              duration: Duration(seconds: 1),
              content: Text('上下文已清除'),
              backgroundColor: Color(0xFF838CFF),
          ),
        )
      }
    });
  }

  Future<void> expandMessages() async {
    await Future.delayed(Duration(milliseconds: 100),(){
      requestGet("/api/chat/get_all_messages", {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
      },query:  {
        "userId": widget.selfId,
        "anotherId": widget.userId,
        'pageIndex':currentIndex + 1,
        'pageSize': 10,
      }).then((response) {
        if (response.statusCode == 200) {
          String decodedString = utf8.decode(response.bodyBytes);
          Map body = jsonDecode(decodedString) as Map;

          for(var item in body['messages']){
            // 截取日期和时间部分
            String datePart = item['time'].substring(0, 10);
            String timePart = item['time'].substring(11, 19);

            // 格式化时间
            String formattedTime = '$datePart $timePart';
            setState(() {
              messages.add({
                'name': item['senderId'] == widget.userId ? 'AI助手' : LocalStorage.getString('userName'),
                'content': item['content'],
                'createdAt': formattedTime,
                'me?': item['senderId'] == widget.selfId,
                'status': 1,
                'show': true
              });
            });
          }
          currentIndex += 1;
        }
      });
    });
  }


  static int SENDING_TYPE = 0;
  static int FAILED_TYPE = 1;
  static int SUCCESSED_TYPE = 2;

  @override
  Widget build(BuildContext context){
    contentMaxWidth = MediaQuery.of(context).size.width - 90;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI聊天助手'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFF1F5FB),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: CustomMaterialIndicator(
                trigger: IndicatorTrigger.trailingEdge,
                onRefresh: expandMessages,
                indicatorBuilder: (BuildContext context, IndicatorController controller) {
                  return Icon(
                    Icons.refresh,
                    color: Colors.blue,
                    size: 30,
                  );
                },
                child: Container(
                  //列表内容少的时候靠上
                  alignment: Alignment.topCenter,
                  child: _renderList(),
                ),
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
                  Expanded(
                    child:Container(
                      margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
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
                          icon: const Icon(Icons.cleaning_services),
                          color: Color(0xFF838CFF),
                          iconSize: 30, // 调整图标大小
                          onPressed: () {
                            clearHistory();
                          },
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.center,
                      height: 70,
                      child: const Text(
                        '发送',
                        style: TextStyle(
                          color: Color(0xFF464EB5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    onTap: () {
                      sendTxt();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

