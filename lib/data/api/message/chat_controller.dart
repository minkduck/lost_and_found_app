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
}
