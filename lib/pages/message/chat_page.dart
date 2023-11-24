import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/data/api/message/chat_controller.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/data/api/message/Chat.dart';
import 'message_tile.dart'; // Import your updated MessageTile widget

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List<dynamic> messagesData = [];
  bool _isMounted = false;

  Future<dynamic> listChatData() async {
    try {
      var chatData = await ChatController().getChatData(widget.chat.chatId);

      if (chatData.exists) {
        var chatMetadata = chatData.data();
        // print('Chat Metadata: $chatMetadata');
        //
        // // Retrieve messages data from the chat metadata
        // messagesData = chatMetadata?['messages'] ?? [];
        //
        // print('Messages Data: $messagesData');
        //
        // // You can now iterate through messagesData and do further processing
        // for (var message in messagesData) {
        //   print('Message: $message');
        // }
        return chatMetadata?['messages'];
      } else {
        print('Chat not found.');
      }

    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    listChatData().then((result) {
      if (_isMounted) {
        setState(() {
          messagesData = result;
          print(messagesData);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        title: Row(
          children: [
            const BackButton(),
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.image),
            ),
            Gap(AppLayout.getWidth(20) * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 32,
                  color: const Color(0xFF087949).withOpacity(0.08),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: messagesData.length,
                    itemBuilder: (context, index) {
                      var messageData = messagesData[index];

                      return MessageTile(
                        message: messageData['text'],
                        sender: messageData['senderId'],
                        sentByMe: messageData['senderId'] == widget.chat.uid,
                        imageUrl: messageData['img'],
                      );
                    },
                  ),
                ),
                // Your message input field and send button
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20 * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF00BF6D).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 20 / 4),
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  decoration: InputDecoration(
                                    hintText: "Type message",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(AppLayout.getWidth(20)),
                      GestureDetector(
                        onTap: () {
                          // sendMessage();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.send,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/data/api/message/chat_controller.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/data/api/message/Chat.dart';
import 'message_tile.dart'; // Import your updated MessageTile widget

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List<dynamic> messagesData = [];
  bool _isMounted = false;
  Stream<QuerySnapshot>? _chatDataStream;


  Stream<List<dynamic>> streamChatData() {
    return ChatController().getChatData(widget.chat.chatId).map((chatData) {
      if (chatData.exists) {
        var chatMetadata = chatData.data();
        return chatMetadata?['messages'] ?? [];
      } else {
        print('Chat not found.');
        return [];
      }
    });
  }

  Future<dynamic> listChatData() async {
    try {
      var chatData = await ChatController().getChatData(widget.chat.chatId);

      if (chatData.exists) {
        var chatMetadata = chatData.data();
/*        // print('Chat Metadata: $chatMetadata');
        //
        // // Retrieve messages data from the chat metadata
        // messagesData = chatMetadata?['messages'] ?? [];
        //
        // print('Messages Data: $messagesData');
        //
        // // You can now iterate through messagesData and do further processing
        // for (var message in messagesData) {
        //   print('Message: $message');
        // }*/
        return chatMetadata?['messages'];
      } else {
        print('Chat not found.');
      }

    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
/*
    listChatData().then((result) {
      if (_isMounted) {
        setState(() {
          messagesData = result;
          print(messagesData);
        });
      }
    });
*/
    ChatController().getChatData(widget.chat.chatId).then((val) {
      setState(() {
        _chatDataStream = val;
      });
    });
    print("chatDataStream: " + _chatDataStream.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        title: Row(
          children: [
            const BackButton(),
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.image),
            ),
            Gap(AppLayout.getWidth(20) * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 32,
                  color: const Color(0xFF087949).withOpacity(0.08),
                ),
              ],
            ),
            child: Column(
              children: [
/*
                StreamBuilder(
                  stream: _chatDataStream,
                  builder: (context,AsyncSnapshot snapshot) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) {
                            var messageData = snapshot.data?.docs[index];
                            print("messageData: " + messageData);
                            return MessageTile(
                              message: messageData['text'],
                              sender: messageData['senderId'],
                              sentByMe: messageData['senderId'] == widget.chat.uid,
                              imageUrl: messageData['img'],
                            );
                          },
                        ),
                      );
                    }
                ),
*/
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20 * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF00BF6D).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 20 / 4),
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  decoration: InputDecoration(
                                    hintText: "Type message",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(AppLayout.getWidth(20)),
                      GestureDetector(
                        onTap: () {
                          // sendMessage();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.send,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/