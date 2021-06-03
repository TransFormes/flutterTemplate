import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  int index = 0;
  setIndex(int number) {
    index = number;
    notifyListeners();
  }
}
