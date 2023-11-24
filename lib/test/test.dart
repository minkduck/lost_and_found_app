import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/auth/google_sign_in.dart';
import 'package:lost_and_find_app/data/api/category/category_controller.dart';
import 'package:lost_and_find_app/data/api/comment/comment_controller.dart';
import 'package:lost_and_find_app/data/api/item/item_controller.dart';
import 'package:lost_and_find_app/data/api/location/location_controller.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';
import 'package:lost_and_find_app/utils/app_constraints.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/app_styles.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_drop_menu_filed_title.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:lost_and_find_app/widgets/generator_qrcode.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/api/message/chat_controller.dart';
import '../utils/app_assets.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/app_button.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Stream? member;
  final _productSizeList = ["Small", "Medium", "Large", "XLarge"];
  String? _selectedValue = "";
  late String fcmToken = "";
  late String accessToken = "";
  TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> userAndChatList = [];

  Future<void> fetchAndPrintUserChats() async {
    ChatController(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupChats("FzEZGbNisxb96Y8IaFC0nQ2S7Zr1FLtIEJvuMgfg58u4sXhzxPn9qr73")
        .then((val) {
      setState(() {
        member = val;
      });
      print("chats:" + member.toString());
    });
  }


  @override
  void initState() {
    super.initState();
    _selectedValue = _productSizeList[0];
    // Future<void> fetchAndPrintUserChats() async {
      ChatController(uid: FirebaseAuth.instance.currentUser!.uid)
          .getGroupChats("FzEZGbNisxb96Y8IaFC0nQ2S7Zr1FLtIEJvuMgfg58u4sXhzxPn9qr73")
          .then((val) {
        setState(() {
          member = val;
        });
        print("chats:" + member.toString());
      });
    // }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('hello'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // fcmToken = await AppConstrants.getFcmToken();
                // accessToken = await AppConstrants.getToken();
                // SnackbarUtils().showSuccess(title: "Success", message: "Login google successfully");
                // SnackbarUtils().showError(title: "Error", message: "Some thing wrong");
                // SnackbarUtils().showInfo(title: "Info", message: "Info");
                // SnackbarUtils().showLoading(message: "loading");
                // Get.find<ItemController>().getItemByUidList();
                // Get.find<CategoryController>().getCategoryGroupList();
                // Get.find<PostController>().getPostByUidList();
                // Get.find<LocationController>().getAllLocationPages();
                // Get.find<CommentController>().getCommentByPostId(1);
                fetchAndPrintUserChats();

              },
              child: Text('button'),
            ),
            Gap(AppLayout.getHeight(20)),
            Column(
              children:[
                // const GeneratorQrCode(data: "anh dung day tu chieu")
/*
              SizedBox(
                child: StreamBuilder(
                stream: member,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data['messages'] != null) {
                      final length = snapshot.data['messages'].length;
                      print("length: " + length);
                      if (snapshot.data['messages'].length != 0) {
                        return ListView.builder(
                          itemCount: snapshot.data['messages'].length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              child: Text(snapshot.data[index]['messages']['text'].toString()),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text("NO MEMBERS"),
                        );
                      }
                    } else {
                      return const Center(
                        child: Text("NO MEMBERS"),
                      );
                    }
                  } else {
                    return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ));
                  }
                },
            ),
              ),
*/
/*
                SizedBox(
                  child: StreamBuilder(
                    stream: member,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data?.data();
                        if (data != null && data['messages'] != null) {
                          final messages = List<Map<String, dynamic>>.from(data['messages']);
                          return ListView.builder(
                            itemCount: messages.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final text = message['text'];
                              final senderId = message['senderId'];
                              return ListTile(
                                title: Text('Sender: $senderId'),
                                subtitle: Text('Message: $text'),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text("NO MESSAGES"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      }
                    },
                  ),
                ),
*/
/*
                SizedBox(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("userChats").snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        // Lấy danh sách các documents từ snapshot
                        List<DocumentSnapshot> documents = snapshot.data!.docs;

                        // Duyệt qua danh sách documents và in ra toàn bộ dữ liệu từ mỗi document
                        for (DocumentSnapshot document in documents) {
                          // Lấy dữ liệu từ document
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                          // In ra toàn bộ dữ liệu để xem cấu trúc của nó
                          print("Document Data: $data");

                          // TODO: Sử dụng dữ liệu ở đây, ví dụ: hiển thị trong ListView
                        }

                        // TODO: Trả về widget hiển thị danh sách hoặc một phần nào đó của dữ liệu
                        return Text(documents.toString());
                      } else {
                        // Nếu snapshot chưa có dữ liệu, hiển thị một widget khác, ví dụ: CircularProgressIndicator
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      }
                    },
                  ),
                )
*/
                SizedBox(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("userChats").snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        // Lấy danh sách các documents từ snapshot
                        List<DocumentSnapshot> documents = snapshot.data!.docs;

                        // Kiểm tra nếu danh sách không rỗng và lấy dữ liệu từ document đầu tiên
                        if (documents.isNotEmpty) {
                          // Lấy dữ liệu từ document đầu tiên
                          Map<String, dynamic> data = documents[0].data() as Map<String, dynamic>;

                          // TODO: Sử dụng dữ liệu ở đây, ví dụ: hiển thị trong ListView

                          // Iterate over each UID in the document
                          data.forEach((uid, userData) {
                            // Perform your action here
                            var uidUser = userData['uid'];

                            // Retrieve data for each UID
                            FirebaseFirestore.instance.collection("users").doc(uidUser).get().then((userSnapshot) {
                              if (userSnapshot.exists) {
                                // Retrieve data from the user document
                                Map<String, dynamic> userMap = userSnapshot.data() as Map<String, dynamic>;

                                // Create a Map to store user and user chat information
                                Map<String, dynamic> userAndChatInfo = {
                                  'user': userMap,
                                  'userChat': {'uid': uidUser, 'lastMessage': userData['lastMessage'], 'timeLastMessage': userData['date']},
                                };

                                // Add the Map to the list
                                userAndChatList.add(userAndChatInfo);
                                // TODO: Use the user and user chat data as needed
                              } else {
                                // The user document does not exist
                                print("User document for UID $uidUser does not exist.");
                              }
                            });
                          });
                          print(userAndChatList.toString());

                          // Trả về widget hiển thị dữ liệu
                          return Column(
                            children: [
                              Text("User and Chat List: ${userAndChatList.toString()}"),
                            ],
                          );
                        } else {
                          // Nếu danh sách rỗng, hiển thị một widget thông báo
                          return Text('No documents found.');
                        }
                      } else {
                        // Nếu snapshot chưa có dữ liệu, hiển thị một widget khác, ví dụ: CircularProgressIndicator
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      }
                    },
                  ),
                )



              ]
            )
          ],
        ),
      ),
    );
  }
}
