import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/api/message/chat_controller.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;

  GroupChatPage({required this.groupId});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  late Stream<QuerySnapshot> groupChatsStream;

  @override
  void initState() {
    super.initState();
    // Call your function to get group chats
    groupChatsStream = ChatController().getGroupChats(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat'),
      ),
      body: StreamBuilder(
        stream: groupChatsStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // Check if there are no documents
          if (snapshot.data?.docs.isEmpty ?? true) {
            return Center(
              child: Text('No messages available.'),
            );
          }

          // Build the chat messages
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var message = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Access the message fields
              var date = message['date'];
              var id = message['id'];
              var senderId = message['senderId'];
              var text = message['text'];

              // Display the message in your UI
              return ListTile(
                title: Text(text),
                subtitle: Text('Sent by: $senderId'),
                // You can add more details like date, etc., as needed
              );
            },
          );
        },
      ),
    );
  }
}

// Don't forget to update your ChatController to return a Stream<QuerySnapshot>
// for getGroupChats method:


