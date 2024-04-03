import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget{
  final String userId;
  ChatPage({super.key, required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>{
  List<Map> messages = [
    {'name': 'chl','content': 'content','me?': true,'createdAt': '2024-03-07 15:56','status': 1},
    {'name': 'chl','content': 'contentfdsfdsssss','me?': false,'createdAt': '2024-03-07 15:56','status': 1},
    {'name': 'chl','content': 'content','me?': true,'createdAt': '2024-03-07 15:56','status': 1},
    {'name': 'chl','content': 'contentfdsfdsssss','me?': false,'createdAt': '2024-03-07 15:56','status': 1},{'name': 'chl','content': 'content','me?': true,'createdAt': '2024-03-07 15:56','status': 1},
    {'name': 'chl','content': 'contentfdsfdsssss','me?': false,'createdAt': '2024-03-07 15:56','status': 1},
  ];
  // String employeeNo;
  double contentMaxWidth = 500;
  late TextEditingController textEditingController;
  ScrollController _scrollController = ScrollController(); //listview的控制器
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    initData();
  }

  initData() async {
    // employeeNo = await LocalStorage.get('employeeNo');
    // userId = await LocalStorage.get('userId');
    // userName = await LocalStorage.get('name');
    // String url =
    //     '${Address.getPrefix()}hbpay/overdue/urge/getOverdueUrgeReplyList';
    // var res = await httpManager.netFetch(url,
    //     queryParameters: {'orderNo': widget.orderNo},
    //     options: Options(method: 'post'),
    //     showLoadingForPost: false);
    // setState(() {
    //   if (res.data == null || res.data.length == 0) {
    //     return;
    //   }
    //   list = (res.data as List).reversed.toList();
    // });
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
                            child: Text(
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
                              child: Text(
                                item['content'],
                                softWrap: true,
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

  sendTxt() async {
    // int tag = random.nextInt(maxValue);
    // if (CommonUtils.isEmpty(textEditingController.value.text.trim())) {
    //   return;
    // }
    // String message = textEditingController.value.text;
    // addMessage(message, tag);
    // textEditingController.text = '';
    // String url = '${Address.getPrefix()}hbpay/overdue/urge/saveReply';
    // var res = await httpManager.netFetch(url,
    //     data: {
    //       'cusUid': userId,
    //       'orderNo': widget.orderNo,
    //       'employeeNo': employeeNo,
    //       'name': userName,
    //       'reply': message,
    //       'tag': '${tag}',
    //     },
    //     options: Options(method: 'post'),
    //     showLoadingForPost: false);
    //
    // int index = 0;
    // if (res.result) {
    //   for(int i = 0; index < list.length; i++) {
    //     if (list[i]['tag'] == res.data) {
    //       index = i;
    //       break;
    //     }
    //   }
    //   setState(() {
    //     list[index]['status'] = SUCCESSED_TYPE;
    //   });
    // } else {
    //   setState(() {
    //     list[index]['status'] = FAILED_TYPE;
    //   });
    // }
  }

  final random = Random();

  addMessage(content, tag) {
    int time = new DateTime.now().millisecondsSinceEpoch;
    setState(() {
      messages.insert(0, {
        'name': 'chl','content': 'content','me?': true,'createdAt': time
      });
    });
    Timer(
        Duration(milliseconds: 100),
            () => _scrollController.jumpTo(0));
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
