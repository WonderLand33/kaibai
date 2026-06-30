import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'app_state.dart';
import 'home_screen.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && _isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(420, 780),
        minimumSize: Size(360, 640),
        center: true,
        title: '开摆 - 混底薪神器',
        backgroundColor: Color(0xFF0D0D0D),
        skipTaskbar: false,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
    await _initTray();
  }

  await NotificationService.instance.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const KaibaiApp(),
    ),
  );
}

Future<void> _initTray() async {
  // 使用 app 图标作为托盘图标
  await trayManager.setIcon(
    Platform.isWindows
        ? 'assets/images/app_icon.png'
        : 'assets/images/app_icon.png',
  );
  await trayManager.setToolTip('开摆 - 混底薪神器 🐼');
  await trayManager.setContextMenu(Menu(
    items: [
      MenuItem(key: 'show', label: '🐼  显示开摆'),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: '🚪  退出'),
    ],
  ));
}

bool get _isDesktop =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

class KaibaiApp extends StatelessWidget {
  const KaibaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '开摆',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFF22C55E),
          surface: Color(0xFF1A1A1A),
          error: Color(0xFFEF4444),
        ),
        useMaterial3: true,
      ),
      home: const _TrayHandler(child: HomeScreen()),
    );
  }
}

// 处理托盘菜单点击
class _TrayHandler extends StatefulWidget {
  final Widget child;
  const _TrayHandler({required this.child});

  @override
  State<_TrayHandler> createState() => _TrayHandlerState();
}

class _TrayHandlerState extends State<_TrayHandler> with TrayListener {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb && _isDesktop) trayManager.addListener(this);
  }

  @override
  void dispose() {
    if (!kIsWeb && _isDesktop) trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayMenuItemClick(MenuItem item) {
    switch (item.key) {
      case 'show':
        windowManager.show();
        windowManager.focus();
      case 'quit':
        windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
