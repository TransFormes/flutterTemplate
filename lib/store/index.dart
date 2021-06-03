// 全局数据

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static SharedPreferences sharedPreferences;
  //根据用户类型来
  static String userInfo;

  static GlobalKey<NavigatorState> navigatorKey;

  static init() async {
    navigatorKey = GlobalKey<NavigatorState>();
    sharedPreferences = await SharedPreferences.getInstance();
    String user = sharedPreferences.getString('userInfo');
    if (user != null) {
      userInfo = user;
    }
  }
}
