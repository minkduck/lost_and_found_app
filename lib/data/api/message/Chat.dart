import 'package:lost_and_find_app/utils/app_assets.dart';

class Chat {
  final String uid;
  final String name;
  final String image;
  final String lastMessage;
  final String time;
  final DateTime date;
  final String chatId;
  final String formattedDate;
  final String otherId;// Add this property

  Chat({
    required this.uid,
    required this.name,
    required this.image,
    required this.lastMessage,
    required this.time,
    required this.chatId,
    required this.formattedDate,
    required this.otherId,
    required this.date,


  });
}


/*
List chatsData = [
  Chat(
    name: "Jenny Wilson",
    lastMessage: "Hope you are doing well...",
    image: AppAssets.avatarDefault,
    time: "3m ago",
  ),
  Chat(
    name: "Esther Howard",
    lastMessage: "Hello Abdullah! I am...",
    image: AppAssets.avatarDefault,
    time: "8m ago",
  ),
  Chat(
    name: "Ralph Edwards",
    lastMessage: "Do you have update...",
    image: AppAssets.avatarDefault,
    time: "5d ago",
  ),
  Chat(
    name: "Jacob Jones",
    lastMessage: "You’re welcome :)",
    image: AppAssets.avatarDefault,
    time: "5d ago",
  ),
  Chat(
    name: "Albert Flores",
    lastMessage: "Thanks",
    image: AppAssets.avatarDefault,
    time: "6d ago",
  ),
  Chat(
    name: "Jenny Wilson",
    lastMessage: "Hope you are doing well...",
    image: AppAssets.avatarDefault,
    time: "3m ago",
  ),
  Chat(
    name: "Esther Howard",
    lastMessage: "Hello Abdullah! I am...",
    image: AppAssets.avatarDefault,
    time: "8m ago",
  ),
  Chat(
    name: "Ralph Edwards",
    lastMessage: "Do you have update...",
    image: AppAssets.avatarDefault,
    time: "5d ago",
  ),
];
*/
