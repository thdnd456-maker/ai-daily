// 휴식 타이머: 종료 시각을 DB에 저장해 앱을 종료/재실행해도 이어지며,
// 백그라운드에서는 예약 알림(진동 포함)으로 휴식 종료를 알립니다.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'providers.dart';

class Notifications {
  static final plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static const _restId = 1001;

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(requestAlertPermission: false, requestSoundPermission: false, requestBadgePermission: false),
        ),
      );
      _ready = true;
    } catch (_) {
      _ready = false; // 테스트 환경 등 플러그인이 없는 경우
    }
  }

  static Future<void> requestPermission() async {
    if (!_ready) return;
    await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, sound: true);
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'rest_timer',
      '휴식 타이머',
      channelDescription: '세트 간 휴식 종료 알림',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    ),
    iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
  );

  static Future<void> scheduleRestEnd(DateTime endAt) async {
    if (!_ready) return;
    try {
      final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final exact = await android?.canScheduleExactNotifications() ?? false;
      await plugin.zonedSchedule(
        id: _restId,
        title: '휴식 종료',
        body: '다음 세트를 시작하세요 💪',
        scheduledDate: tz.TZDateTime.from(endAt.toUtc(), tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  static Future<void> cancelRest() async {
    if (!_ready) return;
    try {
      await plugin.cancel(id: _restId);
    } catch (_) {}
  }
}

class RestTimerState {
  final DateTime? endAt;
  final int totalSec;
  final DateTime now;
  const RestTimerState({this.endAt, this.totalSec = 0, required this.now});

  bool get running => endAt != null && endAt!.isAfter(now);
  int get remaining => endAt == null ? 0 : (endAt!.difference(now).inMilliseconds / 1000).ceil().clamp(0, 99999);
  double get progress => totalSec == 0 ? 0 : (1 - remaining / totalSec).clamp(0, 1);
}

class RestTimerController extends Notifier<RestTimerState> {
  Timer? _ticker;

  @override
  RestTimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    _restore();
    return RestTimerState(now: DateTime.now());
  }

  Future<void> _restore() async {
    final repo = ref.read(repositoryProvider);
    final end = DateTime.tryParse(await repo.getSetting('rest.endAt') ?? '');
    final total = int.tryParse(await repo.getSetting('rest.total') ?? '') ?? 0;
    if (end != null && end.isAfter(DateTime.now())) {
      state = RestTimerState(endAt: end, totalSec: total, now: DateTime.now());
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final now = DateTime.now();
      final wasRunning = state.running;
      state = RestTimerState(endAt: state.endAt, totalSec: state.totalSec, now: now);
      if (wasRunning && !state.running) {
        _ticker?.cancel();
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 300), HapticFeedback.heavyImpact);
        SystemSound.play(SystemSoundType.alert);
        _persist(null, 0);
      }
    });
  }

  Future<void> _persist(DateTime? end, int total) async {
    final repo = ref.read(repositoryProvider);
    await repo.setSetting('rest.endAt', end?.toIso8601String());
    await repo.setSetting('rest.total', end == null ? null : '$total');
  }

  Future<void> start(int seconds) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    state = RestTimerState(endAt: end, totalSec: seconds, now: DateTime.now());
    _startTicker();
    await _persist(end, seconds);
    await Notifications.cancelRest();
    await Notifications.scheduleRestEnd(end);
  }

  Future<void> add(int seconds) async {
    if (!state.running) return start(seconds);
    final end = state.endAt!.add(Duration(seconds: seconds));
    final total = (state.totalSec + seconds).clamp(1, 3600);
    state = RestTimerState(endAt: end, totalSec: total, now: DateTime.now());
    await _persist(end, total);
    await Notifications.cancelRest();
    await Notifications.scheduleRestEnd(end);
  }

  Future<void> stop() async {
    _ticker?.cancel();
    state = RestTimerState(now: DateTime.now());
    await _persist(null, 0);
    await Notifications.cancelRest();
  }
}

final restTimerProvider = NotifierProvider<RestTimerController, RestTimerState>(RestTimerController.new);
