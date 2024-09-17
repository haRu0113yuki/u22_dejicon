import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:u22_application/StoryPage.dart';
import 'package:u22_application/gridModule.dart';

class Topmodule extends StatefulWidget {
  const Topmodule({Key? key}) : super(key: key);

  @override
  _TopmoduleState createState() => _TopmoduleState();
}

class _TopmoduleState extends State<Topmodule> {
  late Stream<QuerySnapshot> _itemStream;

  @override
  void initState() {
    super.initState();

    try {
      _itemStream = FirebaseFirestore.instance
          .collection('items')
          .where('memorized', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      print('Error initializing Firestore stream: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.white : Colors.black;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final gradientColors = isDarkMode
        ? [Colors.deepPurpleAccent, Colors.black]
        : [Colors.deepPurpleAccent, Colors.amber];

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _itemStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                print('Error fetching data: ${snapshot.error}');
                return Center(
                  child: Text(
                    'データの取得中にエラーが発生しました。',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'アイテムが見つかりません',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                );
              }

              final items = snapshot.data!.docs.map((doc) {
                return Flashcard(
                  id: doc.id,
                  title: doc['name'] as String? ?? '無題',
                  content: doc['content'] as String? ?? 'コンテンツがありません',
                  memorized: doc['memorized'] as bool? ?? false,
                  memoryDepth: doc['memoryDepth'] as int? ?? 0,
                );
              }).toList();

              return FlashcardScreen(flashcards: items);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StoryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(color: borderColor, width: 2),
                ),
              ),
              child: Center(
                child: Text(
                  'ストーリー',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
