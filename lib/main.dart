import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'start_night_screen.dart';
import 'join_squad_screen.dart';
import 'how_it_works_screen.dart';

void main() {
  runApp(const PubGolfApp());
}

// ─── Design System ────────────────────────────────────────────────────────────
class PubGolfColors {
  PubGolfColors._();
  static const background    = Color(0xFF0B3D2E);
  static const surface       = Color(0xFF1E1E1E);
  static const gold          = Color(0xFFF2C94C);
  static const purple        = Color(0xFF9D4EDD);
  static const purpleDark    = Color(0xFF7B2CBF);
  static const danger        = Color(0xFFEB5757);
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFBDBDBD);
}

class PubGolfApp extends StatelessWidget {
  const PubGolfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PubGolf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        dividerColor: Colors.transparent,
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: Stack(
        children: [
          // Layer 1: bokeh city-lights background
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _BokehPainter(),
          ),
          // Layer 2: stars / sparkles
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _StarsPainter(),
          ),
          // Layer 3: dark vignette overlay
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.0,
                colors: [Colors.transparent, Color(0xCC050508)],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          // Layer 4: UI content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildLogo(),
                  const SizedBox(height: 18),
                  const Text(
                    'PUBGOLF.',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Turn your night into a game',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white60,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(flex: 3),
                  _GlowButton(
                    label: 'Start a Night',
                    subtitle: 'Create your crawl',
                    glowColor: const Color(0xFF6EC06E),
                    iconWidget: const _GolfHoleIcon(),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const StartNightScreen())),
                  ),
                  const SizedBox(height: 16),
                  _GlowButton(
                    label: 'Join the Squad',
                    subtitle: 'Enter code or link',
                    glowColor: const Color(0xFFB565D8),
                    iconWidget: const Icon(
                      Icons.people_rounded,
                      color: Color(0xFFCE93D8),
                      size: 28,
                    ),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const JoinSquadScreen())),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HowItWorksScreen())),
                    child: const Text(
                      'See how it works',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A843).withValues(alpha: 0.35),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          const _GolfHoleIconLarge(),
        ],
      ),
    );
  }
}

// ─── Golf Hole Icon (button size) ─────────────────────────────────────────────
class _GolfHoleIcon extends StatelessWidget {
  const _GolfHoleIcon();
  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(32, 28),
      painter: _GolfHoleIconPainter(scale: 1.0),
    );
  }
}

// ─── Golf Hole Icon (hero/logo size) ──────────────────────────────────────────
class _GolfHoleIconLarge extends StatelessWidget {
  const _GolfHoleIconLarge();
  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(64, 56),
      painter: _GolfHoleIconPainter(scale: 2.0),
    );
  }
}

class _GolfHoleIconPainter extends CustomPainter {
  final double scale;
  const _GolfHoleIconPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.68;

    // Green mound
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.9, height: size.height * 0.38),
      Paint()..color = const Color(0xFFD4A843),
    );

    // Shadow on mound
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + size.height * 0.05), width: size.width * 0.65, height: size.height * 0.14),
      Paint()
        ..color = const Color(0xFFA07828)
        ..style = PaintingStyle.stroke
        ..strokeWidth = scale * 1.2,
    );

    // Hole
    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.02),
      size.width * 0.07,
      Paint()..color = const Color(0xFF1A1008),
    );

    // Pole
    canvas.drawLine(
      Offset(cx, cy - size.height * 0.02),
      Offset(cx, size.height * 0.08),
      Paint()
        ..color = const Color(0xFFD4A843)
        ..strokeWidth = scale * 1.4
        ..strokeCap = StrokeCap.round,
    );

    // Flag
    final flagPath = Path()
      ..moveTo(cx, size.height * 0.08)
      ..lineTo(cx + size.width * 0.28, size.height * 0.22)
      ..lineTo(cx, size.height * 0.36)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = const Color(0xFFE8C060));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Glow Button ──────────────────────────────────────────────────────────────
class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.label,
    required this.subtitle,
    required this.glowColor,
    required this.iconWidget,
    required this.onTap,
  });

  final String label, subtitle;
  final Color glowColor;
  final Widget iconWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: glowColor.withValues(alpha: 0.75), width: 1.4),
          boxShadow: [
            BoxShadow(color: glowColor.withValues(alpha: 0.30), blurRadius: 22, spreadRadius: 0),
            BoxShadow(color: glowColor.withValues(alpha: 0.12), blurRadius: 8, spreadRadius: -2, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: glowColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Background painters ───────────────────────────────────────────────────────
class _BokehPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final warmColors = [
      const Color(0xFFFF6010).withValues(alpha: 0.18),
      const Color(0xFFFF8C00).withValues(alpha: 0.14),
      const Color(0xFFFF3030).withValues(alpha: 0.12),
      const Color(0xFFFFD700).withValues(alpha: 0.10),
      const Color(0xFF20C8FF).withValues(alpha: 0.10),
      const Color(0xFF8B20FF).withValues(alpha: 0.13),
      const Color(0xFFFF20C0).withValues(alpha: 0.09),
      const Color(0xFF00FF80).withValues(alpha: 0.07),
    ];
    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = size.height * (0.3 + rng.nextDouble() * 0.7);
      final r = 25.0 + rng.nextDouble() * 70;
      final color = warmColors[rng.nextInt(warmColors.length)];
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28));
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.55),
      size.width * 0.55,
      Paint()..color = const Color(0xFF4B0082).withValues(alpha: 0.22)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(31);
    for (int i = 0; i < 55; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.65;
      final opacity = 0.25 + rng.nextDouble() * 0.55;
      final r = 0.6 + rng.nextDouble() * 1.2;
      final sparkle = rng.nextDouble() < 0.35;
      canvas.drawCircle(Offset(x, y), r, Paint()..color = Colors.white.withValues(alpha: opacity));
      if (sparkle) {
        final linePaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.5)
          ..strokeWidth = 0.7
          ..strokeCap = StrokeCap.round;
        final arm = r * 2.8;
        canvas.drawLine(Offset(x - arm, y), Offset(x + arm, y), linePaint);
        canvas.drawLine(Offset(x, y - arm), Offset(x, y + arm), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
