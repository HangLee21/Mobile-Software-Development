import 'package:flutter/material.dart';
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

  bool logined = false;

  @override
  void initState(){
    super.initState();
    initLocalStorage().then((sharedPreferences){
      if(sharedPreferences.getString('token') != null){
        logined = true;
        setState(() {

        });
      }
    });


  }

  Future initLocalStorage()async{
    SharedPreferences? sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences;
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
      home: logined?LoginLayout():const NavigationExample(),
      builder:EasyLoading.init(),
    );
  }
}

