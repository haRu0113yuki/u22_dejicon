import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:u22_application/Allmodule.dart';
import 'package:u22_application/HappinessCountNotifier.dart';
import 'package:u22_application/Settingmodule.dart';
import 'package:u22_application/Topmodule.dart';
import 'package:u22_application/explain.dart';
import 'package:u22_application/models/theme_mode.dart';
import 'package:u22_application/notification/NotificationService.dart';
import 'globals.dart';
import 'happiness_manager.dart';

void incrementHappinessCount(int memoryDepth) {
  happinessCount += memoryDepth;
  print('Happiness count: $happinessCount');
}

void updateHappinessCount() {
  HappinessManager manager = HappinessManager();
  manager.incrementHappinessCount();
  print('Happiness count: ${manager.happinessCount}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'apiKey',
      appId: '1:208625512991:web:a30601f8cdeff0ed505b2a',
      messagingSenderId: '208625512991',
      projectId: 'u-22-flutter-2024',
    ),
  );
  FirebaseFirestore.instance.collection('items').get().then((querySnapshot) {
    querySnapshot.docs.forEach((document) {
      checkAndScheduleNotifications(document);
    });
  });
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final themeModeNotifier = ThemeModeNotifier(pref);
  final happinessCountNotifier = HappinessCountNotifier();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => themeModeNotifier),
      ChangeNotifierProvider(create: (context) => happinessCountNotifier),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, modeNotifier, child) => MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ja', ''),
        ],
        title: 'エビング家',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.deepPurple[800]!,
            secondary: Colors.amber[600]!,
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.deepPurple[800],
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Cinzel',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            elevation: 0,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.deepPurple[800],
            selectedItemColor: Colors.amber[600],
            unselectedItemColor: Colors.white,
            showUnselectedLabels: false,
            showSelectedLabels: true,
          ),
          dialogTheme: DialogTheme(
            backgroundColor: Colors.deepPurple[800],
            titleTextStyle: TextStyle(
              color: Colors.amber[600],
              fontFamily: 'Cinzel',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Cinzel',
              fontSize: 16,
            ),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.deepPurple[900]!,
            secondary: Colors.amber[600]!,
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.deepPurple[900],
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Cinzel',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            elevation: 0,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.deepPurple[900],
            selectedItemColor: Colors.amber[600],
            unselectedItemColor: Colors.white,
            showUnselectedLabels: false,
            showSelectedLabels: true,
          ),
          dialogTheme: DialogTheme(
            backgroundColor: Colors.deepPurple[900],
            titleTextStyle: TextStyle(
              color: Colors.amber[600],
              fontFamily: 'Cinzel',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Cinzel',
              fontSize: 16,
            ),
          ),
        ),
        themeMode: modeNotifier.mode,
        home: const TopScreen(),
      ),
    );
  }
}

class TopScreen extends StatefulWidget {
  const TopScreen({super.key});

  @override
  _TopScreenState createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen> {
  int current = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Explain()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A148C), Color(0xFFCE93D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: Text(
                DateFormat.yMd('ja_JP').add_Hm().format(DateTime.now()),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Consumer<HappinessCountNotifier>(
              builder: (context, happinessCountNotifier, child) => Row(
                children: [
                  Image.asset(
                    'assets/images/mainIcon.png',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${happinessCount}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: current == 0
            ? const AllModule()
            : current == 1
                ? const Topmodule()
                : const Settingmodule(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        onTap: (index) => setState(() => current = index),
        currentIndex: current,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Top',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
