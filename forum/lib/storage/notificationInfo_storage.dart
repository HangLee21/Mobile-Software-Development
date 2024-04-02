import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/notification_card.dart';

class NotificationStorage {

  Future<void> saveNotifications(Map<String, NotificationInfo> notifications) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> serializedNotifications = {};
    notifications.forEach((key, value) {
      serializedNotifications[key] = value.toJson();
    });
    await _prefs.setString('notifications', jsonEncode(serializedNotifications));
  }

  Future<void> saveNotification(NotificationInfo notification) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Map<String, NotificationInfo> serializedNotifications = await loadNotifications();
    serializedNotifications[notification.friendId] = notification;
    print("save");
    print(serializedNotifications);
    await _prefs.setString('notifications', jsonEncode(serializedNotifications));
  }

  Future<Map<String, NotificationInfo>> loadNotifications() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? notificationsJson = _prefs.getString('notifications');
    print("read");
    print(notificationsJson);
    if (notificationsJson != null) {
      Map<String, dynamic> serializedNotifications = jsonDecode(notificationsJson);
      Map<String, NotificationInfo> notifications = {};
      serializedNotifications.forEach((key, value) {
        notifications[key] = NotificationInfo.fromJson(value);
      });
      return notifications;
    } else {
      return {};
    }
  }
}
