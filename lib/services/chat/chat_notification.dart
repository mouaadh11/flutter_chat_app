import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/firebase_options.dart';
import 'package:flutter_chat_app/pages/chat_screen_page.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PendingChatTarget {
  const PendingChatTarget({
    required this.chatId,
    required this.messageId,
    required this.senderId,
    required this.receiverId,
  });

  final String chatId;
  final String messageId;
  final String senderId;
  final String receiverId;

  String get key => '$chatId:$messageId';

  static PendingChatTarget? fromMessageData(Map<String, dynamic> data) {
    final chatId = data['chatId']?.toString();
    final messageId = data['messageId']?.toString();
    final senderId = data['senderId']?.toString();
    final receiverId = data['receiverId']?.toString();

    if ([
      chatId,
      messageId,
      senderId,
      receiverId,
    ].any((value) => value == null || value.isEmpty)) {
      return null;
    }

    return PendingChatTarget(
      chatId: chatId!,
      messageId: messageId!,
      senderId: senderId!,
      receiverId: receiverId!,
    );
  }
}

class ChatNotification {
  ChatNotification._();

  static final ChatNotification _instance = ChatNotification._();

  factory ChatNotification() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GlobalKey<NavigatorState>? _navigatorKey;
  String? _lastUid;
  String? _lastToken;
  String? _lastHandledTargetKey;
  String? _activeChatUserId;
  PendingChatTarget? _pendingChatTarget;
  bool _initialized = false;

  Future<void> initNotifications(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    if (_initialized) return;
    _initialized = true;

    if (!_isAndroid) return;

    await _requestNotificationPermission();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        await _removeCurrentToken();
        return;
      }

      if (await areNotificationsEnabled()) {
        await _saveCurrentToken(user.uid);
      }
      await tryOpenPendingChat();
    });

    _messaging.onTokenRefresh.listen((token) async {
      final user = _auth.currentUser;
      if (user == null) return;
      if (!await areNotificationsEnabled()) return;

      await _saveToken(user.uid, token);
    });
  }

  Future<void> _requestNotificationPermission() async {
    await _messaging.requestPermission();
  }

  Future<void> _saveCurrentToken(String uid) async {
    if (!_isAndroid) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _saveToken(uid, token);
  }

  Future<void> _saveToken(String uid, String token) async {
    if (!_isAndroid) return;

    if (_lastUid != null && _lastUid != uid && _lastToken != null) {
      await _deleteToken(_lastUid!, _lastToken!);
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .set({
          'token': token,
          'platform': 'android',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    _lastUid = uid;
    _lastToken = token;
  }

  Future<void> _removeCurrentToken() async {
    if (_lastUid == null || _lastToken == null) return;

    await _deleteToken(_lastUid!, _lastToken!);
    _lastUid = null;
    _lastToken = null;
  }

  Future<void> removeCurrentTokenForUser(String uid) async {
    final token = _lastToken ?? await _messaging.getToken();
    if (token == null) return;

    await _deleteToken(uid, token);

    if (_lastUid == uid && _lastToken == token) {
      _lastUid = null;
      _lastToken = null;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final data = userDoc.data();

    return data?['notificationsEnabled'] != false;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'notificationsEnabled': enabled,
      'notificationsUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (enabled) {
      await _requestNotificationPermission();
      await _saveCurrentToken(user.uid);
    } else {
      await removeCurrentTokenForUser(user.uid);
    }
  }

  Future<void> _deleteToken(String uid, String token) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .delete();
  }

  void setActiveChat(String? userId) {
    _activeChatUserId = userId;
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    final target = PendingChatTarget.fromMessageData(message.data);
    if (target == null) return;

    if (_lastHandledTargetKey == target.key ||
        _pendingChatTarget?.key == target.key) {
      return;
    }

    _pendingChatTarget = target;
    await tryOpenPendingChat();
  }

  Future<void> tryOpenPendingChat() async {
    final target = _pendingChatTarget;
    final navigator = _navigatorKey?.currentState;
    final currentUser = _auth.currentUser;

    if (target == null || navigator == null || currentUser == null) {
      return;
    }

    if (currentUser.uid != target.receiverId) {
      _pendingChatTarget = null;
      return;
    }

    if (_activeChatUserId == target.senderId) {
      _lastHandledTargetKey = target.key;
      _pendingChatTarget = null;
      return;
    }

    final senderDoc = await _firestore
        .collection('users')
        .doc(target.senderId)
        .get();
    final senderData = senderDoc.data();
    if (senderData == null) {
      _pendingChatTarget = null;
      return;
    }

    final receiverName =
        (senderData['username'] ?? senderData['email'] ?? 'Unknown').toString();
    final receiverAvatarUrl = (senderData['avatarUrl'] ?? '').toString();

    navigator.popUntil((route) => route.isFirst);
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverName: receiverName,
          receiverAvatarUrl: receiverAvatarUrl,
          userId: target.senderId,
          receiverData: senderData,
        ),
      ),
    );

    _lastHandledTargetKey = target.key;
    _pendingChatTarget = null;
  }
}

bool get _isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
