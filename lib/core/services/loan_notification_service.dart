import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Notificaciones locales para vencimientos de préstamos.
class LoanNotificationService {
  LoanNotificationService._();

  static final LoanNotificationService instance = LoanNotificationService._();

  /// Máximo de avisos horarios a programar (3 días).
  static const int _maxHourlySlots = 72;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  Future<void> ensureInitialized() async {
    if (_ready) return;

    try {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('America/Lima'));
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
      );

      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
        await androidPlugin?.createNotificationChannel(
          const AndroidNotificationChannel(
            'loan_due_dates',
            'Vencimientos de préstamos',
            description: 'Avisos del día en que debes pagar o te deben pagar',
            importance: Importance.high,
          ),
        );
      }

      _ready = true;
    } catch (e, st) {
      debugPrint('Finanza: notificaciones no inicializadas: $e\n$st');
      _ready = false;
    }
  }

  Future<bool> requestPermissionIfNeeded() async {
    await ensureInitialized();
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  /// Programa aviso el día de vencimiento a la hora elegida.
  /// Si [repeatHourly] es true, programa avisos cada hora desde esa hora.
  Future<void> scheduleDueReminder({
    required String loanId,
    required String title,
    required String body,
    required DateTime dueDate,
    int hour = 9,
    int minute = 0,
    bool repeatHourly = false,
  }) async {
    await ensureInitialized();
    if (!_ready) return;
    await cancel(loanId);

    final safeHour = hour.clamp(0, 23);
    final safeMinute = minute.clamp(0, 59);
    final now = tz.TZDateTime.now(tz.local);
    final first = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      safeHour,
      safeMinute,
    );

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'loan_due_dates',
        'Vencimientos de préstamos',
        channelDescription:
            'Avisos del día en que debes pagar o te deben pagar',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    try {
      if (!repeatHourly) {
        if (!first.isAfter(now)) return;
        await _plugin.zonedSchedule(
          id: _notificationId(loanId),
          title: title,
          body: body,
          scheduledDate: first,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: loanId,
        );
        return;
      }

      var slot = first;
      if (!slot.isAfter(now)) {
        final hoursAhead = now.difference(slot).inHours + 1;
        slot = slot.add(Duration(hours: hoursAhead));
      }

      for (var i = 0; i < _maxHourlySlots; i++) {
        final when = slot.add(Duration(hours: i));
        if (!when.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: _notificationId(loanId, offset: i),
          title: title,
          body: body,
          scheduledDate: when,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: loanId,
        );
      }
    } catch (e, st) {
      debugPrint('Finanza: no se pudo programar aviso: $e\n$st');
    }
  }

  Future<void> cancel(String loanId) async {
    await ensureInitialized();
    if (!_ready) return;
    try {
      for (var i = 0; i < _maxHourlySlots; i++) {
        await _plugin.cancel(id: _notificationId(loanId, offset: i));
      }
    } catch (e, st) {
      debugPrint('Finanza: no se pudo cancelar aviso: $e\n$st');
    }
  }

  int _notificationId(String loanId, {int offset = 0}) {
    final base = loanId.hashCode & 0x7ffff000;
    return (base + offset) & 0x7fffffff;
  }
}
