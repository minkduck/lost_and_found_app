import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_constraints.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import '../../data/api/message/Chat.dart';
import 'chat_card.dart';
import 'chat_page.dart';
import 'package:lost_and_find_app/data/api/message/chat_controller.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late String myUid;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AppConstrants.getUid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          myUid = snapshot.data!;
          return _buildChatPage();
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildChatPage() {
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
          StreamBuilder<List<Chat>>(
            stream: ChatController().getMyChatsStream(myUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Chat>? chatsData = snapshot.data;
                return chatsData != null && chatsData.isNotEmpty
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
                    : Container();
              }
            },
          ),
        ],
      ),
    );

  }
}
