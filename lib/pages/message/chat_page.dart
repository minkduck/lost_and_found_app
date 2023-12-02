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

}*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/data/api/message/chat_controller.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/data/api/message/Chat.dart';
import 'package:uuid/uuid.dart';
import '../../utils/app_constraints.dart';
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
  late String myUid;

  Future<dynamic> listChatData() async {
    try {
      var chatData = await ChatController().getChatData(widget.chat.chatId);

      print('Chat Data: $chatData');

      if (chatData.exists) {
        var chatMetadata = chatData.data();
        return chatMetadata?['messages'];
      } else {
        print('Chat not found.');
        return null;  // Return null or an empty list based on your use case
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;  // Return null or an empty list based on your use case
    }
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    print('chatId: ' + widget.chat.chatId);
    AppConstrants.getUid().then((value) {
      myUid = value;
    });
    listChatData().then((result) {
      if (_isMounted) {
        setState(() {
          messagesData = result ?? [];
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ChatController().getChatDataStream(widget.chat.chatId),
        builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text("No messages yet."),
            );
          }
          var messagesData = snapshot.data!['messages'];

          return Stack(
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
                            message: messageData['text'] ?? "",
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
                          Gap(AppLayout.getWidth(10)), // Adjust the gap as needed
                          GestureDetector(
                            onTap: () async {
                              String messageText = messageController.text;
                              print(messageText);

                              if (messageText.isNotEmpty) {
                                // Call the sendMessage method to send the message to Firestore
                                await sendMessage(messageText);

                                // Clear the message input field after sending
                                messageController.clear();
                              }
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
                          ),
                          Gap(AppLayout.getWidth(10)), // Adjust the gap as needed
                          GestureDetector(
                            onTap: () {
                              // Add your logic to handle sending images
                              // This can include opening an image picker, etc.
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
                                  Icons.image, // Change this to the appropriate image icon
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Add the method to send a message
  Future<void> sendMessage(String messageText) async {
    try {
      // Create a new message map
      Map<String, dynamic> newMessage = {
        'date': DateTime.now().millisecondsSinceEpoch,
        'id': Uuid().v4(),
        'senderId': myUid, // Replace with the actual sender ID
        'text': messageText,
      };

      // Add the new message to the Firestore collection
      await ChatController().addMessage(widget.chat.chatId, newMessage, myUid, widget.chat.otherId);
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

