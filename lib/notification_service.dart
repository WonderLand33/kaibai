import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'app_state.dart' show PaymentMethod;

class HourlyPayload {
  final String amount;
  final String unit;
  final String funText;
  final DateTime timestamp;

  HourlyPayload({
    required this.amount,
    required this.unit,
    required this.funText,
    required this.timestamp,
  });
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _tts = FlutterTts();
  bool _ttsConfigured = false;
  final inAppNotif = ValueNotifier<HourlyPayload?>(null);

  // 系统通知支持平台：Android / iOS / macOS / Linux
  // Windows 系统通知 flutter_local_notifications v18 未完整支持，用 in-app 替代
  bool get _supportsSystemNotif {
    if (kIsWeb) return false;
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isLinux;
  }

  // TTS 支持平台：除 Linux / Web 外
  bool get _supportsTts {
    if (kIsWeb) return false;
    return !Platform.isLinux;
  }

  Future<void> init() async {
    await _initNotifications();
    await _initTts();
  }

  Future<void> _initNotifications() async {
    if (!_supportsSystemNotif) return;

    final android = Platform.isAndroid
        ? const AndroidInitializationSettings('@mipmap/ic_launcher')
        : null;

    final darwin = (Platform.isIOS || Platform.isMacOS)
        ? const DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: false,
            requestSoundPermission: false,
          )
        : null;

    final linux = Platform.isLinux
        ? const LinuxInitializationSettings(defaultActionName: '查看')
        : null;

    await _plugin.initialize(
      InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
      ),
    );
  }

  Future<void> _initTts() async {
    if (!_supportsTts) return;
    // 安卓的 TTS 引擎是异步绑定的，这里只做最轻量的配置；
    // 真正的语言/语速设置放到首次 speak 前惰性完成，避免引擎未就绪时抛异常。
    try {
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}
    // 尝试预热配置，失败也无所谓（speak 前会再配一次）
    await _configureTts();
  }

  /// 惰性配置 TTS，幂等。引擎就绪后任意一次成功即可。
  Future<bool> _configureTts() async {
    if (!_supportsTts) return false;
    if (_ttsConfigured) return true;
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.85);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ttsConfigured = true;
      return true;
    } catch (_) {
      // 引擎还没绑定，下次 speak 再试
      return false;
    }
  }

  Future<void> _speak(String text) async {
    if (!_supportsTts) return;
    // 每次播报前确保已配置（首次或引擎重连后）
    await _configureTts();
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: false, sound: false);
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: false, sound: false);
    }
  }

  String _ttsText(String amount, String unit, PaymentMethod method) {
    return switch (method) {
      PaymentMethod.alipay => '支付宝到账$amount$unit',
      PaymentMethod.wechat => '微信收款$amount$unit',
    };
  }

  String _notifTitle(PaymentMethod method, bool privacyMode) {
    final t = switch (method) {
      PaymentMethod.alipay => '支付宝到账提醒',
      PaymentMethod.wechat => '微信收款提醒',
    };
    return _s(t, privacyMode);
  }

  /// 试听：与每小时播报走完全一致的流程（覆盖层 + 语音 + 系统通知）。
  Future<void> previewTTS(
      double hourlyRate, bool privacyMode, PaymentMethod method) async {
    await _broadcast(
      hourlyRate: hourlyRate,
      privacyMode: privacyMode,
      paymentMethod: method,
    );
  }

  Future<void> triggerHourlyBroadcast({
    required double hourlyRate,
    required bool privacyMode,
    required PaymentMethod paymentMethod,
  }) async {
    await _broadcast(
      hourlyRate: hourlyRate,
      privacyMode: privacyMode,
      paymentMethod: paymentMethod,
    );
  }

  Future<void> _broadcast({
    required double hourlyRate,
    required bool privacyMode,
    required PaymentMethod paymentMethod,
  }) async {
    final amountStr = hourlyRate.toStringAsFixed(2);
    final unit = privacyMode ? '豆' : '元';
    final funText = _s('本小时底薪已到账', privacyMode);

    // in-app 覆盖层（所有平台）
    final payload = HourlyPayload(
      amount: amountStr,
      unit: unit,
      funText: funText,
      timestamp: DateTime.now(),
    );
    inAppNotif.value = payload;

    // TTS 语音播报
    _speak(_ttsText(amountStr, unit, paymentMethod));

    // 系统通知
    if (_supportsSystemNotif) {
      _showSystemNotification(amountStr, unit, paymentMethod, privacyMode);
    }

    Future.delayed(const Duration(seconds: 4), () {
      if (inAppNotif.value?.timestamp == payload.timestamp) {
        inAppNotif.value = null;
      }
    });
  }

  Future<void> _showSystemNotification(
    String amount,
    String unit,
    PaymentMethod method,
    bool privacyMode,
  ) async {
    final title = _notifTitle(method, privacyMode);
    final word = switch (method) {
      PaymentMethod.alipay => '支付宝到账',
      PaymentMethod.wechat => '微信收款',
    };
    final body = _s('$word $amount $unit', privacyMode);

    NotificationDetails details;

    if (Platform.isAndroid) {
      details = const NotificationDetails(
        android: AndroidNotificationDetails(
          'hourly_arrival',
          '每小时到账提醒',
          channelDescription: '每满一小时播报一次底薪到账',
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
          enableVibration: true,
        ),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      details = const NotificationDetails(
        iOS: DarwinNotificationDetails(presentSound: false),
        macOS: DarwinNotificationDetails(presentSound: false),
      );
    } else if (Platform.isLinux) {
      details = const NotificationDetails(
        linux: LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.normal,
        ),
      );
    } else {
      return;
    }

    await _plugin.show(0, title, body, details).catchError((_) {});
  }

  Future<void> cancelAll() async {
    if (_supportsSystemNotif) {
      await _plugin.cancelAll().catchError((_) {});
    }
    if (_supportsTts) _tts.stop().catchError((_) {});
    inAppNotif.value = null;
  }

  String _s(String text, bool privacy) =>
      privacy ? text.replaceAll('薪', '*') : text;
}
