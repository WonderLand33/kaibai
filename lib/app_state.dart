import 'dart:async';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'notification_service.dart';

enum WorkStatus { idle, working, offWork }

enum PaymentMethod { alipay, wechat }

class WorkSummary {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final double amount;
  final int broadcastCount;
  final bool privacyMode;

  WorkSummary({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.amount,
    required this.broadcastCount,
    required this.privacyMode,
  });
}

class AppState extends ChangeNotifier {
  // ─── 薪资设置 ───
  double monthlySalary = 0;
  int monthlyRestDays = 4;
  double dailyWorkHours = 8;
  bool privacyMode = false;
  PaymentMethod paymentMethod = PaymentMethod.alipay;

  // ─── 工作状态 ───
  WorkStatus status = WorkStatus.idle;
  DateTime? workStartTime;
  DateTime? workEndTime;
  Duration _accumulated = Duration.zero;
  int _lastNotifiedHour = 0;
  int hourlyBroadcastCount = 0;

  Timer? _ticker;
  bool _settingsValid = false;

  // ─── 初始化 ───
  Future<void> init() async {
    await _load();
    if (status == WorkStatus.working && workStartTime != null) {
      _startTicker();
    }
  }

  // ─── 计算属性 ───

  int get _daysInCurrentMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  double get hourlyRate {
    if (monthlySalary <= 0) return 0;
    final workDays = _daysInCurrentMonth - monthlyRestDays;
    if (workDays <= 0 || dailyWorkHours <= 0) return 0;
    return monthlySalary / workDays / dailyWorkHours;
  }

  Duration get currentWorkDuration {
    if (status == WorkStatus.working && workStartTime != null) {
      return _accumulated + DateTime.now().difference(workStartTime!);
    }
    return _accumulated;
  }

  double get currentAmount =>
      currentWorkDuration.inSeconds * hourlyRate / 3600;

  bool get hasValidSettings => _settingsValid && monthlySalary > 0;

  String get unitSymbol => privacyMode ? '' : '¥';
  String get unitWord => privacyMode ? '豆' : '元';

  String fmtAmount(double v) {
    if (privacyMode) return '${v.toStringAsFixed(2)} 豆';
    return '¥${v.toStringAsFixed(2)}';
  }

  String fmtRate(double v) {
    if (privacyMode) return '${v.toStringAsFixed(2)} 豆/小时';
    return '¥${v.toStringAsFixed(2)}/小时';
  }

  String get durationStr {
    final d = currentWorkDuration;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ─── 操作 ───

  void startWork() {
    if (status == WorkStatus.working) return;
    _accumulated = Duration.zero;
    workStartTime = DateTime.now();
    workEndTime = null;
    status = WorkStatus.working;
    _lastNotifiedHour = 0;
    hourlyBroadcastCount = 0;
    _startTicker();
    _save();
    notifyListeners();
  }

  WorkSummary stopWork() {
    _accumulated = currentWorkDuration;
    workEndTime = DateTime.now();
    final sum = WorkSummary(
      startTime: workStartTime ?? workEndTime!,
      endTime: workEndTime!,
      duration: _accumulated,
      amount: currentAmount,
      broadcastCount: hourlyBroadcastCount,
      privacyMode: privacyMode,
    );
    workStartTime = null;
    status = WorkStatus.offWork;
    _ticker?.cancel();
    NotificationService.instance.cancelAll();
    _save();
    notifyListeners();
    return sum;
  }

  void resetForNewDay() {
    if (status == WorkStatus.offWork) {
      status = WorkStatus.idle;
      _accumulated = Duration.zero;
      workStartTime = null;
      workEndTime = null;
      _lastNotifiedHour = 0;
      hourlyBroadcastCount = 0;
      _save();
      notifyListeners();
    }
  }

  void togglePrivacy() {
    privacyMode = !privacyMode;
    _saveSettings();
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod m) {
    paymentMethod = m;
    _saveSettings();
    notifyListeners();
  }

  void updateSettings({
    required double salary,
    required int restDays,
    required double workHours,
  }) {
    monthlySalary = salary;
    monthlyRestDays = restDays;
    dailyWorkHours = workHours;
    _settingsValid = true;
    _saveSettings();
    notifyListeners();
  }

  // ─── 计时器 ───

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkHourBoundary();
      notifyListeners();
    });
  }

  void _checkHourBoundary() {
    final completedHours = currentWorkDuration.inSeconds ~/ 3600;
    if (completedHours > _lastNotifiedHour) {
      _lastNotifiedHour = completedHours;
      hourlyBroadcastCount++;
      NotificationService.instance.triggerHourlyBroadcast(
        hourlyRate: hourlyRate,
        privacyMode: privacyMode,
        paymentMethod: paymentMethod,
      );
    }
  }

  // ─── 持久化 ───

  Future<void> _load() async {
    final p = await StorageService.instance.prefs;
    monthlySalary = p.getDouble('monthlySalary') ?? 0;
    monthlyRestDays = p.getInt('monthlyRestDays') ?? 4;
    dailyWorkHours = p.getDouble('dailyWorkHours') ?? 8;
    privacyMode = p.getBool('privacyMode') ?? false;
    final pmStr = p.getString('paymentMethod') ?? 'alipay';
    paymentMethod = PaymentMethod.values.firstWhere(
      (e) => e.name == pmStr,
      orElse: () => PaymentMethod.alipay,
    );
    _settingsValid = monthlySalary > 0;

    _accumulated = Duration(seconds: p.getInt('accumulatedSeconds') ?? 0);
    final startMs = p.getInt('workStartMs');
    final statusStr = p.getString('workStatus') ?? 'idle';
    _lastNotifiedHour = p.getInt('lastNotifiedHour') ?? 0;
    hourlyBroadcastCount = p.getInt('broadcastCount') ?? 0;

    if (statusStr == 'working' && startMs != null) {
      workStartTime = DateTime.fromMillisecondsSinceEpoch(startMs);
      status = WorkStatus.working;
    } else if (statusStr == 'offWork') {
      status = WorkStatus.offWork;
      final endMs = p.getInt('workEndMs');
      if (endMs != null) {
        workEndTime = DateTime.fromMillisecondsSinceEpoch(endMs);
      }
    } else {
      status = WorkStatus.idle;
    }

    notifyListeners();
  }

  Future<void> _save() async {
    await _saveSettings();
    final p = await StorageService.instance.prefs;
    await p.setString('workStatus', status.name);
    await p.setInt('accumulatedSeconds', _accumulated.inSeconds);
    await p.setInt('lastNotifiedHour', _lastNotifiedHour);
    await p.setInt('broadcastCount', hourlyBroadcastCount);
    if (workStartTime != null) {
      await p.setInt('workStartMs', workStartTime!.millisecondsSinceEpoch);
    }
    if (workEndTime != null) {
      await p.setInt('workEndMs', workEndTime!.millisecondsSinceEpoch);
    }
  }

  Future<void> _saveSettings() async {
    final p = await StorageService.instance.prefs;
    await p.setDouble('monthlySalary', monthlySalary);
    await p.setInt('monthlyRestDays', monthlyRestDays);
    await p.setDouble('dailyWorkHours', dailyWorkHours);
    await p.setBool('privacyMode', privacyMode);
    await p.setString('paymentMethod', paymentMethod.name);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
