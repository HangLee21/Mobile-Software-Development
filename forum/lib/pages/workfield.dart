import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forum/pages/navigation.dart';
import 'package:forum/pages/postpage.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:better_player/better_player.dart';

import '../constants.dart';

class WorkField extends StatefulWidget{
  final String title;
  final String content;
  final List materials;
  WorkField(this.title, this.content, this.materials,{super.key});

  @override
  _WorkFieldState createState() => _WorkFieldState();
}

class _WorkFieldState extends State<WorkField>{
  String title = '';
  String content = '';
  int materialCount = 5;
  String postId = '';
  List materials = [];
  SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    title = widget.title;
    content = widget.content;
    materials = widget.materials;
    materialCount = materials.length + 1;
    _initLocalStorage();
    _initPostId();
  }

  void _initLocalStorage()async{
    sharedPreferences = await SharedPreferences.getInstance();
  }

  void _initPostId() async{
    if(postId == ''){

    }
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
        'Authorization': sharedPreferences?.getString('token') ?? '',
      });
      request.fields.addAll({
        'userId': sharedPreferences?.getString('userId') ?? '',
      });

      var response = await request.send();
      if(response.statusCode == 200){
        print("addMaterial");
        var responseBody = await response.stream.bytesToString();
        sharedPreferences?.setString('token', json.decode(responseBody)['token']);
        String url = json.decode(responseBody)['content'];
        setState(() {
          materials = [...materials, url];
          materialCount = materials.length + 1;
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
        'Authorization':'Bearer ${sharedPreferences?.getString('token')}'
      },
      query: {
        'userId':sharedPreferences?.getString('userId'),
        'postId': postId,
        'filename': filename
      }
    ).then((http.Response res){
      if(res.statusCode == 200){
        print('delete');
        sharedPreferences?.setString('token', json.decode(res.body)['token']);
        setState(() {
          materials.removeAt(index);
          materialCount = materials.length + 1;
        });
      }
    });
  }

  void showMaterial(){
    //TODO 添加图片dialog
    showDialog(context: context, builder: (context){
      return BetterPlayer.network('https://prod-streaming-video-msn-com.akamaized.net/a8c412fa-f696-4ff2-9c76-e8ed9cdffe0f/604a87fc-e7bc-463e-8d56-cde7e661d690.mp4');
    });
  }

  Widget _buildMaterialBox(int index) {
    // 这里可以根据实际情况构建你的图片方块
    print(materialCount);
    if(materials.length > 0) {
      print(materials[0]);
    }
    if(index < materialCount - 1) {
      return Stack(
          children: [
            GestureDetector(
              onTap: showMaterial,
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child:
                      // materials[index].split('.')[materials[index].split('.').length] == 'png' || materials[index].split('.')[materials[index].split('.').length] == 'jpg'?
                      // Image.network(
                      //     materials[index],
                      //     width: 80,
                      //     height: 80
                      // )
                      //     :Image.network(
                      //     materials[index],
                      //     width: 80,
                      //     height: 80
                      // )
                      Image.network(
                        materials[index],
                        width: 80,
                        height: 80
                      )
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
            )
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
          '/api/cos/upload_work',
          {
            'title': title,
            'userId': sharedPreferences?.getString('userId'),
            'content': content,
            'postId': postId
          },
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${sharedPreferences?.getString('token')}'
          }
        ).then((http.Response res){
          if(res.statusCode == 200){
            Navigator.of(context).pop();
            EasyLoading.showSuccess('发布成功');
            Future.delayed(Duration(seconds: 1),(){

              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostPage(postId)));
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
          'userId':sharedPreferences?.getString('userId'),
          'postId': postId
        },
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${sharedPreferences?.getString('token')}'
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
          'userId': sharedPreferences?.getString('userId'),
          'content': content,
          'postId': postId
        },
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${sharedPreferences?.getString('token')}'
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
                children: List.generate(
                  materialCount,
                  (index) => _buildMaterialBox(index),
                ),
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
    );
  }

}