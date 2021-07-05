import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertemplate/store/index.dart';
import './../api/index.dart';
import './tools.dart' show toast;

bool isLoginPage = false;
bool isSendLogin = false;

BaseOptions options = BaseOptions(
    baseUrl: API.baseUrl,
    connectTimeout: 100000,
    receiveTimeout: 5000,
    responseType: ResponseType.json,
    contentType: 'application/x-www-form-urlencoded');
Dio dio = Dio(options);
Dio getToken = Dio(options);

class Request {
  static Future get(String url,
      [Map<String, dynamic> data, bool isShowToast = true]) async {
    if (data != null && data.isNotEmpty) {
      StringBuffer options = StringBuffer('?');
      data.forEach((key, value) {
        options.write('$key=$value&');
      });
      String optionsStr = options.toString();
      optionsStr = optionsStr.substring(0, optionsStr.length - 1);
      url += optionsStr;
    }
    return await _sendRequest(url, 'get', {}, isShowToast);
  }

  static Future post(String url, Map<String, dynamic> data) async {
    return await _sendRequest(url, 'post', data);
  }

  static Future _sendRequest(String url, String method,
      [Map<String, dynamic> data, bool isShowToast = true]) async {
    Response response;
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options, hander) {
      options.headers['Cookie'] = Store.sharedPreferences.getString('cookie');
      return hander.next(options);
    }));
    try {
      if (method == 'get') {
        response = await dio.get(url);
      } else {
        response = await dio.post(url, data: data);
      }
    } on DioError catch (e) {
      response = e.response;
    }
    if (response?.statusCode != 200) {
      bool isReturn = true;
      for (int i = 0; i < 5; i++) {
        response = await dio.get(url);
        if (response?.statusCode == 200) {
          isReturn = false;
          break;
        }
      }
      if (isReturn) {
        toast('网络繁忙，请稍后重试');
        return;
      }
    }
    Map<String, dynamic> responseData = json.decode(response.data);
    //身份过期 锁住后面的请求 重新登录成功之后在请求 失败就取消
    if (responseData['code'] == 101) {
      if (isSendLogin) return;
      isSendLogin = true;
      dio.interceptors.requestLock.lock();
      String urls = url;
      final String token = Store.sharedPreferences.getString('token');
      String userInfo = Store.sharedPreferences.getString('userInfo');
      if (token != null && userInfo != null) {
        Map<String, dynamic> user = json.decode(userInfo);
        var res = await getToken.get(API.login,
            queryParameters: {"email": user['email'], "code": token});
        Map<String, dynamic> loginData = json.decode(res.data);
        if (loginData['code'] == 0) {
          Store.sharedPreferences.setString('token', loginData['data']);
          isSendLogin = false;
          setCookie(res);
          dio.interceptors.requestLock.unlock();
          response = await dio.get(urls);
          Map<String, dynamic> responseData = json.decode(response.data);
          return responseData['data'] ?? '';
        } else {
          dio.interceptors.requestLock.clear();
          if (!isLoginPage) {
            goLogin();
          }
        }
      } else {
        isSendLogin = false;
        if (!isLoginPage) {
          goLogin();
        }
      }
    } else if (responseData['code'] == 0) {
      if ((url.indexOf(API.login) > -1)) {
        setCookie(response);
      }
      return responseData['data'] ?? '';
    } else {
      if (url.indexOf('app3/userbasic') == -1 && isShowToast) {
        List list = responseData['msg'].toString().split('#');
        if (list.length > 1) {
          toast(responseData['msg']);
        } else {
          toast(responseData['msg']);
        }
      }
    }
  }
}

void setCookie(Response response) {
  if (response?.headers['set-cookie'] != null &&
      response?.headers['set-cookie'].length > 0) {
    for (int i = 0; i < response.headers['set-cookie'].length; i++) {
      if (response.headers['set-cookie'][i].indexOf('SESSIONIDD2') > -1) {
        String cookie = response.headers['set-cookie'][i];
        Store.sharedPreferences.setString('cookie', cookie);
        break;
      }
    }
  }
}

void goLogin() {
  dio.interceptors.requestLock.unlock();
  isLoginPage = true;
  Store.sharedPreferences.remove('token');
  Store.sharedPreferences.remove('cookie');
  Store.sharedPreferences.remove('userInfo');
  Navigator.of(Store.navigatorKey.currentContext)
      .pushNamedAndRemoveUntil('/login', ModalRoute.withName('/login'));
  Timer(Duration(seconds: 3), () {
    isLoginPage = false;
    isSendLogin = false;
  });
}
