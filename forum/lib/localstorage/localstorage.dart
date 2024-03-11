// 导入依赖
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储工具类
class LocalStorage {

  /// 设置布尔的值
  static setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// 设置int的值
  static setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// 设置Sting的值
  static setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// 设置StringList
  static setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  static get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  /// 移除单个
  static remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// 清空所有
  static clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}