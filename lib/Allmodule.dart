import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:u22_application/ListItem.dart';

class AllModule extends StatefulWidget {
  const AllModule({Key? key}) : super(key: key);

  @override
  State<AllModule> createState() => _AllModuleState();
}

class _AllModuleState extends State<AllModule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('items')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final items = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final document = items[index];
                        final reviewTime =
                            (document['reviewTime'] as Timestamp).toDate();
                        final now = DateTime.now();
                        final remainingTime = reviewTime.difference(now);

                        if (remainingTime.isNegative && document['memorized']) {
                          FirebaseFirestore.instance
                              .collection('items')
                              .doc(document.id)
                              .update({
                            'memorized': false,
                          });
                        }

                        return ListItem(document: document);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () => showItemDialog(context),
              backgroundColor: Colors.deepPurpleAccent,
              child: Icon(Icons.add, size: 30.0),
              tooltip: 'アイテム追加',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showItemDialog(BuildContext context) async {
    String name = '';
    String content = '';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.black.withOpacity(0.8),
          child: Container(
            width: 320.0,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.black87],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'アイテム追加',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white54,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    labelText: '項目名を入力',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: '項目名を入力',
                    hintStyle: TextStyle(color: Colors.white54),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  onChanged: (value) => name = value,
                ),
                SizedBox(height: 16.0),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white54,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    labelText: '項目の内容を入力',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: '項目の内容を入力',
                    hintStyle: TextStyle(color: Colors.white54),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  onChanged: (value) => content = value,
                  maxLines: 4,
                ),
                SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('キャンセル'),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          final now = DateTime.now();
                          final reviewTime = now.add(Duration(hours: 24));

                          Navigator.of(context).pop();

                          try {
                            await FirebaseFirestore.instance
                                .collection('items')
                                .add({
                              'name': name,
                              'content': content,
                              'timestamp': FieldValue.serverTimestamp(),
                              'reviewTime': reviewTime,
                              'memorized': true,
                              'memoryDepth': 1,
                            });

                            if (mounted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      backgroundColor:
                                          Colors.black.withOpacity(0.8),
                                      title: Text('アイテム追加完了',
                                          style: TextStyle(
                                              color: Colors.deepPurpleAccent,
                                              fontWeight: FontWeight.bold)),
                                      content: Text(
                                        '最初の復習ができるのは24時間後です。24時間後にまた会いましょう。',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: Text('OK',
                                              style: TextStyle(
                                                  color:
                                                      Colors.deepPurpleAccent)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              });
                            }
                          } catch (e) {
                            print('Error adding item: $e');

                            if (mounted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          Colors.black.withOpacity(0.8),
                                      title: Text('エラー',
                                          style: TextStyle(
                                              color: Colors.deepPurpleAccent,
                                              fontWeight: FontWeight.bold)),
                                      content: Text(
                                        'アイテムの追加中にエラーが発生しました。',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text('OK',
                                              style: TextStyle(
                                                  color:
                                                      Colors.deepPurpleAccent)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              });
                            }
                          }
                        },
                        child: Text('追加'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
