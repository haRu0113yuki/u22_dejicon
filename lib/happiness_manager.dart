class HappinessManager {
  static final HappinessManager _instance = HappinessManager._internal();

  HappinessManager._internal();

  factory HappinessManager() {
    return _instance;
  }

  int happinessCount = 0;

  void incrementHappinessCount() {
    happinessCount++;
  }
}
