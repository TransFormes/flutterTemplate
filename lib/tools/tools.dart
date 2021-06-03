// 全局工具类
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//提示信息
void toast(String str) {
  Fluttertoast.showToast(
      msg: str,
      timeInSecForIosWeb: 3,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black);
}

//loading
void loading(BuildContext context, [bool isClick = false]) {
  showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.transparent,
      barrierDismissible: isClick,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        );
      });
}

//获取网络
Future<bool> hasInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (ConnectivityResult.none == connectivityResult) {
    toast('暂无网络');
    return false;
  } else {
    return true;
  }
}
