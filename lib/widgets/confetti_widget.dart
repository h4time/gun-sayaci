import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final bool isPlaying;

  const ConfettiWidget({super.key, this.isPlaying = true});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(60, (_) => _createParticle());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  ConfettiParticle _createParticle() {
    return ConfettiParticle(
      x: _random.nextDouble(),
      y: _random.nextDouble() * -1,
      size: _random.nextDouble() * 8 + 4,
      speed: _random.nextDouble() * 0.3 + 0.1,
      wobble: _random.nextDouble() * 2 - 1,
      rotation: _random.nextDouble() * pi * 2,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
      color: [
        const Color(0xFFFF6B6B),
        const Color(0xFFFFD93D),
        const Color(0xFF6BCB77),
        const Color(0xFF4D96FF),
        const Color(0xFFC77DFF),
        const Color(0xFFFF9A8B),
        const Color(0xFFFF6C9B),
        const Color(0xFF00D2FF),
      ][_random.nextInt(8)],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final double wobble;
  double rotation;
  final double rotationSpeed;
  final Color color;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.wobble,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y + progress * p.speed * 4) % 1.3 - 0.3;
      final wobbleOffset = sin(progress * pi * 4 + p.wobble * pi) * 0.03;
      final currentX = p.x + wobbleOffset;
      final currentRotation = p.rotation + progress * p.rotationSpeed * pi * 8;

      final dx = currentX * size.width;
      final dy = currentY * size.height;

      if (dy < -20 || dy > size.height + 20) continue;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(currentRotation);

      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - currentY).clamp(0.3, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          Radius.circular(p.size * 0.1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
