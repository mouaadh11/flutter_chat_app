import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/models/message.dart';

class ChatServices {
  //get firebase instance
  final FirebaseFirestore firebase = FirebaseFirestore.instance;

  //get users stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return firebase.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  //get current user stream
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  //send message
  Future<void> sendMessage(String message, String receiverId) async {
    final currentUser = getCurrentUser();
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }
    final senderEmail = currentUser.email;
    final senderId = currentUser.uid;
    final timestamp = DateTime.now();

    Message newMessage = Message(
      text: message,
      senderId: senderId,
      timestamp: timestamp,
      sednerEmail: senderEmail!,
      receiverId: receiverId,
    );
    //create a chat id by combining sender and receiver ids
    String chatId = senderId.hashCode <= receiverId.hashCode
        ? '$senderId-$receiverId'
        : '$receiverId-$senderId';
    //create a new document in the messages collection with the message data
    await firebase
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //get messages stream
  Stream<List<Map<String, dynamic>>> getMessagesStream(String receiverId) {
    final currentUser = getCurrentUser();
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }
    final senderId = currentUser.uid;
    String chatId = senderId.hashCode <= receiverId.hashCode
        ? '$senderId-$receiverId'
        : '$receiverId-$senderId';
        
        return firebase
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots().map((snapshot) {
          return snapshot.docs.map((doc) {
            final message = doc.data();
            return message;
          }).toList();
        });
        
  }
}
