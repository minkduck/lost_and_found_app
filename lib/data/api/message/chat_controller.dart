import 'package:cloud_firestore/cloud_firestore.dart';

class ChatController {
  final String? uid;
  ChatController({this.uid});

  // reference for our collections
  final CollectionReference chatsCollection =
      FirebaseFirestore.instance.collection("chats");
  final CollectionReference userChatsCollection =
      FirebaseFirestore.instance.collection("userChats");
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
    await usersCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  gettingUserChats() async {
    DocumentReference userDocumentReference = usersCollection.doc("FLtIEJvuMgfg58u4sXhzxPn9qr73");
    DocumentReference userChatsDocumentReference = userChatsCollection.doc("FLtIEJvuMgfg58u4sXhzxPn9qr73");

    DocumentSnapshot documentSnapshot = await userChatsDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['userChats'];
    return groups;
  }

  getGroupChats(groupId) async {
    return chatsCollection.doc(groupId).snapshots();
  }

  getMyChats(myUid) async {
    return FirebaseFirestore.instance
        .collection("userChats")
        .doc(myUid)
        .get();
  }

  getUserUid(uid) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
  }

/*  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatDataStream(String chatId) {
    return chatsCollection
        .doc(chatId)
        .snapshots()
        .map((snapshot) => snapshot as DocumentSnapshot<Map<String, dynamic>>);
  }*/

    getChatData(chatId) async {
    return chatsCollection
        .doc(chatId)
        .get();
  }
}
