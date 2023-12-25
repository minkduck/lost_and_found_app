import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'Chat.dart';

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
    DocumentReference userDocumentReference = usersCollection.doc(
        "FLtIEJvuMgfg58u4sXhzxPn9qr73");
    DocumentReference userChatsDocumentReference = userChatsCollection.doc(
        "FLtIEJvuMgfg58u4sXhzxPn9qr73");

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

  Stream<List<Chat>> getMyChatsStream(String uid) {
    return userChatsCollection.doc(uid).snapshots().asyncMap((docSnapshot) async {
      var userChatsData = docSnapshot.data() as Map<String, dynamic>?;

      if (userChatsData != null) {
        var chatsList = <Chat>[];

        for (var entry in userChatsData.entries) {
          var chatId = entry.key;
          var chatData = entry.value as Map<String, dynamic>;

          var otherUid = chatData['uid'];

          var otherUserSnapshot = await ChatController().getUserUid(otherUid);
          var otherUserData = otherUserSnapshot.data();

          if (otherUserData != null) {
            var now = DateTime.now();
            var timeDifference = now.difference(chatData['date'].toDate());
            var formattedDate = '';

            if (timeDifference.inMinutes < 1) {
              formattedDate = 'just now';
            } else if (timeDifference.inHours < 1) {
              var minutesAgo = timeDifference.inMinutes;
              formattedDate = (minutesAgo == 1) ? '1 minute ago' : '$minutesAgo minutes ago';
            } else if (timeDifference.inHours < 24) {
              var hoursAgo = timeDifference.inHours;
              formattedDate = (hoursAgo == 1) ? '1 hour ago' : '$hoursAgo hours ago';
            } else if (timeDifference.inDays <= 7) {
              var daysAgo = timeDifference.inDays;
              formattedDate = (daysAgo == 1) ? '1 day ago' : '$daysAgo days ago';
            } else if (timeDifference.inDays <= 365) {
              formattedDate = DateFormat('dd-MM').format(chatData['date'].toDate());
            } else {
              formattedDate = DateFormat('dd-MM-yyyy').format(chatData['date'].toDate());
            }

            String chatId;

            if (otherUid.compareTo(uid) > 0) {
              chatId = otherUid + uid;
            } else {
              chatId = uid + otherUid;
            }

            var chat = Chat(
              uid: otherUid,
              name: otherUserData['displayName'],
              image: otherUserData['photoUrl'],
              lastMessage: chatData['lastMessage']['text'],
              chatId: chatId,
              formattedDate: formattedDate,
              time: formattedDate,
              date: chatData['date'].toDate(),
              otherId: otherUid
              // Add other fields accordingly
            );

            chatsList.add(chat);
          }
        }
        chatsList.sort((a, b) => b.date.compareTo(a.date));

        return chatsList;

      } else {
        return [];
      }
    });
  }

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

  Future<void> addMessage(String chatId, Map<String, dynamic> messageData, String userId, String otherId) async {
    try {
      // Create a reference to the specific chat document
      DocumentReference chatDocRef = chatsCollection.doc(chatId);

      // Add the new message to the messages array using FieldValue.arrayUnion()
      await chatDocRef.update({
        'messages': FieldValue.arrayUnion([messageData]),
      });
      DocumentReference userChatUserId = userChatsCollection.doc(userId);
      await userChatUserId.update({
        chatId : {
          // 'date': messageData['date'],
          'date': DateTime.now(),
          'lastMessage': {
            'text': messageData['text'],
          },
          'uid': otherId,
        }
      });
      DocumentReference userChatOtherId = userChatsCollection.doc(otherId);
      await userChatOtherId.update({
        chatId : {
          // 'date': messageData['date'],
          'date': DateTime.now(),
          'lastMessage': {
            'text': messageData['text'],
          },
          'uid': userId,
        }
      });
    } catch (e) {
      print('Error adding message: $e');
      throw e;
    }
  }

  Future<void> createUserChats(String myUid, String otherUid) async {
    // Check whether the group chats in Firestore exist, if not create
    String chatId =
    myUid.compareTo(otherUid) > 0 ? myUid + otherUid : otherUid + myUid;

    try {
      DocumentSnapshot chatDocSnapshot =
      await chatsCollection.doc(chatId).get();

      if (!chatDocSnapshot.exists) {
        // Create a chat in chats collection
        await chatsCollection.doc(chatId).set({'messages': []});

        // Create user chats
        await userChatsCollection.doc(myUid).update({
          '$chatId.uid': otherUid,
          '$chatId.date': FieldValue.serverTimestamp(),
          '$chatId.lastMessage.text': '',
        });

        await userChatsCollection.doc(otherUid).update({
          '$chatId.uid': myUid,
          '$chatId.date': FieldValue.serverTimestamp(),
          '$chatId.lastMessage.text': '',
        });
      }
    } catch (error) {
      print('Error handling chat: $error');
    }
  }
}