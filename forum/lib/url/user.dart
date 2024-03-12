import 'dart:convert';
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

Future<http.Response> requestGet(pathname,headers) async{
  var res = await http.get(Uri.parse(BASEURL+pathname), headers: headers);
  return res;
}

Future<http.Response> requestPost( pathname,Map<String, String> body, Map<String, String> headers) async{
  var res = await http.post(Uri.parse(BASEURL+pathname),body: json.encode(body), headers: headers);
  return res;
}