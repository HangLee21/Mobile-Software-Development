import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? sharedPreferences;
  static void init()async{
    sharedPreferences ??= await SharedPreferences.getInstance();
  }
  static String? getString(String string){
    init();
    return sharedPreferences?.getString(string);
  }
  static void setString(String key,String value){
    init();
    sharedPreferences?.setString(key, value);
  }
}