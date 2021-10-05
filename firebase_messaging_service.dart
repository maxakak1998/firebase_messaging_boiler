import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hermes_flutter/commons/services/firebase_messing_service/custom_notification.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseMessagingService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final PublishSubject<CustomNotification> _streamController;
  final PublishSubject<CustomNotification> _pushClickStreamController;
  CustomNotification? lastClickedNotification;
  bool hasInit = false;

  FirebaseMessagingService()
      : _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(),
        _streamController = PublishSubject(),
        _pushClickStreamController = PublishSubject();

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel _channel;

  Future<RemoteMessage?> init() async {
    try {
      await _initFlutterLocalNotification();
      await _initFlutterMessaging();
      _initListener();
      hasInit = true;
    } catch (e) {
      hasInit = false;
    }
    if (hasInit) {
      final remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null && remoteMessage.data.isNotEmpty) {
        return remoteMessage;
      }
      return null;
    }
    return null;
  }

  void dispose() {
    _streamController.close();
    _pushClickStreamController.close();
    lastClickedNotification = null;
    hasInit = false;
  }

  void addListener(
      Function(CustomNotification notification) notificationCallback) {
    _streamController.listen(notificationCallback);
  }

  void addNotificationClickListener(
      Function(CustomNotification notification) notificationCallback) {
    _pushClickStreamController.listen(notificationCallback);
  }

  Future<void> _initFlutterLocalNotification() async {
    _channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification:
                onIosDidReceiveLocalNotificationForeground);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> _initFlutterMessaging() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedApp);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                _channel.description,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            payload: jsonEncode(message.data));
        if (message.data.isNotEmpty) {
          _streamController.add(CustomNotification.fromJson(message.data));
        }
      }
    });
  }

  void _initListener() {
    _pushClickStreamController.listen((value) {
      lastClickedNotification = value;
      FlutterAppBadger.removeBadge();
    });
  }

  Future onIosDidReceiveLocalNotificationForeground(
      int id, String? title, String? body, String? payload) async {
    ///apply for the ios > 10 when the notification is clicked in the foreground
    onSelectNotification(payload);
  }

  Future onSelectNotification(String? payload) async {
    ///open when the notification is clicked in the foreground
    print("payload is $payload");
    if (payload != null && payload.isNotEmpty) {
      final navigation = CustomNotification.fromPush(payload);
      requestNavigation(navigation);
    }
  }

  void _onOpenedApp(RemoteMessage event) {
    ///open when the notification is clicked in the background
    print("onOpenApp");
    if (event.data.isNotEmpty) {
      final navigation = CustomNotification.fromJson(event.data);
      requestNavigation(navigation);
    }
  }

  void requestNavigation(CustomNotification notification) {
    _pushClickStreamController.add(notification);
  }

}
