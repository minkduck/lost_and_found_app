import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_find_app/data/api/message/chat_controller.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/data/api/message/Chat.dart';
import 'package:uuid/uuid.dart';

import '../../utils/app_constraints.dart';
import '../../widgets/app_button_upload_image.dart';
import 'message_tile.dart';

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

  final ImagePicker _imagePicker = ImagePicker();
  XFile? imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
      String imagePath = pickedFile.path;
      // await _sendImageMessage(imagePath);
    }
  }

  Future<void> takePicture() async {
    final XFile? picture = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      imageFile = picture;
      setState(() {});
    }
  }

  void removeImage() {
    setState(() {
      imageFile = null; // Clear the imageFile
    });
  }


  Future<dynamic> listChatData() async {
    try {
      var chatData = await ChatController().getChatData(widget.chat.chatId);

      print('Chat Data: $chatData');

      if (chatData.exists) {
        var chatMetadata = chatData.data();
        return chatMetadata?['messages'];
      } else {
        print('Chat not found.');
        return null; // Return null or an empty list based on your use case
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null; // Return null or an empty list based on your use case
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
                      child: ReverseListView(
                        reverse: true,
                        children: List.generate(
                          messagesData.length,
                              (index) {
                            var messageData = messagesData[index];
                            return MessageTile(
                              message: messageData['text'] ?? "",
                              sender: messageData['senderId'],
                              sentByMe: messageData['senderId'] == widget.chat.uid,
                              imageUrl: messageData['img'],
                            );
                          },
                        ),
                      )

                    ),
                    Column(
                      children: [
                        if (imageFile != null)
                          Stack(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                child: Image.file(
                                  File(imageFile!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -10,
                                right: -10,
                                child: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.times,
                                    color: AppColors.primaryColor,
                                  ),
                                  onPressed: () {
                                    removeImage();
                                  },
                                ),
                              ),
                            ],
                          ),
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
                              Gap(AppLayout.getWidth(10)),
                              GestureDetector(
                                onTap: () async {
                                  String messageText = messageController.text;
                                  print(messageText);

                                  if (imageFile != null && messageText.isNotEmpty) {
                                    await _sendImageMessage(imageFile!.path);
                                    setState(() {
                                      imageFile = null;
                                    });
                                    await sendMessage(messageText);
                                    messageController.clear();
                                  } else if (messageText.isNotEmpty) {
                                    await sendMessage(messageText);
                                    messageController.clear();
                                  } else if (imageFile != null) {
                                    await _sendImageMessage(imageFile!.path);
                                    setState(() {
                                      imageFile = null;
                                    });
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
                              Gap(AppLayout.getWidth(10)),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        // Make the content size fit its children
                                        children: [
                                          AppButtonUpLoadImage(
                                            boxColor: AppColors.primaryColor,
                                            textButton: "Take a photo",
                                            onTap: () {
                                              takePicture();
                                              Navigator.pop(
                                                  context); // Close the dialog after taking a photo
                                            },
                                          ),
                                          Gap(AppLayout.getHeight(20)),
                                          // Add a gap between the buttons
                                          AppButtonUpLoadImage(
                                            boxColor: AppColors.secondPrimaryColor,
                                            textButton: "Upload photo",
                                            onTap: () {
                                              _pickImage();
                                              Navigator.pop(
                                                  context); // Close the dialog after selecting an image
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  });
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
                                      Icons.image,
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
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> sendMessage(String messageText) async {
    try {
      Map<String, dynamic> newMessage = {
        'date': DateTime.now().millisecondsSinceEpoch,
        'id': Uuid().v4(),
        'senderId': myUid,
        'text': messageText,
      };

      await ChatController().addMessage(widget.chat.chatId, newMessage, myUid, widget.chat.otherId);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

/*
  Future<void> _sendImageMessage(String imagePath) async {
    try {
      String messageText = '';

      Reference storageRef = FirebaseStorage.instance.ref().child('images/${Uuid().v4()}');

      UploadTask uploadTask = storageRef.putFile(File(imagePath));

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        // Handle upload progress if needed
        // final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // print('Upload progress: $progress');
      });

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      Map<String, dynamic> newMessage = {
        'date': DateTime.now().millisecondsSinceEpoch,
        'id': Uuid().v4(),
        'senderId': myUid,
        'text': messageText,
        'img': downloadURL,
      };

      await ChatController().addMessage(widget.chat.chatId, newMessage, myUid, widget.chat.otherId);
    } catch (e) {
      print('Error sending image message: $e');
    }
  }
*/


  Future<void> _sendImageMessage(String imagePath) async {
    try {
      String messageText = ''; // You can add a message text here if needed

      // Create a reference to the Firebase Storage location with a dynamic path
      Reference storageRef = FirebaseStorage.instance.ref().child('images/${Uuid().v4()}');

      // Upload the image to Firebase Storage with its content type
      UploadTask uploadTask = storageRef.putFile(
        File(imagePath),
        SettableMetadata(contentType: 'image/jpeg'), // Adjust the content type based on your needs
      );

      // Wait for the upload to complete
      await uploadTask.whenComplete(() => null);

      // Get the download URL of the uploaded image
      String downloadURL = await storageRef.getDownloadURL();

      // Create a new message map
      Map<String, dynamic> newMessage = {
        'date': DateTime.now().millisecondsSinceEpoch,
        'id': Uuid().v4(),
        'senderId': myUid,
        'text': messageText,
        'img': downloadURL,
      };

      // Add the new message to the chat
      await ChatController().addMessage(widget.chat.chatId, newMessage, myUid, widget.chat.otherId);
    } catch (e) {
      print('Error sending image message: $e');
    }
  }
}
class ReverseListView extends StatelessWidget {
  final bool reverse;
  final List<Widget> children;

  ReverseListView({
    required this.reverse,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      reverse: reverse,
      physics: BouncingScrollPhysics(),
      children: children.reversed.toList(),
    );
  }
}
