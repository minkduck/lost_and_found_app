import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();

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
              backgroundImage: AssetImage(AppAssets.avatarDefault!),
            ),
            Gap(AppLayout.getWidth(20) * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Kristin Watson",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Active 3m ago",
                  style: TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_phone),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          Gap(AppLayout.getWidth(10)),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
                left: 20, right: 20, bottom: 20
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
            //comment container
            child: Container(
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
                      child: const Row(
                        children: [
                          SizedBox(width: 20 / 4),
                          Expanded(
                            child: TextField(
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
                          )),
                    ),
                  )
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
