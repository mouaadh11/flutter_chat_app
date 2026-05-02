import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_chat_app/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("==================== rani fi al func li manach 3arfin wash tdir");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class ChatNotification {
  ChatNotification._();

  static final ChatNotification _instance = ChatNotification._();

  factory ChatNotification() => _instance;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _lastUid;
  String? _lastToken;
  bool _initialized = false;

  Future<void> initNotifications() async {
    if (_initialized) return;
    _initialized = true;

    if (!_isAndroid) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'messages',
      'Messages',
      importance: Importance.high,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _requestNotificationPermission();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_showForegroundMessage);

    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        await _removeCurrentToken();
        return;
      }

      await _saveCurrentToken(user.uid);
    });

    _messaging.onTokenRefresh.listen((token) async {
      final user = _auth.currentUser;
      if (user == null) return;

      await _saveToken(user.uid, token);
    });
  }

  Future<void> _requestNotificationPermission() async {
    await _messaging.requestPermission();

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
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

  Future<void> _deleteToken(String uid, String token) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .delete();
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? 'New Message';
    final body = notification?.body ?? message.data['body'] ?? '';

    if (body.isEmpty) return;

    await showNotification(body, title: title);
  }

  Future<void> showNotification(
    String message, {
    String title = 'New Message',
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'messages', //kan 3andi channel_id
          'Messages',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.show(0, title, message, details);
  }
}

bool get _isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
