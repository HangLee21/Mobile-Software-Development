import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/pages/navigation.dart';
import 'package:forum/pages/postpage.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:better_player/better_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../constants.dart';
import 'AIChatPage.dart';

class WorkField extends StatefulWidget{
  final String postId;
  WorkField(this.postId,{super.key});

  @override
  _WorkFieldState createState() => _WorkFieldState();
}

class _WorkFieldState extends State<WorkField>{
  String title = '';
  String content = '';
  int materialCount = 0;
  String postId = '';
  List materials = [];
  List<Widget> materialbox = [];
  @override
  void initState(){
    super.initState();
    postId = widget.postId;
    materialCount = materials.length + 1;
    if(postId == '') {
      _initPostId();
    }else{
      _initDraft();
    }
    materialbox = List.generate(
      materialCount,
          (index) => _buildMaterialBox(index),
    );
  }

  void _initPostId() async{
    if(postId == ''){
      requestGet('/api/cos/get_draftId', {
        'Authorization': 'Bearer ${LocalStorage.getString('token')}',
      },query:{
        'userId': LocalStorage.getString('userId')
      }).then((http.Response res){
        if(res.statusCode == 200){
          Map body = json.decode(res.body);
          setState(() {
            postId = body['content'];
            print('postId:$postId');
          });
        }
      });
    }
  }

  void _initDraft()async{
    requestGet('/api/cos/post/query_draft',{
      'Authorization': 'Bearer ${LocalStorage.getString('token')}',
    },query: {
      'postId': widget.postId
    }).then((http.Response res){
      print(res.statusCode);
      if(res.statusCode == 200){
        String decodedString1 = utf8.decode(res.bodyBytes);
        print('posts:${json.decode(decodedString1)['posts']}');
        Map post = json.decode(decodedString1)['posts'][0];
        setState(() {
          title = post['title'];
          content = post['content'];
          materials = post['urls'];
          print(materials);
          materialCount = materials.length + 1;
          materialbox = List.generate(
            materialCount,
                (index) => _buildMaterialBox(index),
          );
        });
      }
    });
  }

  void _addMaterial() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.media);
    EasyLoading.show(status: '上传中...');
    if (result != null) {
      print('yes');
      File file = File(result.files.single.path!);
      var uri = Uri.parse('http://$BASEURL/api/cos/upload_post_material');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer ${LocalStorage.getString('token')}',
      });
      request.fields.addAll({
        'userId': LocalStorage.getString('userId') ?? '',
        'postId': postId
      });

      var response = await request.send();
      print("code:${response.statusCode}");
      if(response.statusCode == 200){

        var responseBody = await response.stream.bytesToString();
        LocalStorage.setString('token', json.decode(responseBody)['token']);
        String url = json.decode(responseBody)['content'];
        print('url:$url');
        setState(() {
          materials = [...materials, url];
          materialCount = materials.length + 1;
          materialbox = List.generate(
            materialCount,
                (index) => _buildMaterialBox(index),
          );
        });
      }
    }
    EasyLoading.dismiss();
  }

  void _deleteImage(int index) async{
    //TODO delete

    String url = materials[index];
    List<String> parts = url.split('/');
    String filename = parts.last;
    requestDelete(
      '/api/cos/delete_post_material',
      {

      },
      {
        'Authorization':'Bearer ${LocalStorage.getString('token')}'
      },
      query: {
        'userId':LocalStorage.getString('userId'),
        'postId': postId,
        'filename': filename
      }
    ).then((http.Response res){
      if(res.statusCode == 200){
        print('delete');
        LocalStorage.setString('token', json.decode(res.body)['token']);
        setState(() {
          materials.removeAt(index);
          materialCount = materials.length + 1;
          materialbox = List.generate(
            materialCount,
                (index) => _buildMaterialBox(index),
          );
        });
      }
    });
  }

  void showMaterial(int index){
    //TODO 添加图片dialog
    showDialog(
      context: context,
      builder: (context){
        if(materials[index].split('.')[materials[index].split('.').length - 1] == 'png' || materials[index].split('.')[materials[index].split('.').length - 1] == 'jpg' || materials[index].split('.')[materials[index].split('.').length - 1] == 'jpeg'){
          return Image.network(materials[index]);
        }else{
          return BetterPlayer.network(
              materials[index],
              betterPlayerConfiguration: BetterPlayerConfiguration(
                autoPlay: true
              )
          );
        }
      }
    );
  }

  Future<Uint8List?> getThumbnail(String videoUrl) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 80,
      maxHeight: 80,
      quality: 25,
    );
    return uint8list;
  }

  Widget _buildMaterialBox(int index) {
    // 这里可以根据实际情况构建你的图片方块
    if(index < materialCount - 1) {
      return Stack(
          children: [
            GestureDetector(
              onTap: (){
                showMaterial(index);
              },
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child:
                      materials[index].split('.')[materials[index].split('.').length - 1] == 'png' || materials[index].split('.')[materials[index].split('.').length - 1] == 'jpg'?
                      Image.network(
                          materials[index],
                          width: 80,
                          height: 80
                      )
                          :FutureBuilder<Uint8List?>(
                        future: getThumbnail(materials[index]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator(); // 正在加载
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // 发生错误
                          } else if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(
                                snapshot.data!,
                                width: 80,
                                height: 80,
                            ); // 显示缩略图
                          } else {
                            return Text('No Thumbnail Available'); // 没有缩略图
                          }
                        },
                      ),

                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  _deleteImage(index);
                },
                child: materials[index] == null
                    ? Container()
                    : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[500],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
            if (materials[index].split('.')[materials[index].split('.').length - 1] != 'png' && materials[index].split('.')[materials[index].split('.').length - 1] != 'jpg')
              Positioned(
                top: 15,
                right: 15,
                child:  GestureDetector(
                  onTap: (){
                    showMaterial(index);
                  },
                  child: Icon(
                  Icons.play_circle_outline_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                )


              ),
          ]
        );
    }else{
      return GestureDetector(
          onTap: _addMaterial,
          child: Container(
            width: 80,
            height: 80,
            child: const Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              margin: EdgeInsets.all(0),
              child: Icon(Icons.add),
            ),
          )
      );
    }
  }

  void sendPost(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('发布'),
        content: Text('您确定要发布吗'),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.pop(context, "取消");
              },
              child: Text('取消')
          ),
          TextButton(
              onPressed: (){
                send();
              },
              child: Text('确定')
          ),
        ],
      );
    });
  }

  void send()async{
    EasyLoading.show(status: '正在发布...');
    if(title != '' && content != ''){
      requestPost(
          '/api/cos/post',
          {
            'title': title,
            'userId': LocalStorage.getString('userId'),
            'content': content,
            'draftId': postId
          },
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${LocalStorage.getString('token')}'
          }
        ).then((http.Response res){
          if(res.statusCode == 200){
            Navigator.of(context).pop();
            EasyLoading.showSuccess('发布成功');
            String _postId = json.decode(res.body)['content'];
            Future.delayed(Duration(seconds: 1),(){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostPage(_postId)));
            });
          }else{
            Navigator.of(context).pop();
            EasyLoading.showError('发布失败');
          }
        }
      );
    }
    else{
      Navigator.of(context).pop();
      EasyLoading.showError('请输入标题和内容');
    }
  }
  
  void deletePost(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('删除'),
        content: Text('您确定要删除吗'),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.pop(context, "取消");
              },
              child: Text('取消')
          ),
          TextButton(
              onPressed: (){
                delete();
              },
              child: Text('确定')
          ),
        ],
      );
    });
  }
  
  void delete()async{
    EasyLoading.show(status: '删除中');
    requestDelete(
        '/api/cos/delete_draft',
        {
          'userId':LocalStorage.getString('userId'),
          'postId': postId
        },
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.getString('token')}'
        }
    ).then((http.Response res){
        if(res.statusCode == 200){
          EasyLoading.showSuccess('删除成功');
          Navigator.of(context).pop();
          Future.delayed(Duration(seconds: 1),(){

            Navigator.of(context).push(MaterialPageRoute(builder: (context) => NavigationExample()));
          });
        }else{
          EasyLoading.showError('删除失败');
          Navigator.of(context).pop();
        }
    });
  }

  void save()async{
    EasyLoading.show(status: '保存中...');
    requestPost(
        '/api/cos/upload_draft',
        {
          'title': title,
          'userId': LocalStorage.getString('userId'),
          'content': content,
          'postId': postId
        },
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.getString('token')}'
        }
    ).then((http.Response res){
        if(res.statusCode == 200){
          EasyLoading.showSuccess('保存成功');
        }else{
          EasyLoading.showSuccess('保存失败');
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创作'),
        actions: [
          IconButton(
            icon:Icon(Icons.save_as_outlined),
            onPressed: () {
              save();
            },
            tooltip: '保存',
          ),
          IconButton(
            icon:Icon(Icons.delete_outline),
            onPressed: () {
              deletePost();
            },
            tooltip: '删除',
          ),
          IconButton(
            icon:Icon(Icons.send),
            onPressed: () {
              sendPost();
            },
            tooltip: '发送',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(10.0,0.0,10.0,0),
              child: Wrap(
                spacing: 8.0, // 水平方向子组件之间的间距
                runSpacing: 8.0, // 垂直方向子组件之间的间距
                alignment: WrapAlignment.start,
                children: materialbox
              ),
          ),

          TextField(
            onChanged: (str){
                title = str;
            },
            controller: TextEditingController(text: title),
            // cursorColor:Color(0xFF464EB5),
            maxLines: null,
            maxLength: 50,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 10.0, bottom:10.0),
              hintText: "标题（建议不超过15字）",
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
          const Divider(height: 10,),
          Expanded(child: TextField(
            onChanged: (str){
              content = str;
            },
            controller: TextEditingController(text: content),
            // cursorColor:Color(0xFF464EB5),
            maxLines: null,
            // maxLength: 200,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 10.0, bottom:10.0),
              hintText: "分享你的动态",
              hintStyle: TextStyle(
                  color: Color(0xFFADB3BA),
                  fontSize:15
              ),
            ),
            style: const TextStyle(
                color: Color(0xFF03073C),
                fontSize:15
            ),
          ),)

        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.question_answer_outlined),
        ///点击响应事
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AIChatPage(userId: 'ai_assistant',)));
        },
        ///长按提示
        tooltip: "AI助手",
        ///设置悬浮按钮的背景
        heroTag: 'other',
      ),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(),
    );
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // 计算屏幕宽度和高度
    double scaffoldWidth = scaffoldGeometry.scaffoldSize.width;
    double scaffoldHeight = scaffoldGeometry.scaffoldSize.height;

    // 计算按钮的水平位置（右侧）
    double fabX = scaffoldWidth - scaffoldGeometry.minInsets.right - kFloatingActionButtonMargin - scaffoldGeometry.floatingActionButtonSize.width ;

    // 计算按钮的垂直位置（屏幕中间）
    double fabY = scaffoldHeight / 2 - scaffoldGeometry.floatingActionButtonSize.height / 2;

    return Offset(fabX, fabY);
  }
}