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
  late List<_Particle> _particles;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(35, (_) => _createParticle());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isPlaying) _controller.forward();
  }

  _Particle _createParticle() {
    // Gold/amber palette only — professional, not childish
    final colors = [
      const Color(0xFFF5A623),
      const Color(0xFFD4930D),
      const Color(0xFFE8B84B),
      const Color(0xFFC8873A),
      const Color(0xFFFFD700),
      const Color(0xFFB8860B),
    ];
    return _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble() * -0.5,
      size: _rng.nextDouble() * 6 + 3,
      speed: _rng.nextDouble() * 0.25 + 0.1,
      wobble: _rng.nextDouble() * 2 - 1,
      rotation: _rng.nextDouble() * pi * 2,
      rotationSpeed: (_rng.nextDouble() - 0.5) * 0.08,
      color: colors[_rng.nextInt(colors.length)],
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
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x, y;
  final double size, speed, wobble;
  double rotation;
  final double rotationSpeed;
  final Color color;

  _Particle({
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

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Fade out in last 30%
    final fadeOut = progress > 0.7
        ? 1.0 - ((progress - 0.7) / 0.3)
        : 1.0;

    for (final p in particles) {
      final currentY = (p.y + progress * p.speed * 3.5) % 1.2 - 0.2;
      final wobbleOffset = sin(progress * pi * 3 + p.wobble * pi) * 0.025;
      final currentX = p.x + wobbleOffset;
      final currentRotation = p.rotation + progress * p.rotationSpeed * pi * 6;

      final dx = currentX * size.width;
      final dy = currentY * size.height;

      if (dy < -20 || dy > size.height + 20) continue;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(currentRotation);

      final alpha = (fadeOut * (1 - currentY).clamp(0.2, 1.0)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          Radius.circular(p.size * 0.15),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
