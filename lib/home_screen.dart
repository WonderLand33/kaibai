import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'notification_service.dart';
import 'settings_screen.dart';
import 'v2_theme.dart';

String _s(String text, bool privacy) =>
    privacy ? text.replaceAll('薪', '*') : text;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: V2Background(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(child: _buildBody(context)),
                ],
              ),
            ),
            _buildBroadcastOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
        color: V2Colors.background,
        border: Border(bottom: BorderSide(color: V2Colors.black, width: 4)),
        boxShadow: [
          BoxShadow(color: V2Colors.black, offset: Offset(8, 8), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_rounded, color: V2Colors.pink, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '开摆混底薪',
              textAlign: TextAlign.center,
              style: V2Text.headline.copyWith(fontSize: 23),
            ),
          ),
          GestureDetector(
            onTap: state.togglePrivacy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: state.privacyMode ? V2Colors.cyan : V2Colors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: V2Colors.black, width: 3),
              ),
              child: Row(
                children: [
                  Icon(
                    state.privacyMode
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: state.privacyMode ? Colors.black : V2Colors.muted,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.privacyMode ? '豆' : '元',
                    style: V2Text.mono.copyWith(
                      color: state.privacyMode ? Colors.black : V2Colors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _openSettings(context),
            child: const Icon(
              Icons.settings_rounded,
              color: V2Colors.pink,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        22,
        24,
        22,
        MediaQuery.of(context).padding.bottom + 32,
      ),
      child: Column(
        children: [
          _buildStatusHero(state),
          const SizedBox(height: 22),
          _buildTickerWindow(state),
          const SizedBox(height: 22),
          _buildPrimaryAction(context, state),
          const SizedBox(height: 20),
          _buildStatsGrid(state),
          if (state.withdrawDay >= 0) ...[
            const SizedBox(height: 22),
            _buildWithdrawCard(state),
          ],
          const SizedBox(height: 24),
          const V2Sticker(text: '躺着也能赚钱', angle: -0.11),
        ],
      ),
    );
  }

  Widget _buildStatusHero(AppState state) {
    final isWorking = state.status == WorkStatus.working;
    final isOffWork = state.status == WorkStatus.offWork;
    final imagePath = isOffWork
        ? 'assets/images/关机下班底薪到手.png'
        : 'assets/images/开机开始混底薪.png';

    final label = switch (state.status) {
      WorkStatus.idle => '准备摸鱼',
      WorkStatus.working => '摸鱼进行中',
      WorkStatus.offWork => '已下班',
    };

    return V2Card(
      color: isWorking ? V2Colors.pink : V2Colors.surface,
      padding: const EdgeInsets.all(14),
      radius: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: V2Colors.beige,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: V2Colors.black, width: 4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 18,
            child: V2Sticker(
              text: _s(isWorking ? '混底薪中' : '开机摸鱼', state.privacyMode),
              color: V2Colors.cyan,
              angle: -0.08,
              fontSize: 18,
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: V2Sticker(
              text: label,
              color: V2Colors.yellow,
              angle: 0.06,
              fontSize: 14,
            ),
          ),
          Positioned(
            right: -8,
            top: -8,
            child: _RoundSticker(
              text: isWorking ? '📈' : '🐟',
              color: isWorking ? V2Colors.green : V2Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTickerWindow(AppState state) {
    return V2Window(
      title: _s('今日已到账', state.privacyMode),
      titleColor: V2Colors.pink,
      child: Column(
        children: [
          _TickerAmount(
            amount: state.currentAmount,
            privacyMode: state.privacyMode,
          ),
          const SizedBox(height: 12),
          Text(
            _statusCopy(state),
            textAlign: TextAlign.center,
            style: V2Text.body.copyWith(color: V2Colors.cyanSoft),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AppState state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [
        _StatTile(
          icon: Icons.bolt_rounded,
          label: _s('当前时薪', state.privacyMode),
          value: state.fmtRate(state.hourlyRate),
          color: V2Colors.cyan,
          rotation: -0.025,
        ),
        _StatTile(
          icon: Icons.timer_rounded,
          label: _s('混底薪时长', state.privacyMode),
          value: state.durationStr,
          color: V2Colors.pink,
          rotation: 0.025,
        ),
        _StatTile(
          icon: Icons.trending_up_rounded,
          label: '摸鱼收益率',
          value: state.status == WorkStatus.working ? '420%' : '0%',
          color: V2Colors.yellow,
          rotation: 0.018,
        ),
        _StatTile(
          icon: Icons.psychology_alt_rounded,
          label: '老板状态',
          value: state.status == WorkStatus.working ? '蒙在鼓里' : '很安全',
          color: V2Colors.green,
          rotation: -0.018,
        ),
      ],
    );
  }

  Widget _buildWithdrawCard(AppState state) {
    final date = state.nextWithdrawDate!;
    final days = state.daysUntilWithdraw;
    final dateStr =
        '${date.month} 月 ${date.day} 日';
    final dayLabel = state.withdrawDay == 0
        ? '月底'
        : '每月 ${state.withdrawDay} 号';

    final urgentColor = days <= 3 ? V2Colors.green : V2Colors.yellow;

    return V2Window(
      title: _s('💸 工资提现日', state.privacyMode),
      titleColor: urgentColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: V2Text.headline.copyWith(
                    color: urgentColor,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayLabel,
                  style: V2Text.mono.copyWith(
                    color: V2Colors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: urgentColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: V2Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: V2Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  days == 0 ? '今天！' : '$days',
                  style: V2Text.headline.copyWith(
                    color: Colors.black,
                    fontSize: days == 0 ? 18 : 28,
                  ),
                ),
                if (days > 0)
                  Text(
                    '天后',
                    style: V2Text.mono.copyWith(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction(BuildContext context, AppState state) {
    if (state.status == WorkStatus.working) {
      return _SlideToStop(
        label: _s('滑动关机，底薪到手', state.privacyMode),
        onConfirmed: () {
          final summary = state.stopWork();
          _showSummaryDialog(context, summary);
        },
      );
    }

    final hasSetup = state.hasValidSettings;
    return Column(
      children: [
        V2Pressable(
          onTap: () {
            if (!hasSetup) {
              _openSettings(context);
            } else {
              state.startWork();
            }
          },
          color: V2Colors.green,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.power_settings_new_rounded,
                color: Colors.black,
                size: 28,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  _s(hasSetup ? '开机混底薪' : '先设置月薪', state.privacyMode),
                  textAlign: TextAlign.center,
                  style: V2Text.headline.copyWith(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.status == WorkStatus.offWork) ...[
          const SizedBox(height: 18),
          V2Pressable(
            onTap: state.resetForNewDay,
            color: V2Colors.cyan,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            radius: 14,
            child: Text(
              '明天继续自嗨',
              textAlign: TextAlign.center,
              style: V2Text.title.copyWith(color: Colors.black, fontSize: 17),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBroadcastOverlay(BuildContext context) {
    return ValueListenableBuilder<HourlyPayload?>(
      valueListenable: NotificationService.instance.inAppNotif,
      builder: (context, payload, _) {
        if (payload == null) return const SizedBox.shrink();
        return Positioned(
          top: MediaQuery.of(context).padding.top + 14,
          left: 18,
          right: 18,
          child: _BroadcastBanner(payload: payload),
        );
      },
    );
  }

  String _statusCopy(AppState state) {
    return switch (state.status) {
      WorkStatus.idle => _s('老板还不知道你准备开始混底薪。', state.privacyMode),
      WorkStatus.working => _s('正在用时间复利收割底薪，每秒都在到账。', state.privacyMode),
      WorkStatus.offWork => _s('今日底薪已落袋，建议保持低调。', state.privacyMode),
    };
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _showSummaryDialog(BuildContext context, WorkSummary summary) {
    Future.microtask(() {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SummaryDialog(summary: summary),
      );
    });
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double rotation;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: V2Card(
        color: color,
        padding: const EdgeInsets.all(13),
        radius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: V2Colors.black, width: 3),
              ),
              child: Icon(icon, color: Colors.black, size: 22),
            ),
            Text(
              label.toUpperCase(),
              style: V2Text.mono.copyWith(color: Colors.black, fontSize: 10),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: V2Text.title.copyWith(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundSticker extends StatelessWidget {
  final String text;
  final Color color;

  const _RoundSticker({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(color: V2Colors.black, spreadRadius: 3),
          BoxShadow(color: V2Colors.black, offset: Offset(5, 5), blurRadius: 0),
        ],
      ),
      child: Center(child: Text(text, style: const TextStyle(fontSize: 24))),
    );
  }
}

class _SlideToStop extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;

  const _SlideToStop({required this.label, required this.onConfirmed});

  @override
  State<_SlideToStop> createState() => _SlideToStopState();
}

class _SlideToStopState extends State<_SlideToStop>
    with SingleTickerProviderStateMixin {
  static const _thumbSize = 64.0;
  static const _trackHeight = 80.0;
  static const _threshold = 0.82;

  double _progress = 0.0;
  late AnimationController _snapCtrl;
  late Animation<double> _snapAnim;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _snapAnim = Tween<double>(begin: 0, end: 0).animate(_snapCtrl)
      ..addListener(() => setState(() => _progress = _snapAnim.value));
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d, double trackWidth) {
    if (_triggered) return;
    final max = trackWidth - _thumbSize;
    setState(() {
      _progress = ((_progress * max) + d.delta.dx).clamp(0, max) / max;
    });
  }

  void _onDragEnd(double trackWidth) {
    if (_triggered) return;
    if (_progress >= _threshold) {
      setState(() => _triggered = true);
      _snapAnim = Tween<double>(
        begin: _progress,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOut));
      _snapCtrl
        ..reset()
        ..forward().whenComplete(widget.onConfirmed);
    } else {
      _snapAnim = Tween<double>(
        begin: _progress,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOut));
      _snapCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final max = trackWidth - _thumbSize;
        final dx = _progress * max;

        return GestureDetector(
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, trackWidth),
          onHorizontalDragEnd: (_) => _onDragEnd(trackWidth),
          child: SizedBox(
            width: trackWidth,
            height: _trackHeight + 8,
            child: Stack(
              children: [
                Positioned.fill(
                  bottom: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [V2Colors.pink, V2Colors.yellow, V2Colors.cyan],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: V2Colors.black, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: V2Colors.black,
                          offset: Offset(8, 8),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  bottom: 8,
                  child: Center(
                    child: Opacity(
                      opacity: (1 - _progress * 1.35).clamp(0.0, 1.0),
                      child: Text(
                        widget.label,
                        style: V2Text.mono.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: dx,
                  top: 8,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: V2Colors.black, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: V2Colors.black,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('😆', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BroadcastBanner extends StatefulWidget {
  final HourlyPayload payload;

  const _BroadcastBanner({required this.payload});

  @override
  State<_BroadcastBanner> createState() => _BroadcastBannerState();
}

class _BroadcastBannerState extends State<_BroadcastBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Material(
          color: Colors.transparent,
          child: V2Card(
            color: V2Colors.cyan,
            padding: const EdgeInsets.all(14),
            radius: 18,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: V2Colors.black, width: 3),
                  ),
                  child: const Center(
                    child: Text(
                      '¥',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '工资到账',
                        style: V2Text.mono.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '到账 ${widget.payload.amount} ${widget.payload.unit}',
                        style: V2Text.title.copyWith(color: Colors.black),
                      ),
                      Text(
                        widget.payload.funText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: V2Text.body.copyWith(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TickerAmount extends StatelessWidget {
  final double amount;
  final bool privacyMode;

  const _TickerAmount({required this.amount, required this.privacyMode});

  @override
  Widget build(BuildContext context) {
    final numStr = amount.toStringAsFixed(2);
    final bigStyle = V2Text.headline.copyWith(
      fontSize: 58,
      color: V2Colors.yellow,
      shadows: [
        Shadow(color: V2Colors.yellow.withValues(alpha: 0.55), blurRadius: 14),
      ],
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (!privacyMode) Text('¥', style: bigStyle.copyWith(fontSize: 36)),
          ...numStr.characters.map((ch) {
            final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
            if (isDigit) return _TickerChar(char: ch, style: bigStyle);
            return Text(ch, style: bigStyle.copyWith(fontSize: 38));
          }),
          if (privacyMode) ...[
            const SizedBox(width: 8),
            Text('豆', style: bigStyle.copyWith(fontSize: 30)),
          ],
        ],
      ),
    );
  }
}

class _TickerChar extends StatefulWidget {
  final String char;
  final TextStyle style;

  const _TickerChar({required this.char, required this.style});

  @override
  State<_TickerChar> createState() => _TickerCharState();
}

class _TickerCharState extends State<_TickerChar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String _prev = '';
  String _cur = '';

  @override
  void initState() {
    super.initState();
    _prev = widget.char;
    _cur = widget.char;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_TickerChar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.char != widget.char) {
      _prev = oldWidget.char;
      _cur = widget.char;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = (widget.style.fontSize ?? 58) * 1.1;
    return ClipRect(
      child: SizedBox(
        height: height,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) {
            final value = _anim.value;
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Opacity(
                  opacity: (1 - value).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, -value * height),
                    child: Text(_prev, style: widget.style),
                  ),
                ),
                Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * height),
                    child: Text(_cur, style: widget.style),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryDialog extends StatelessWidget {
  final WorkSummary summary;

  const _SummaryDialog({required this.summary});

  String _timeStr(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final h = summary.duration.inHours;
    final m = summary.duration.inMinutes % 60;
    final durationText = h > 0 ? '$h 小时 $m 分钟' : '$m 分钟';
    final amountText = summary.privacyMode
        ? '${summary.amount.toStringAsFixed(2)} 豆'
        : '¥${summary.amount.toStringAsFixed(2)}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: V2Window(
        title: '下班成功',
        titleColor: V2Colors.green,
        bodyColor: V2Colors.beige,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              '老板毫无察觉',
              style: V2Text.headline.copyWith(
                color: Colors.black,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 18),
            V2Card(
              color: V2Colors.surface,
              shadow: false,
              child: Column(
                children: [
                  _row(
                    _s('今日底薪到手', summary.privacyMode),
                    amountText,
                    valueColor: V2Colors.yellow,
                  ),
                  _row(_s('混底薪时长', summary.privacyMode), durationText),
                  _row('开机时间', _timeStr(summary.startTime)),
                  _row('关机时间', _timeStr(summary.endTime)),
                  _row('到账播报', '${summary.broadcastCount} 次'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            V2Pressable(
              onTap: () => Navigator.pop(context),
              color: V2Colors.yellow,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Center(
                child: Text(
                  '收好工资，回家躺平',
                  style: V2Text.title.copyWith(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: V2Text.body.copyWith(color: V2Colors.muted)),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: V2Text.body.copyWith(
                color: valueColor ?? V2Colors.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
