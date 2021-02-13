import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../service_locator.dart';
import '../ui/beacon/beacon_view.dart';
import 'navigation.dart';

/// LocalNotificationService
class LocalNotificationService {
  final _navigation = servicesLocator<NavigationService>();

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// for iOS version < 10
  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    showDialog(
      context: _navigation.currentContext,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BeaconView(),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  /// for iOS version > 10
  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    _navigation.pushNamed(routeName: '/');
  }

  /// showNotification
  Future<void> showNotification(String title, String body) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Notification Title
      body, // Notification Body, set as null to remove the body
      platformChannelSpecifics,
      payload: 'New Payload', // Notification Payload
    );
  }

  /// showDelayedNotification
  Future<void> showDelayedNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Delayed Title',
        'Delayed Body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3)),
        platformChannelSpecifics,
        payload: 'Delay Payload',
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  /// showScheduledNotification
  Future<void> showScheduledNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'Scheduled Title',
      'Scheduleed Body',
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      payload: 'Scheduled Payload',
      androidAllowWhileIdle: true,
    );
  }

  /// detailedScheduledNotification
  Future<void> detailedScheduleNotification() async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'detailed scheduled notification title',
        'detailed scheduled notification body',
        _nextInstanceOfDate(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'detailed notification channel id',
              'detailed notification channel name',
              'detailed notificationdescription'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  tz.TZDateTime _nextInstanceOfDate() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, 2021, 1, 19, 5, 39);
    print(scheduledDate);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// cancelNotification
  Future<void> cancelNotification(int index) async {
    await _flutterLocalNotificationsPlugin.cancel(index);
    print('cancel No.$index notifications');
  }

  /// cancelNotifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('cancel all notifications');
  }

  /// initLocalNotification
  void initLocalNotification() async {
    tz.initializeTimeZones();

    // ignore: lines_longer_than_80_chars
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const initializationSettingsAndroid = AndroidInitializationSettings('');

    final initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final initializationSettingsMacOS = MacOSInitializationSettings();

    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }
}
