import 'package:flutter/material.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/pages/navigation.dart';
import 'package:forum/theme/theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
/// Flutter code sample for [NavigationBar].

void main() => runApp(ForumApp());

class ForumApp extends StatefulWidget{
  const ForumApp({super.key});

  @override
  _ForumAppState createState() => _ForumAppState();
}

class _ForumAppState extends State<ForumApp> {

  bool logined = true;

  @override
  void initState(){
    super.initState();
    init();


  }

  void init()async{
    await LocalStorage.init();
    print('name:${LocalStorage.getString('userName')}');
    if (LocalStorage.getString('token') != '' && LocalStorage.getString('token') != null){
      logined = true;
    }else{
      logined = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: FlutterThemeData.lightThemeData,
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: Colors.blue,
          //启用
          useMaterial3: true,
        ),
      home: !logined?LoginLayout():const NavigationExample(),
      builder:EasyLoading.init(),
    );
  }
}

