import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:u22_application/main.dart';
import 'package:u22_application/notification/NotificationService.dart';

class GridModule extends StatelessWidget {
  const GridModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('items').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs
            .map((doc) => Flashcard(
                  id: doc.id,
                  title: doc['name'],
                  content: doc['content'],
                  memorized: doc['memorized'],
                  memoryDepth: doc['memoryDepth'],
                ))
            .toList();

        return FlashcardScreen(flashcards: items);
      },
    );
  }
}

class Flashcard {
  final String id;
  final String title;
  final String content;
  final bool memorized;
  final int memoryDepth;

  Flashcard({
    required this.id,
    required this.title,
    required this.content,
    required this.memorized,
    required this.memoryDepth,
  });
}

class FlashcardScreen extends StatefulWidget {
  List<Flashcard> flashcards;

  FlashcardScreen({super.key, required this.flashcards});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  Color backgroundColor = _getRandomColor();
  late Flashcard _selectedFlashcard;
  bool _isContentVisible = false;

  static Color _getRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
        .withOpacity(1.0);
  }

  void _showCardDialog(Flashcard flashcard) {
    _selectedFlashcard = flashcard;

    final parentContext = context;

    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        bool isContentVisible = _isContentVisible;

        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: Colors.white,
              title: Text(
                flashcard.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 8.0),
                      child: Text(
                        flashcard.content,
                        style: TextStyle(
                          color: isContentVisible
                              ? Colors.amber[800]
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (!isContentVisible)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[600],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          if (mounted) {
                            setDialogState(() {
                              isContentVisible = true;
                            });
                          }
                        },
                        child: Text(
                          '項目内容を表示',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    if (isContentVisible)
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple[400],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () {
                              if (mounted) {
                                setDialogState(() {
                                  isContentVisible = false;
                                });
                              }
                            },
                            child: Text(
                              '項目内容を隠す',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[700],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              print('Dialog closed, updating flashcard...');
                              try {
                                await _updateFlashcard(flashcard.id, true);
                                print('Updating happiness count...');

                                incrementHappinessCount(flashcard.memoryDepth);
                                print('finished');
                              } catch (e) {
                                print('Error occurred:$e');
                              }
                              if (mounted) {
                                setState(
                                  () {},
                                );
                              }
                            },
                            child: Text(
                              '暗記する',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actionsPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    '閉じる',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateFlashcard(String id, bool memorized) async {
    print('Updating flashcard with id: $id');
    final flashcard = widget.flashcards.firstWhere((fc) => fc.id == id);
    final newMemoryDepth =
        memorized ? flashcard.memoryDepth + 1 : flashcard.memoryDepth;
    final reviewTime = _calculateReviewTime(newMemoryDepth);

    try {
      await FirebaseFirestore.instance.collection('items').doc(id).update({
        'memorized': memorized,
        'memoryDepth': newMemoryDepth,
        'reviewTime': reviewTime,
      });

      await NotificationService.scheduleNotification(
        reviewTime,
        id,
        '復習の時間です',
        '${flashcard.title}の復習を行ってください',
      );
    } catch (e) {
      print('Error updating flashcard: $e');
    }

    if (!mounted) return;
    setState(() {
      final updatedFlashcards = widget.flashcards.map((fc) {
        if (fc.id == id) {
          return Flashcard(
            id: fc.id,
            title: fc.title,
            content: fc.content,
            memorized: memorized,
            memoryDepth: newMemoryDepth,
          );
        }
        return fc;
      }).toList();

      widget.flashcards = updatedFlashcards;
    });
  }

  DateTime _calculateReviewTime(int memoryDepth) {
    final now = DateTime.now();
    Duration duration;

    switch (memoryDepth) {
      case 1:
        duration = Duration(hours: 24);
        break;
      case 2:
        duration = Duration(hours: 72);
        break;
      case 3:
        duration = Duration(hours: 168);
        break;
      case 4:
        duration = Duration(hours: 672);
        break;
      case 5:
        duration = Duration(hours: 2016);
        break;
      case 6:
        duration = Duration(hours: 4032);
        break;
      default:
        duration = Duration(days: 30);
    }

    return now.add(duration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CarouselSlider.builder(
        itemCount: widget.flashcards.length,
        itemBuilder: (BuildContext context, int index, int realIndex) {
          final flashcard = widget.flashcards[index];
          return GestureDetector(
            onTap: () {
              _showCardDialog(flashcard);
            },
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    flashcard.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 200,
          aspectRatio: 16 / 9,
          viewportFraction: 0.8,
          initialPage: 0,
          enableInfiniteScroll: false,
          onPageChanged: (index, reason) {
            setState(() {
              backgroundColor = _getRandomColor();
            });
          },
        ),
      ),
    );
  }
}
