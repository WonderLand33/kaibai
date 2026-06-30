import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _salary;
  late int _restDays;
  late double _workHours;
  late PaymentMethod _paymentMethod;

  // 月薪快捷预设
  static const _salaryPresets = [3000, 5000, 6000, 8000, 10000, 12000, 15000, 20000, 30000];
  static const _salaryStep = 500;

  // 月休天数选项
  static const _restOptions = [
    _Option(value: 0,  label: '无休',  sub: '卷王'),
    _Option(value: 4,  label: '单休',  sub: '4天'),
    _Option(value: 8,  label: '双休',  sub: '8天'),
    _Option(value: 12, label: '大休',  sub: '12天'),
  ];

  // 每日工作时长选项
  static const _hourOptions = [
    _Option(value: 6,  label: '6小时',  sub: '摸鱼王'),
    _Option(value: 7,  label: '7小时',  sub: '佛系'),
    _Option(value: 8,  label: '8小时',  sub: '正常人'),
    _Option(value: 9,  label: '9小时',  sub: '微加班'),
    _Option(value: 10, label: '10小时', sub: '大厂味'),
    _Option(value: 12, label: '12小时', sub: '996'),
  ];

  // 自定义输入控制器
  late TextEditingController _salaryInputCtrl;
  late TextEditingController _restInputCtrl;
  late TextEditingController _hoursInputCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _salary = s.monthlySalary > 0 ? s.monthlySalary : 8000;
    _restDays = s.monthlyRestDays;
    _workHours = s.dailyWorkHours;
    _paymentMethod = s.paymentMethod;
    _salaryInputCtrl = TextEditingController();
    _restInputCtrl = TextEditingController();
    _hoursInputCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _salaryInputCtrl.dispose();
    _restInputCtrl.dispose();
    _hoursInputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF888888)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('薪资设置',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHint(),
              const SizedBox(height: 28),
              _buildSalarySection(),
              const SizedBox(height: 28),
              _buildRestDaysSection(),
              const SizedBox(height: 28),
              _buildWorkHoursSection(),
              const SizedBox(height: 28),
              _buildPaymentMethodSection(),
              const SizedBox(height: 28),
              _buildPreview(),
              const SizedBox(height: 28),
              _buildSaveButton(),
              const SizedBox(height: 12),
              _buildPrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 提示 ───

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: const Row(
        children: [
          Text('🔒', style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '数据仅保存在本机，不联网不上传。',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 月薪 ───

  Widget _buildSalarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('💰', '月薪'),
        const SizedBox(height: 14),
        // 大号数字 + 加减
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Row(
            children: [
              _circleBtn(icon: Icons.remove, onTap: () => setState(() {
                _salary = (_salary - _salaryStep).clamp(500, 99999);
                _salaryInputCtrl.clear();
              })),
              Expanded(
                child: Column(
                  children: [
                    Text('¥ ${_salary.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFFFFD700), fontSize: 36, fontWeight: FontWeight.w900)),
                    const Text('元 / 月',
                        style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
                  ],
                ),
              ),
              _circleBtn(icon: Icons.add, onTap: () => setState(() {
                _salary = (_salary + _salaryStep).clamp(500, 99999);
                _salaryInputCtrl.clear();
              })),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 快捷预设
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _salaryPresets.map((v) {
            final selected = _salary == v.toDouble();
            return GestureDetector(
              onTap: () => setState(() { _salary = v.toDouble(); _salaryInputCtrl.clear(); }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFFFD700).withValues(alpha: 0.15) : const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? const Color(0xFFFFD700) : const Color(0xFF333333)),
                ),
                child: Text(
                  v >= 10000 ? '${(v / 10000).toStringAsFixed(v % 10000 == 0 ? 0 : 1)}万' : v.toString(),
                  style: TextStyle(
                    color: selected ? const Color(0xFFFFD700) : const Color(0xFF888888),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // 自定义输入
        _customInput(
          ctrl: _salaryInputCtrl,
          hint: '自定义金额（元）',
          onSubmitted: (v) {
            final n = double.tryParse(v);
            if (n != null && n > 0) setState(() => _salary = n.clamp(1, 999999));
          },
        ),
      ],
    );
  }

  // ─── 月休天数 ───

  Widget _buildRestDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('🏖️', '每月休息天数'),
        const SizedBox(height: 14),
        Row(
          children: _restOptions.map((o) {
            final selected = _restDays == o.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() { _restDays = o.value; _restInputCtrl.clear(); }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF60A5FA).withValues(alpha: 0.15) : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? const Color(0xFF60A5FA) : const Color(0xFF333333),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(o.label, style: TextStyle(
                            color: selected ? const Color(0xFF60A5FA) : Colors.white,
                            fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(o.sub, style: TextStyle(
                            color: selected ? const Color(0xFF60A5FA).withValues(alpha: 0.7) : const Color(0xFF666666),
                            fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _customInput(
          ctrl: _restInputCtrl,
          hint: '自定义天数',
          onSubmitted: (v) {
            final n = int.tryParse(v);
            if (n != null && n >= 0 && n < 31) setState(() => _restDays = n);
          },
        ),
      ],
    );
  }

  // ─── 每日工作时长 ───

  Widget _buildWorkHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('⏰', '每日工作时长'),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _hourOptions.map((o) {
            final selected = _workHours == o.value.toDouble();
            return GestureDetector(
              onTap: () => setState(() { _workHours = o.value.toDouble(); _hoursInputCtrl.clear(); }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFA78BFA).withValues(alpha: 0.15) : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? const Color(0xFFA78BFA) : const Color(0xFF333333),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(o.label, style: TextStyle(
                        color: selected ? const Color(0xFFA78BFA) : Colors.white,
                        fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(o.sub, style: TextStyle(
                        color: selected ? const Color(0xFFA78BFA).withValues(alpha: 0.7) : const Color(0xFF666666),
                        fontSize: 11)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _customInput(
          ctrl: _hoursInputCtrl,
          hint: '自定义小时数（如 7.5）',
          onSubmitted: (v) {
            final n = double.tryParse(v);
            if (n != null && n > 0 && n <= 24) setState(() => _workHours = n);
          },
        ),
      ],
    );
  }

  // ─── 收款方式 + TTS 试听 ───

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('📣', '到账播报方式'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _paymentCard(
              method: PaymentMethod.alipay,
              label: '支付宝',
              emoji: '💙',
              preview: '支付宝到账 XX 元',
              color: const Color(0xFF1677FF),
            )),
            const SizedBox(width: 12),
            Expanded(child: _paymentCard(
              method: PaymentMethod.wechat,
              label: '微信',
              emoji: '💚',
              preview: '微信收款 XX 元',
              color: const Color(0xFF07C160),
            )),
          ],
        ),
        const SizedBox(height: 16),
        // 试听按钮
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: _previewTTS,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF444444)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF888888)),
            label: const Text('试听播报效果', style: TextStyle(color: Color(0xFF888888))),
          ),
        ),
      ],
    );
  }

  Widget _paymentCard({
    required PaymentMethod method,
    required String label,
    required String emoji,
    required String preview,
    required Color color,
  }) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : const Color(0xFF333333),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(
                  color: selected ? color : Colors.white,
                  fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (selected) Icon(Icons.check_circle, color: color, size: 16),
            ]),
            const SizedBox(height: 8),
            Text(preview,
                style: TextStyle(
                    color: selected ? color.withValues(alpha: 0.8) : const Color(0xFF666666),
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ─── 实时预览 ───

  Widget _buildPreview() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final workDays = daysInMonth - _restDays;
    final rate = workDays > 0 && _workHours > 0 ? _salary / workDays / _workHours : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 实时预览',
              style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          _previewRow('当月工作天数', '$workDays 天'),
          _previewRow('当前时薪', rate > 0 ? '¥${rate.toStringAsFixed(2)}/小时' : '-', highlight: true),
          _previewRow('播报文案',
              _paymentMethod == PaymentMethod.alipay
                  ? '支付宝到账 ${rate.toStringAsFixed(2)} 元'
                  : '微信收款 ${rate.toStringAsFixed(2)} 元'),
        ],
      ),
    );
  }

  Widget _previewRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: highlight ? const Color(0xFFFFD700) : Colors.white,
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── 保存按钮 ───

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text('保存设置，开始混底薪',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return const Center(
      child: Text('提示：首页右上角可开启防偷窥模式，元变豆',
          style: TextStyle(fontSize: 11, color: Color(0xFF555555))),
    );
  }

  // ─── 工具方法 ───

  Widget _sectionTitle(String emoji, String label) {
    return Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF444444)),
        ),
        child: Icon(icon, color: const Color(0xFFFFD700), size: 20),
      ),
    );
  }

  Widget _customInput({
    required TextEditingController ctrl,
    required String hint,
    required void Function(String) onSubmitted,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 13),
        prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFF555555), size: 18),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  void _previewTTS() {
    final state = context.read<AppState>();
    NotificationService.instance.previewTTS(
      state.hourlyRate > 0 ? state.hourlyRate : 38.46,
      state.privacyMode,
      _paymentMethod,
    );
  }

  void _save() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    if (_restDays >= daysInMonth) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('休息天数不能大于当月天数'),
        backgroundColor: Color(0xFFEF4444),
      ));
      return;
    }
    final state = context.read<AppState>();
    state.updateSettings(salary: _salary, restDays: _restDays, workHours: _workHours);
    state.setPaymentMethod(_paymentMethod);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('设置已保存 🎉'),
      backgroundColor: Color(0xFF22C55E),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

class _Option {
  final int value;
  final String label;
  final String sub;
  const _Option({required this.value, required this.label, required this.sub});
}
