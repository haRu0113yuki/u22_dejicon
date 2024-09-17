import 'package:flutter/material.dart';
import 'package:u22_application/Settingmodule.dart';

class ListItem extends ChangeNotifier {
  List<int> periods = defaultPeriods;

  void updatePeriods(List<int> newPeriods) {
    periods = newPeriods;
    notifyListeners();
  }
}
