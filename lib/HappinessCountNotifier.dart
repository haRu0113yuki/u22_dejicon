import 'package:flutter/foundation.dart';

class HappinessCountNotifier extends ChangeNotifier {
  int _happinessCount = 0;

  int get happinessCount => _happinessCount;

  void incrementHappinessCount(int memoryDepth) {
    _happinessCount += memoryDepth;
    print('Happiness Count Incremented: $_happinessCount');
    notifyListeners();
  }

  void setHappinessCount(int count) {
    _happinessCount = count;
    notifyListeners();
  }
}
