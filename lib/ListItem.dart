import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:u22_application/notification/NotificationService.dart';
import 'dart:async';

class ListItem extends StatefulWidget {
  const ListItem({Key? key, required this.document}) : super(key: key);
  final DocumentSnapshot document;

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  Timer? _timer;
  String formattedRemainingTime = "計算中";
  DateTime? reviewTime;

  @override
  void initState() {
    super.initState();
    reviewTime = (widget.document['reviewTime'] as Timestamp).toDate();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemainingTime() {
    if (reviewTime == null) return;

    final now = DateTime.now();
    final remainingTime = reviewTime!.difference(now);

    setState(() {
      if (remainingTime.isNegative || remainingTime.inSeconds <= 0) {
        formattedRemainingTime = '復習可能';
        _updateFirestoreMemorized(false);
        _sendNotificationIfNeeded();
      } else if (remainingTime.inDays > 0) {
        formattedRemainingTime = '${remainingTime.inDays}日後';
      } else if (remainingTime.inHours > 0) {
        formattedRemainingTime = '${remainingTime.inHours}時間後';
      } else if (remainingTime.inMinutes > 0) {
        formattedRemainingTime = '${remainingTime.inMinutes}分後';
      } else {
        formattedRemainingTime = '${remainingTime.inSeconds}秒後';
      }
    });
  }

  Future<void> _updateFirestoreMemorized(bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(widget.document.id)
          .update({'memorized': value});
    } catch (e) {
      print('Error updating memorized field: $e');
    }
  }

  Future<void> _sendNotificationIfNeeded() async {
    final docId = widget.document.id;

    try {
      await NotificationService.scheduleNotification(
        DateTime.now(),
        docId,
        '復習の時間です',
        '${widget.document['name']}の復習を行ってください',
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemName = widget.document['name'];
    final isMemorized = widget.document['memorized'];
    reviewTime = (widget.document['reviewTime'] as Timestamp).toDate();
    _updateRemainingTime();
    return ListTile(
      tileColor: isMemorized ? Colors.deepPurple[900] : Colors.deepPurple[400],
      leading: const Icon(Icons.home, color: Colors.amberAccent),
      title: Text(itemName,
          style: TextStyle(
              color: isMemorized ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold)),
      subtitle: Text('次の復習までの残り時間: $formattedRemainingTime',
          style: TextStyle(color: Colors.white70)),
      onTap: () => showItemDialog(context, widget.document),
    );
  }

  Future<void> showItemDialog(
      BuildContext context, DocumentSnapshot document) async {
    final itemName = document['name'];
    final itemContent = document['content'];
    final memoryDepth = document['memoryDepth'];
    final reviewTime = (document['reviewTime'] as Timestamp).toDate();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _ItemDialog(
          document: document,
          initialItemName: itemName,
          initialItemContent: itemContent,
          initialMemoryDepth: memoryDepth,
          initialReviewTime: reviewTime,
        );
      },
    );
  }
}

class _ItemDialog extends StatefulWidget {
  const _ItemDialog({
    Key? key,
    required this.document,
    required this.initialItemName,
    required this.initialItemContent,
    required this.initialMemoryDepth,
    required this.initialReviewTime,
  }) : super(key: key);

  final DocumentSnapshot document;
  final String initialItemName;
  final String initialItemContent;
  final int initialMemoryDepth;
  final DateTime initialReviewTime;

  @override
  _ItemDialogState createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  Timer? _timer;
  String formattedRemainingTime = "計算中";
  DateTime? reviewTime;
  late TextEditingController itemNameController;
  late TextEditingController itemContentController;

  @override
  void initState() {
    super.initState();
    reviewTime = widget.initialReviewTime;
    itemNameController = TextEditingController(text: widget.initialItemName);
    itemContentController =
        TextEditingController(text: widget.initialItemContent);
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    itemNameController.dispose();
    itemContentController.dispose();
    super.dispose();
  }

  void _updateRemainingTime() {
    if (reviewTime == null) return;

    final now = DateTime.now();
    final remainingTime = reviewTime!.difference(now);

    setState(() {
      if (remainingTime.isNegative || remainingTime.inSeconds <= 0) {
        formattedRemainingTime = '復習可能';
        _updateFirestoreMemorized(false);
        _sendNotificationIfNeeded();
      } else if (remainingTime.inDays > 0) {
        formattedRemainingTime = '${remainingTime.inDays}日後';
      } else if (remainingTime.inHours > 0) {
        formattedRemainingTime = '${remainingTime.inHours}時間後';
      } else if (remainingTime.inMinutes > 0) {
        formattedRemainingTime = '${remainingTime.inMinutes}分後';
      } else {
        formattedRemainingTime = '${remainingTime.inSeconds}秒後';
      }
    });
  }

  Future<void> _updateFirestoreMemorized(bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(widget.document.id)
          .update({'memorized': value});
    } catch (e) {
      print('Error updating memorized field: $e');
    }
  }

  Future<void> _sendNotificationIfNeeded() async {
    final docId = widget.document.id;

    try {
      await NotificationService.scheduleNotification(
        DateTime.now(),
        docId,
        '復習の時間です',
        '${widget.document['name']}の復習を行ってください',
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoryDepth = widget.initialMemoryDepth;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.deepPurple[800],
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: TextField(
                    controller: itemNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.amberAccent),
                      ),
                      labelText: '項目名',
                      labelStyle: TextStyle(color: Colors.amberAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: TextField(
                    controller: itemContentController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.amberAccent),
                      ),
                      labelText: '項目内容',
                      labelStyle: TextStyle(color: Colors.amberAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amberAccent),
                      ),
                    ),
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  '次の復習までの残り時間: $formattedRemainingTime',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.amberAccent,
                  ),
                ),
                Text(
                  '復習レベル: $memoryDepth',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.amberAccent,
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[700],
                        foregroundColor: Colors.white,
                        shadowColor: Colors.grey,
                        elevation: 5,
                        side: const BorderSide(
                          width: 1.0,
                          color: Colors.amberAccent,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        await FirebaseFirestore.instance
                            .collection('items')
                            .doc(widget.document.id)
                            .delete();
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                        child: Text('削除'),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[700],
                        foregroundColor: Colors.white,
                        shadowColor: Colors.grey,
                        elevation: 5,
                        side: const BorderSide(
                          width: 1.0,
                          color: Colors.amberAccent,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        await FirebaseFirestore.instance
                            .collection('items')
                            .doc(widget.document.id)
                            .update({
                          'name': itemNameController.text,
                          'content': itemContentController.text,
                        });

                        if (widget.initialMemoryDepth >= 7) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('完全に暗記しました！'),
                                content: Text('この項目は完全に暗記されました。'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                        child: Text('更新'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _calculateNextReviewTime(int memoryDepth) {
    final now = DateTime.now();
    final hours = _getHoursForDepth(memoryDepth);
    return now.add(Duration(hours: hours));
  }

  int _getHoursForDepth(int memoryDepth) {
    switch (memoryDepth) {
      case 0:
        return 24;
      case 1:
        return 72;
      case 2:
        return 168;
      case 3:
        return 672;
      case 4:
        return 2016;
      case 5:
        return 4032;
      default:
        return 4032;
    }
  }
}
