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
              recentUsers.add({
                ...userDoc.data()!,
                'lastMessage': doc['lastMessage'],
                'lastMessageTime': doc['lastMessageTime'],
              });
            }
          }
          return recentUsers;
        });
  }
  // Stream<List<Map<String, dynamic>>> getRecentChatsStream() {
  //   final currentUser = getCurrentUser();
  //   print("the current user is ${currentUser?.email}");
  //   if (currentUser == null) {
  //     return Stream.value([]);
  //   }

  //   final currentUserId = currentUser.uid;
  //   print("the current user id is $currentUserId");

  //   return firebase.collection('chats').snapshots().map((snapshot) async {
  //     final List<Map<String, dynamic>> recentUsers = [];
  //     final Set<String> processedUserIds = {}; // Avoid duplicates

  //     for (final doc in snapshot.docs) {
  //       final chatId = doc.id;
  //       String? otherUserId;

  //       // Try to find the other user ID in the chat ID
  //       // Format 1 (new): userId1-userId2 (alphabetically sorted)
  //       final parts = chatId.split('-');
  //       print(parts);
  //       if (parts.length == 2) {
  //         // Check if current user ID is in the chat ID (new format)
  //         if (parts[0] == currentUserId) {
  //           otherUserId = parts[1];
  //         } else if (parts[1] == currentUserId) {
  //           otherUserId = parts[0];
  //         }
  //       }

  //       if (otherUserId != null && !processedUserIds.contains(otherUserId)) {
  //         processedUserIds.add(otherUserId);
  //         // Get the other user's data
  //         final userDoc = await firebase.collection('users').doc(otherUserId).get();
  //         if (userDoc.exists) {
  //           recentUsers.add(userDoc.data()!);
  //         }
  //       }
  //     }
  //     return recentUsers;
  //   });
  // }

  //get current user stream
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  //send message
  Future<void> sendMessage(String message, String receiverId) async {
  final currentUser = getCurrentUser()!;
  final senderId = currentUser.uid;

  final chatId = senderId.compareTo(receiverId) < 0
      ? '$senderId-$receiverId'
      : '$receiverId-$senderId';

  final chatRef = firebase.collection('chats').doc(chatId);

  // ✅ Explicitly write the chat document so it shows up in collection queries
  await chatRef.set({
    'participants': [senderId, receiverId],
    'lastMessage': message,
    'lastMessageTime': Timestamp.now(),
  }, SetOptions(merge: true)); // merge:true so you don't overwrite on each send

  await chatRef.collection('messages').add({
    'senderId': senderId,
    'receiverId': receiverId,
    'message': message,
    'timestamp': Timestamp.now(),
  });
}

  // Future<void> sendMessage(String message, String receiverId) async {
  //   final currentUser = getCurrentUser();
  //   if (currentUser == null) {
  //     throw Exception("User not authenticated");
  //   }
  //   final senderEmail = currentUser.email;
  //   final senderId = currentUser.uid;
  //   final timestamp = DateTime.now();

  //   Message newMessage = Message(
  //     text: message,
  //     senderId: senderId,
  //     timestamp: timestamp,
  //     sednerEmail: senderEmail!,
  //     receiverId: receiverId,
  //   );
  //   //create a chat id by combining sender and receiver ids (sorted alphabetically)
  //   String chatId = senderId.compareTo(receiverId) < 0
  //       ? '$senderId-$receiverId'
  //       : '$receiverId-$senderId';
  //   //create a new document in the messages collection with the message data
  //   await firebase
  //       .collection('chats')
  //       .doc(chatId)
  //       .collection('messages')
  //       .add(newMessage.toMap());
  // }

  //get messages stream
  Stream<List<Map<String, dynamic>>> getMessagesStream(String receiverId) {
    final currentUser = getCurrentUser();
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }
    final senderId = currentUser.uid;
    String chatId = senderId.compareTo(receiverId) < 0
        ? '$senderId-$receiverId'
        : '$receiverId-$senderId';

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
}
