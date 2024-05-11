import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? sharedPreferences;
  static Future<void> init() async {
    print('init start');
    if (sharedPreferences == null) {
      print('sharedPreferences is null, initializing...');
      sharedPreferences = await SharedPreferences.getInstance();
      if (sharedPreferences == null) {
        print('sharedPreferences initialization failed');
      } else {
        print('sharedPreferences initialization successful');
      }
    } else {
      print('sharedPreferences is already initialized');
    }
  }
  static String? getString(String string){
    if (sharedPreferences == null) {
      init();
    }
    return sharedPreferences?.getString(string);
  }
  static void setString(String key,String value){
    if (sharedPreferences == null) {
      init();
    }
    sharedPreferences?.setString(key, value);
  }

  static void remove(String key){
    if (sharedPreferences == null) {
      init();
    }
    sharedPreferences?.remove(key);
  }
}