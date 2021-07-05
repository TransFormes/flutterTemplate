import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertemplate/createMaterialColor.dart';
import 'package:fluttertemplate/event/index.dart';
import 'package:fluttertemplate/pages/login.dart';
import 'package:fluttertemplate/router/index.dart';
import 'package:fluttertemplate/store/index.dart';
import 'package:fluttertemplate/store/provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //禁止横屏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    Provider.debugCheckInvalidValueType = null;
    await Store.init();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    runApp(MyApp());
    EventBus.init();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => User(),
          )
        ],
        child: MaterialApp(
            title: 'Example',
            debugShowCheckedModeBanner: false,
            navigatorKey: Store.navigatorKey,
            theme: ThemeData(
                primarySwatch: createMaterialColor(Color(0xff3668ff)),
                visualDensity: VisualDensity.adaptivePlatformDensity,
                highlightColor: Colors.transparent,
                fontFamily: 'normal',
                splashColor: Colors.transparent),
            routes: routes,
            builder: (context, widget) {
              return MediaQuery(
                ///设置文字大小不随系统设置改变
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: widget,
              );
            },
            home: LoginPage()));
  }
}
