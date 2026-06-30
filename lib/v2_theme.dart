import 'package:flutter/material.dart';

class V2Colors {
  static const background = Color(0xFF171305);
  static const surface = Color(0xFF23200F);
  static const surfaceHigh = Color(0xFF393522);
  static const beige = Color(0xFFF4EBD0);
  static const onSurface = Color(0xFFEBE2C8);
  static const muted = Color(0xFFDCBFC9);
  static const pink = Color(0xFFFF69B4);
  static const pinkSoft = Color(0xFFFFB0D0);
  static const cyan = Color(0xFF00F1FD);
  static const cyanSoft = Color(0xFFDCFDFF);
  static const yellow = Color(0xFFF5E700);
  static const green = Color(0xFF39FF14);
  static const black = Color(0xFF050505);
}

class V2Text {
  static const headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    height: 1.05,
    letterSpacing: -0.8,
    color: V2Colors.yellow,
  );

  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    height: 1.1,
    color: V2Colors.onSurface,
  );

  static const mono = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    color: V2Colors.onSurface,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: V2Colors.onSurface,
  );
}

class V2Background extends StatelessWidget {
  final Widget child;

  const V2Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: V2Colors.background,
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.1,
          colors: [Color(0xFF2B2410), V2Colors.background],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
          child,
        ],
      ),
    );
  }
}

class V2Card extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool shadow;

  const V2Card({
    super.key,
    required this.child,
    this.color = V2Colors.surface,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: V2Colors.black, width: 4),
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: V2Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class V2Window extends StatelessWidget {
  final String title;
  final Widget child;
  final Color titleColor;
  final Color bodyColor;

  const V2Window({
    super.key,
    required this.title,
    required this.child,
    this.titleColor = V2Colors.pink,
    this.bodyColor = V2Colors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return V2Card(
      padding: EdgeInsets.zero,
      color: bodyColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: titleColor,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: V2Text.mono.copyWith(color: Colors.black),
                    ),
                  ),
                  const Text(
                    '● ● ●',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(16), child: child),
          ],
        ),
      ),
    );
  }
}

class V2Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;

  const V2Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.color = V2Colors.green,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.radius = 18,
  });

  @override
  State<V2Pressable> createState() => _V2PressableState();
}

class _V2PressableState extends State<V2Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(
          _pressed ? 6 : 0,
          _pressed ? 6 : 0,
          0,
        ),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: V2Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: V2Colors.black,
              offset: _pressed ? Offset.zero : const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class V2Sticker extends StatelessWidget {
  final String text;
  final Color color;
  final double angle;
  final double fontSize;

  const V2Sticker({
    super.key,
    required this.text,
    this.color = V2Colors.yellow,
    this.angle = -0.08,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(color: V2Colors.black, spreadRadius: 3),
            BoxShadow(
              color: V2Colors.black,
              offset: Offset(5, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.045);
    const gap = 24.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
