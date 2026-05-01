import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/models/message.dart';
import 'package:flutter_chat_app/services/chat/chat_notification.dart';

class ChatServices {
  //get firebase instance
  final FirebaseFirestore firebase = FirebaseFirestore.instance;
  final ChatNotification chatNotificationService = ChatNotification();
  FirebaseFirestore get firebaseIns => firebase; // if it's currently private

  //get users stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return firebase.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  //get recent chats (users we've messaged with)
  Stream<List<Map<String, dynamic>>> getRecentChatsStream() {
    final currentUser = getCurrentUser();
    if (currentUser == null) return Stream.value([]);
    final currentUserId = currentUser.uid;

    return firebase
        .collection('chats')
        .where('participants', arrayContains: currentUserId) // ✅ direct query
        .snapshots()
        .asyncMap((snapshot) async {
          final List<Map<String, dynamic>> recentUsers = [];

          for (final doc in snapshot.docs) {
            final participants = List<String>.from(doc['participants']);
            final otherUserId = participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) continue;

            final userDoc = await firebase
                .collection('users')
                .doc(otherUserId)
                .get();

            if (userDoc.exists) {
              recentUsers.add(userDoc.data()!);
            }
          }
          return recentUsers;
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

    //create a chat id by combining sender and receiver ids (sorted alphabetically)
    String chatId = senderId.hashCode <= receiverId.hashCode
        ? '$senderId-$receiverId'
        : '$receiverId-$senderId';

    print(
      "================ chatId (send): $chatId ==================================",
    );
    final chatRef = firebase.collection('chats').doc(chatId);

    // ✅ Explicitly write the chat document so it shows up in collection queries
    await chatRef.set(
      {
        'participants': [senderId, receiverId],
      },
      SetOptions(merge: true),
    ); // merge:true so you don't overwrite on each send

    await chatRef.collection('messages').add(newMessage.toMap());
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
    print("====================chatId (get): $chatId ========================");
    return firebase
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final message = doc.data();
            return message;
          }).toList();
        });
  }

  final Map<String, StreamSubscription> _chatSubscriptions = {};

  void msgNotification() {
    final currentUser = getCurrentUser();
    if (currentUser == null) return;

    firebase
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .listen((chatSnapshot) {
          for (final chatDoc in chatSnapshot.docs) {
            final chatId = chatDoc.id;

            // ✅ Avoid duplicate listeners
            if (_chatSubscriptions.containsKey(chatId)) continue;

            final sub = chatDoc.reference
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots()
                .listen((msgSnapshot) {
                  if (msgSnapshot.docs.isEmpty) return;

                  final msg = msgSnapshot.docs.first.data();

                  final senderId = msg['senderId'];
                  final text = msg['text'] ?? '';
                  final timestamp = msg['timestamp'];
                  print(
                    "======================= senderID $senderId ==============================",
                  );
                  print(
                    "======================= text $text ==============================",
                  );
                  print(
                    "======================= timestamp $timestamp ==============================",
                  );
                  if (senderId == currentUser.uid) return;

                  if (timestamp != null) {
                    final messageTime = DateTime.parse(timestamp);

                    final age = DateTime.now()
                        .difference(messageTime)
                        .inSeconds;
                    if (age > 5) return;
                  }
                  chatNotificationService.showNotification(text);
                });
            print(
              "======================= Age hadhak howa ==============================",
            );

            _chatSubscriptions[chatId] = sub;
          }
        });
  }
}
