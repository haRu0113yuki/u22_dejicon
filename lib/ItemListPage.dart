import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:u22_application/ListItem.dart';

class ItemListPage extends StatefulWidget {
  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late Stream<List<DocumentSnapshot>> _itemsStream;

  @override
  void initState() {
    super.initState();
    _itemsStream =
        FirebaseFirestore.instance.collection('items').snapshots().map(
              (snapshot) => snapshot.docs,
            );
  }

  void _refreshItems() {
    setState(() {
      _itemsStream =
          FirebaseFirestore.instance.collection('items').snapshots().map(
                (snapshot) => snapshot.docs,
              );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items List'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshItems,
          ),
        ],
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _itemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items available'));
          }

          final items = snapshot.data!;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListItem(document: items[index]);
            },
          );
        },
      ),
    );
  }
}
