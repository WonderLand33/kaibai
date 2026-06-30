import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'notification_service.dart';
import 'settings_screen.dart';

// 正常模式金色，隐私模式紫色
Color _accent(bool privacy) =>
    privacy ? const Color(0xFFA78BFA) : const Color(0xFFFFD700);

// 隐私模式下把"薪"替换为"*"
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
      body: Stack(
        children: [
          _buildBg(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
          _buildAlipayOverlay(context),
        ],
      ),
    );
  }

  Widget _buildBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0A0A), Color(0xFF141414), Color(0xFF0A0A0A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final state = context.watch<AppState>();
    final ac = _accent(state.privacyMode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
      child: Row(
        children: [
          // Logo 颜色跟随主题
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: ac,
              letterSpacing: 2,
            ),
            child: const Text('开摆'),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Text(
              _s('混底薪神器', state.privacyMode),
              style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
            ),
          ),
          const Spacer(),
          // 防偷窥切换按钮
          GestureDetector(
            onTap: state.togglePrivacy,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: state.privacyMode
                    ? ac.withValues(alpha: 0.15)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.privacyMode
                      ? ac.withValues(alpha: 0.6)
                      : const Color(0xFF333333),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.privacyMode
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 14,
                    color: state.privacyMode ? ac : const Color(0xFF666666),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.privacyMode ? '豆' : '元',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          state.privacyMode ? ac : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_rounded,
                color: Color(0xFF555555), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 4),
          _buildStatusBanner(state),
          const SizedBox(height: 20),
          _buildPandaSection(state),
          const SizedBox(height: 20),
          _buildAmountCard(state),
          const SizedBox(height: 16),
          _buildStatsRow(state),
          const SizedBox(height: 28),
          _buildButtons(context, state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(AppState state) {
    final (text, color) = switch (state.status) {
      WorkStatus.idle => ('还没开机，先摸会儿鱼？🐟', const Color(0xFF555555)),
      WorkStatus.working => (_s('混底薪中 🐼', state.privacyMode), const Color(0xFF22C55E)),
      WorkStatus.offWork => ('美滋滋 🎉', const Color(0xFFFFD700)),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildPandaSection(AppState state) {
    final isOffWork = state.status == WorkStatus.offWork;
    final imagePath = isOffWork
        ? 'assets/images/关机下班底薪到手.png'
        : 'assets/images/开机开始混底薪.png';

    return Center(
      child: AnimatedScale(
        scale: state.status == WorkStatus.working ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 400),
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: state.status == WorkStatus.working
                ? [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    )
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(AppState state) {
    final amount = state.currentAmount;
    final isWorking = state.status == WorkStatus.working;
    final ac = _accent(state.privacyMode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWorking
              ? ac.withValues(alpha: 0.35)
              : const Color(0xFF222222),
        ),
        boxShadow: isWorking
            ? [
                BoxShadow(
                  color: ac.withValues(alpha: 0.06),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            '今日已到账',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          _TickerAmount(
            amount: amount,
            color: ac,
            privacyMode: state.privacyMode,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppState state) {
    // 隐私模式下"时薪"→"时豆"
    final rateLabel = _s('当前时薪', state.privacyMode);

    return Row(
      children: [
        Expanded(
          child: _statCard(
            emoji: '⚡',
            label: rateLabel,
            value: state.fmtRate(state.hourlyRate),
            color: const Color(0xFF60A5FA),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            emoji: '⏱️',
            label: _s('混底薪时长', state.privacyMode),
            value: state.durationStr,
            color: const Color(0xFFA78BFA),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String emoji,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF252525)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, AppState state) {
    return Column(
      children: [
        if (state.status == WorkStatus.idle ||
            state.status == WorkStatus.offWork) ...[
          _startButton(context, state),
          if (state.status == WorkStatus.offWork) ...[
            const SizedBox(height: 12),
            _resetButton(state),
          ],
        ],
        if (state.status == WorkStatus.working) _stopButton(context, state),
      ],
    );
  }

  Widget _startButton(BuildContext context, AppState state) {
    final hasSetup = state.hasValidSettings;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (!hasSetup) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          } else {
            state.startWork();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.power_settings_new_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              _s(hasSetup ? '开机，开始混底薪' : '先设置月薪，再混底薪 →', state.privacyMode),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stopButton(BuildContext context, AppState state) {
    return _SlideToStop(
      label: _s('滑动下班，底薪到手', state.privacyMode),
      onConfirmed: () {
        final summary = state.stopWork();
        _showSummaryDialog(context, summary);
      },
    );
  }

  Widget _resetButton(AppState state) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: state.resetForNewDay,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF333333)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          '明天继续自嗨 🐼',
          style: TextStyle(color: Color(0xFF666666), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildAlipayOverlay(BuildContext context) {
    return ValueListenableBuilder<HourlyPayload?>(
      valueListenable: NotificationService.instance.inAppNotif,
      builder: (context, payload, _) {
        if (payload == null) return const SizedBox.shrink();
        return Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: _AlipayBanner(payload: payload),
        );
      },
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

// ══════════════════════════════════════════════════════════
// 滑动关机按钮（iOS 滑动接听风格）
// ══════════════════════════════════════════════════════════

class _SlideToStop extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;
  const _SlideToStop({required this.label, required this.onConfirmed});

  @override
  State<_SlideToStop> createState() => _SlideToStopState();
}

class _SlideToStopState extends State<_SlideToStop>
    with SingleTickerProviderStateMixin {
  static const _thumbSize = 48.0;
  static const _trackHeight = 56.0;
  static const _threshold = 0.82; // 滑过 82% 触发

  double _progress = 0.0; // 0~1
  late AnimationController _snapCtrl;
  late Animation<double> _snapAnim;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
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
      // 滑满：触发关机
      setState(() => _triggered = true);
      _snapAnim = Tween<double>(begin: _progress, end: 1.0)
          .animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOut));
      _snapCtrl
        ..reset()
        ..forward().whenComplete(widget.onConfirmed);
    } else {
      // 未滑满：弹回起点
      _snapAnim = Tween<double>(begin: _progress, end: 0.0)
          .animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOut));
      _snapCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final trackWidth = constraints.maxWidth;
      final max = trackWidth - _thumbSize;
      final dx = _progress * max;

      return GestureDetector(
        onHorizontalDragUpdate: (d) => _onDragUpdate(d, trackWidth),
        onHorizontalDragEnd: (_) => _onDragEnd(trackWidth),
        child: SizedBox(
          width: trackWidth,
          height: _trackHeight,
          child: Stack(
            children: [
              // 轨道背景
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1010),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                  ),
                ),
              ),
              // 已划过区域高亮
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: dx + _thumbSize,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444).withValues(alpha: 0.6),
                        const Color(0xFFEF4444).withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // 提示文字（随进度淡出）
              Positioned.fill(
                child: Center(
                  child: Opacity(
                    opacity: (1 - _progress * 1.5).clamp(0.0, 1.0),
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              // 滑块
              Positioned(
                left: dx,
                top: (_trackHeight - _thumbSize) / 2,
                child: Container(
                  width: _thumbSize,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('😂', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════
// 支付宝到账横幅
// ══════════════════════════════════════════════════════════

class _AlipayBanner extends StatefulWidget {
  final HourlyPayload payload;
  const _AlipayBanner({required this.payload});

  @override
  State<_AlipayBanner> createState() => _AlipayBannerState();
}

class _AlipayBannerState extends State<_AlipayBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1677FF),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1677FF).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '支',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1677FF),
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('支付宝到账提醒',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        '到账 ${widget.payload.amount} ${widget.payload.unit}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        widget.payload.funText,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

// ══════════════════════════════════════════════════════════
// 金额滚动数字（股票跳动风格）
// ══════════════════════════════════════════════════════════

class _TickerAmount extends StatelessWidget {
  final double amount;
  final Color color;
  final bool privacyMode;

  const _TickerAmount({
    required this.amount,
    required this.color,
    required this.privacyMode,
  });

  @override
  Widget build(BuildContext context) {
    final numStr = amount.toStringAsFixed(2); // e.g. "286.40"

    final bigStyle = TextStyle(
      fontSize: 58,
      color: color,
      fontWeight: FontWeight.w900,
      height: 1,
    );
    final prefixStyle = TextStyle(
      fontSize: 28,
      color: color,
      fontWeight: FontWeight.w300,
      height: 1,
    );
    final suffixStyle = TextStyle(
      fontSize: 26,
      color: color,
      fontWeight: FontWeight.w700,
      height: 1,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 前缀 ¥ 或无
        if (!privacyMode)
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: prefixStyle,
            child: const Text('¥'),
          ),
        // 逐位数字
        ...numStr.characters.map((ch) {
          final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
          if (isDigit) {
            return _TickerChar(char: ch, style: bigStyle);
          }
          // 小数点：固定显示，不动画
          return Text(ch,
              style: bigStyle.copyWith(
                  fontSize: 36, fontWeight: FontWeight.w300));
        }),
        // 后缀 豆 或无
        if (privacyMode) ...[
          const SizedBox(width: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: suffixStyle,
            child: const Text('豆'),
          ),
        ],
      ],
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
        vsync: this, duration: const Duration(milliseconds: 180));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_TickerChar old) {
    super.didUpdateWidget(old);
    if (old.char != widget.char) {
      _prev = old.char;
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
    // 用 ClipRect 裁掉溢出，高度固定为字号 * 1.1
    final h = (widget.style.fontSize ?? 58) * 1.1;
    return ClipRect(
      child: SizedBox(
        height: h,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (ctx, child) {
            final v = _anim.value; // 0→1
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                // 旧数字：从原位向上飞出
                Opacity(
                  opacity: (1 - v).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, -v * h),
                    child: Text(_prev, style: widget.style),
                  ),
                ),
                // 新数字：从下方飞入
                Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, (1 - v) * h),
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

// ══════════════════════════════════════════════════════════
// 今日总结弹窗
// ══════════════════════════════════════════════════════════

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
    final amountLabel = _s('今日底薪到手', summary.privacyMode);

    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            const Text(
              '恭喜下班！',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              '明天继续自嗨。',
              style: TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _row(amountLabel, amountText,
                      valueColor: _accent(summary.privacyMode)),
                  _row(_s('混底薪时长', summary.privacyMode), durationText),
                  _row('开机时间', _timeStr(summary.startTime)),
                  _row('关机时间', _timeStr(summary.endTime)),
                  _row('到账播报', '${summary.broadcastCount} 次'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent(summary.privacyMode),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  '收好工资，回家躺平',
                  style:
                      TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Color(0xFF888888), fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
