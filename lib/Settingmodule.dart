import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:u22_application/explain.dart';
import 'package:u22_application/models/theme_mode.dart';

const List<int> defaultPeriods = [24, 72, 168, 672, 2016, 4032];

class Settingmodule extends StatefulWidget {
  const Settingmodule({Key? key}) : super(key: key);
  @override
  _SettingmoduleState createState() => _SettingmoduleState();
}

class _SettingmoduleState extends State<Settingmodule> {
  final List<int> shortPeriod = [10, 30, 70, 280, 840, 1680];
  final List<int> ultraShortPeriod = [1, 3, 7, 28, 84, 168];
  List<int> periods = defaultPeriods;
  int selectedPeriodIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  Future<void> _loadPeriods() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final periodMode = prefs.getString('periodMode') ?? 'default';

    setState(() {
      if (periodMode == 'short') {
        periods = shortPeriod;
      } else if (periodMode == 'ultraShort') {
        periods = ultraShortPeriod;
      } else {
        periods = defaultPeriods;
      }
      selectedPeriodIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, modeNotifier, child) {
        final mode = modeNotifier.mode;
        return Scaffold(
          backgroundColor: mode == ThemeMode.dark ? Colors.black : Colors.white,
          body: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.lightbulb,
                    color: mode == ThemeMode.dark
                        ? Colors.amber
                        : Colors.deepPurple),
                title: Text('ダーク/ライト モード',
                    style: TextStyle(
                        color: mode == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                trailing: Text(
                    (mode == ThemeMode.system)
                        ? 'システム設定'
                        : (mode == ThemeMode.dark ? 'ダークモード' : 'ライトモード'),
                    style: TextStyle(
                        color: mode == ThemeMode.dark
                            ? Colors.amber
                            : Colors.deepPurple,
                        fontSize: 16)),
                onTap: () async {
                  final ret = await Navigator.of(context).push<ThemeMode>(
                    MaterialPageRoute(
                      builder: (context) => ThemeModeSelectionPage(init: mode),
                    ),
                  );
                  if (ret != null) {
                    modeNotifier.update(ret);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.timer,
                    color: mode == ThemeMode.dark
                        ? Colors.amber
                        : Colors.deepPurple),
                title: Text('復習頻度',
                    style: TextStyle(
                        color: mode == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                trailing: Text(getPeriodModeText(periods),
                    style: TextStyle(
                        color: mode == ThemeMode.dark
                            ? Colors.amber
                            : Colors.deepPurple,
                        fontSize: 16)),
                onTap: () {
                  showPeriodSelectionDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.description,
                    color: mode == ThemeMode.dark
                        ? Colors.amber
                        : Colors.deepPurple),
                title: Text('チュートリアル',
                    style: TextStyle(
                        color: mode == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Explain()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String getPeriodModeText(List<int> periods) {
    if (periods == shortPeriod) {
      return '短期間';
    } else if (periods == ultraShortPeriod) {
      return '超短期間';
    } else {
      return 'デフォルト';
    }
  }

  Future<void> showPeriodSelectionDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
          title: Text('期間を選択',
              style: TextStyle(
                  color: isDarkMode ? Colors.amber : Colors.deepPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('デフォルト',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
                leading: Radio<int>(
                  value: 0,
                  groupValue: selectedPeriodIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedPeriodIndex = value!;
                      periods = defaultPeriods;
                      _saveSelectedPeriod('default');
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('短期間',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
                leading: Radio<int>(
                  value: 1,
                  groupValue: selectedPeriodIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedPeriodIndex = value!;
                      periods = shortPeriod;
                      _saveSelectedPeriod('short');
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('超短期間',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
                leading: Radio<int>(
                  value: 2,
                  groupValue: selectedPeriodIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedPeriodIndex = value!;
                      periods = ultraShortPeriod;
                      _saveSelectedPeriod('ultraShort');
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveSelectedPeriod(String periodMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('periodMode', periodMode);
  }
}

class ThemeModeSelectionPage extends StatefulWidget {
  const ThemeModeSelectionPage({
    Key? key,
    required this.init,
  }) : super(key: key);
  final ThemeMode init;

  @override
  _ThemeModeSelectionPageState createState() => _ThemeModeSelectionPageState();
}

class _ThemeModeSelectionPageState extends State<ThemeModeSelectionPage> {
  late ThemeMode _current;

  @override
  void initState() {
    super.initState();
    _current = widget.init;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                onPressed: () => Navigator.pop<ThemeMode>(context, _current),
              ),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: _current,
              title: Text('システム設定',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black)),
              onChanged: (val) => setState(() => _current = val!),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: _current,
              title: Text('ダークモード',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black)),
              onChanged: (val) => setState(() => _current = val!),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: _current,
              title: Text('ライトモード',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black)),
              onChanged: (val) => setState(() => _current = val!),
            ),
          ],
        ),
      ),
    );
  }
}
