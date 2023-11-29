import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/message/Chat.dart';
import 'package:lost_and_find_app/data/api/message/chat_controller.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/big_text.dart';

import 'chat_card.dart';
import 'chat_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late List<Chat> chatsData = [];
  late String myUid = "FLtIEJvuMgfg58u4sXhzxPn9qr73";
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    listMessage().then((result) {
      if (_isMounted) {
        setState(() {
          chatsData = result;
          print(chatsData);
        });
      }
    });
  }

  Future<List<Chat>> listMessage() async {
    // Get the userChats collection based on the user's UID
    var userChatsSnapshot = await ChatController().getMyChats(myUid);

    // Extract data from userChats document
    var userChatsData = userChatsSnapshot.data();
    print("userChatsData" + userChatsData.toString());

    List<Chat> chatsList = [];

    if (userChatsData != null) {
      // Loop through each entry in the userChats document
      for (var entry in userChatsData.entries) {
        var docId = entry.key;
        var chatData = entry.value;

        // Get the UID of the person the user is chatting with from the chat data
        var otherUid = chatData['uid'];
        print("OtherUid:" + otherUid);

        // Get the user document for the person the user is chatting with
        var otherUserSnapshot = await ChatController().getUserUid(otherUid);

        // Extract data from the other user document
        var otherUserData = otherUserSnapshot.data();

        if (otherUserData != null) {
          // Format the date
          var now = DateTime.now();
          var timeDifference = now.difference(chatData['date'].toDate());
          var formattedDate = '';

          if (timeDifference.inMinutes < 1) {
            // Less than 1 minute, format as "just now"
            formattedDate = 'just now';
          } else if (timeDifference.inHours < 1) {
            // Less than 1 hour, format as "... minutes ago"
            var minutesAgo = timeDifference.inMinutes;
            formattedDate = (minutesAgo == 1) ? '1 minute ago' : '$minutesAgo minutes ago';
          } else if (timeDifference.inHours < 24) {
            // Between 1 hour and 24 hours, format as "... hours ago"
            var hoursAgo = timeDifference.inHours;
            formattedDate = (hoursAgo == 1) ? '1 hour ago' : '$hoursAgo hours ago';
          } else if (timeDifference.inDays <= 7) {
            // Between 24 hours and 7 days, format as "... day ago"
            var daysAgo = timeDifference.inDays;
            formattedDate = (daysAgo == 1) ? '1 day ago' : '$daysAgo days ago';
          } else if (timeDifference.inDays <= 365) {
            // Between 7 days and 1 year, format as "dd-MM"
            formattedDate = DateFormat('dd-MM').format(chatData['date'].toDate());
          } else {
            // More than 1 year, format as "dd-MM-yyyy"
            formattedDate = DateFormat('dd-MM-yyyy').format(chatData['date'].toDate());
          }

          String chatId;

          if (otherUid.compareTo(myUid) > 0) {
            chatId = otherUid + myUid;
          } else {
            chatId = myUid + otherUid;
          }

          print(formattedDate);
          // Create a Chat object
          var chat = Chat(
            uid: otherUid,
            name: otherUserData['displayName'],
            image: otherUserData['photoUrl'],
            lastMessage: chatData['lastMessage']['text'],
            time: formattedDate,
            chatId: chatId,
            formattedDate: formattedDate,
          );

          print("chatId: " + chatId);
          // Add the Chat object to the chatsList
          chatsList.add(chat);
        }
      }

      // Sort the chatsList based on UID
      chatsList.sort((a, b) => b.formattedDate.compareTo(a.formattedDate));
    }

    // Return the list of chats
    return chatsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(AppLayout.getWidth(20.0), 0,
                AppLayout.getWidth(20.0), AppLayout.getWidth(20.0)),
            color: AppColors.primaryColor,
            child: Column(
              children: [
                Gap(AppLayout.getHeight(40)),
                Row(
                  children: [
                    Text("Chats",
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ],
            ),
          ),
          chatsData.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: chatsData.length,
                    itemBuilder: (context, index) => ChatCard(
                      chat: chatsData[index],
                      press: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            chat: chatsData[index],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
