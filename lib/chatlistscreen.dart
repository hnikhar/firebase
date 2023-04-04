import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatdetailsscreen.dart';
import 'package:rxdart/rxdart.dart';


final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatListScreen extends StatefulWidget {
  static const String id = 'chat_list_screen';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: loggedInUser != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChatListStream(),
          ],
        )
            : Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
          ),
        ),
      ),
    );
  }

}

class ChatListStream extends StatelessWidget {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterUniqueConversations(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allMessages) {
    final uniqueConversations = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final message in allMessages) {
      if (!message.data().containsKey('item') ||
          !message.data().containsKey('sender') ||
          !message.data().containsKey('receiver') ||
          !message.data().containsKey('text')||
          !message.data().containsKey('timestamp')) {
        print('Incomplete message document: ${message.data()}');
        continue;
      }
      final itemName = message['item'];
      final senderUid = message['sender'];
      final receiverUid = message['receiver'];
      final conversationId =
      senderUid.compareTo(receiverUid) < 0 ? "$senderUid-$receiverUid" : "$receiverUid-$senderUid";
      final existingMessage = uniqueConversations[conversationId];
      if (existingMessage == null || existingMessage['timestamp'].toDate().compareTo(message['timestamp'].toDate()) < 0) {
        uniqueConversations[conversationId] = message;
      }
    }
    return uniqueConversations.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final senderStream = _firestore
        .collection('messages')
        .where('sender', isEqualTo: loggedInUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);

    final receiverStream = _firestore
        .collection('messages')
        .where('receiver', isEqualTo: loggedInUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);

    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: Rx.combineLatest2(senderStream, receiverStream, (List<QueryDocumentSnapshot<Map<String, dynamic>>> senderMessages, List<QueryDocumentSnapshot<Map<String, dynamic>>> receiverMessages) {
        final allMessages = [...senderMessages, ...receiverMessages];
        allMessages.sort((a, b) => b['timestamp'].compareTo(a['timestamp'].toDate()));
        return allMessages;
      }),
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final allMessages = snapshot.data ?? [];

        final uniqueConversations = filterUniqueConversations(allMessages);
        bool isEmptyData = uniqueConversations.isEmpty;

        if (isEmptyData) {
          return Expanded(
            child: Center(
              child: Text("No chats available"),
            ),
          );
        }



        List<Widget> chatListItems = [];
        for (var message in uniqueConversations) {
          final itemName = message['item'];
          final receiverUid = loggedInUser!.uid == message['sender'] ? message['receiver'] : message['sender'];
          final text = message['text'];

          chatListItems.add(
            ChatListItem(
              key: ValueKey(itemName),
              itemName: itemName,
              receiverUid: receiverUid,
              text: text,
            ),
          );
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: chatListItems,
          ),
        );
      },
    );
  }
}


class ChatListItem extends StatelessWidget {
  final String itemName;
  final String receiverUid;
  final String text;
  const ChatListItem({
  Key? key,
    required this.itemName,
    required this.receiverUid,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatDetailsScreen(
                  accepterUid: receiverUid, itemName: itemName,
                ),
          ),
        );
      },
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _firestore.collection('users').doc(receiverUid).get(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return ListTile(
              title: Text("Loading..."),
              subtitle: Text("Loading..."),
            );
          } else {
            return ListTile(
              title: Text("Chat"),
              subtitle: Text("Item: $itemName\nLast message: $text"),
            );
          }
        },
      ),
    );
  }
}
