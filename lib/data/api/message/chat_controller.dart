import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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

  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatDataStream(String chatId) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .snapshots()
        .map((snapshot) => snapshot as DocumentSnapshot<Map<String, dynamic>>);
  }

  Future<void> sendMessage(String chatId, String text, String senderId) async {
    try {
      // Get a reference to the messages collection under the specific chatId
      CollectionReference messagesCollection = FirebaseFirestore.instance.collection("chats/$chatId/messages");
      print('messagesCollection' + messagesCollection.toString());
      // Add a new document to the messages collection with the message data
      await messagesCollection.add({
        'id': Uuid().v4(), // Generating a unique ID using the uuid package
        'text': text,
        'senderId': senderId,
        'date': FieldValue.serverTimestamp(), // Using server timestamp for date
      });

      // Update the last message timestamp in the chat metadata for sorting chats
      await FirebaseFirestore.instance.collection("chats").doc(chatId).update({
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
      throw e; // Re-throw the exception to handle it in the UI if needed
    }
  }
}
