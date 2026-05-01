import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatNotification {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(settings);
  }

  Future<void> showNotification(String message) async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'channel_id',
        'Messages',
        importance: Importance.max,
        priority: Priority.high,
      );

  const NotificationDetails details =
      NotificationDetails(android: androidDetails);

  await notificationsPlugin.show(
    0,
    'New Message',
    message,
    details,
  );
}


}
