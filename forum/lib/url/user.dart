import 'dart:convert';
import 'dart:io';
import 'package:forum/classes/localStorage.dart';

import '../constants.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

// class User{
//   String? username;
//   String? userid;
//   String? email;
//   String? avatar;
//   User({this.username,this.userid,this.email,this.avatar});
//   factory User.fromJson(Map<String, dynamic> json) {
//     return switch (json) {
//       {
//        'username': String username,
//        'userid': String userid,
//         'userEmail': String email,
//         'userAvatar': String avatar,
//       } => User(
//             username: username,
//             userid: userid,
//             email: email,
//             avatar: avatar,
//           ),
//       _ => throw const FormatException('Failed to load user.'),
//     };
//   }
// }

Future<http.Response> requestGet(pathname,Map<String, String> headers,{query}) async{
  query ??= {};
  String url = 'http://'+BASEURL+pathname;
  if( headers['Authorization'] != null){
    var checkToken = await http.get(Uri.parse('http://$BASEURL/api/user/check_token_valid?${LocalStorage.getString('token')}'), headers:{});
    if (checkToken.statusCode == 200){
      String decodedString = utf8.decode(checkToken.bodyBytes);
      Map body = jsonDecode(decodedString);
      if(!body['result']){
        LocalStorage.setString('token', body['token']);
        headers['Authorization'] = 'Bearer ${body['token']}';
      }
    }
  }



  if(query != {}){
    url += '?';
    query.forEach((key,value){
      url += '$key=$value&';
    });
  }

  var res = await http.get(Uri.parse(url), headers: headers, );
  return res;
}

Future<http.Response> requestPost( pathname,Map body, Map<String, String> headers,{query}) async{
  query ??= {};
  String url = 'http://'+BASEURL+pathname;
  if( headers['Authorization'] != null){
    var checkToken = await http.get(Uri.parse('http://$BASEURL/api/user/check_token_valid?${LocalStorage.getString('token')}'), headers:{});
    if (checkToken.statusCode == 200){
      String decodedString = utf8.decode(checkToken.bodyBytes);
      Map body = jsonDecode(decodedString);
      if(!body['result']){
        LocalStorage.setString('token', body['token']);
        headers['Authorization'] = 'Bearer ${body['token']}';
      }
    }
  }
  if(query != {}){
    url += '?';
    query.forEach((key,value){
      url += '$key=$value&';
    });
  }
  var res = await http.post(Uri.parse(url),body: json.encode(body), headers: headers);
  return res;
}

Future<http.Response> requestDelete( pathname,Map body, Map<String, String> headers,{query}) async{
  query ??= {};
  String url = 'http://'+BASEURL+pathname;
  if( headers['Authorization'] != null){
    var checkToken = await http.get(Uri.parse('http://$BASEURL/api/user/check_token_valid?${LocalStorage.getString('token')}'), headers:{});
    if (checkToken.statusCode == 200){
      String decodedString = utf8.decode(checkToken.bodyBytes);
      Map body = jsonDecode(decodedString);
      if(!body['result']){
        LocalStorage.setString('token', body['token']);
        headers['Authorization'] = 'Bearer ${body['token']}';
      }
    }
  }
  if(query != {}){
    url += '?';
    query.forEach((key,value){
      url += '$key=$value&';
    });
  }
  var res = await http.delete(Uri.parse(url),body: json.encode(body), headers: headers);
  return res;
}

Future<void> downloadFile(String url, String savePath) async {
  try {
    // 发起 HTTP GET 请求获取文件内容
    final response = await http.get(Uri.parse(url));

    // 将文件内容写入到文件中
    final file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);

  } catch (e) {
    // 捕获异常，打印错误信息
    print('Error downloading file: $e');
  }
}

bool checkFileExists(String filePath) {
  File file = File(filePath);
  bool exists = file.existsSync();
  return exists;
}