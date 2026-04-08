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
      title: 'Pub Golf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: PubGolfColors.gold,
          secondary: PubGolfColors.purple,
          surface: PubGolfColors.surface,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: PubGolfColors.textPrimary,
        ),
        scaffoldBackgroundColor: PubGolfColors.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: PubGolfColors.gold,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 6,
            shadowColor: PubGolfColors.gold.withValues(alpha: 0.5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: PubGolfColors.purple,
            side: const BorderSide(color: PubGolfColors.purple, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _emojiController;
  late final AnimationController _titleController;
  late final AnimationController _shimmerController;
  late final Animation<Offset> _emojiSlide;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _emojiFade;
  late final Animation<double> _titleFade;

  @override
  void initState() {
    super.initState();

    _emojiController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1900),
      vsync: this,
    );

    _emojiSlide = Tween<Offset>(begin: const Offset(0, -4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _emojiController, curve: const ElasticOutCurve(0.2)));

    _titleSlide = Tween<Offset>(begin: const Offset(0, -3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _titleController, curve: const ElasticOutCurve(0.3)));

    _emojiFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _emojiController, curve: const Interval(0.0, 0.25, curve: Curves.easeIn)));

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _titleController, curve: const Interval(0.0, 0.25, curve: Curves.easeIn)));

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _emojiController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _titleController.forward();
    });
  }

  @override
  void dispose() {
    _emojiController.dispose();
    _titleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: base green → near-black gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B3D2E), Color(0xFF050D0A)],
              ),
            ),
          ),
          // Layer 2: dark night sky overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE0050810),
                    Color(0x8010052A),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.28, 0.58],
                ),
              ),
            ),
          ),
          // Layer 3: shimmer starfield
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (_, _) => CustomPaint(
                painter: _StarfieldPainter(_shimmerController.value),
              ),
            ),
          ),
          // Layer 4: tight purple bloom around emoji
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.45),
                  radius: 0.35,
                  colors: [Color(0x557B2CBF), Colors.transparent],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Layer 5: lower purple bloom behind buttons
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, 0.7),
                  radius: 0.6,
                  colors: [Color(0x2E7B2CBF), Colors.transparent],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // Title area
                  Column(
                    children: [
                      SlideTransition(
                        position: _emojiSlide,
                        child: FadeTransition(
                          opacity: _emojiFade,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x887B2CBF),
                                  blurRadius: 80,
                                  spreadRadius: 30,
                                ),
                              ],
                            ),
                            child: const Text(
                              '⛳',
                              style: TextStyle(fontSize: 72),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: const Text(
                            'PUB GOLF',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: PubGolfColors.gold,
                              letterSpacing: 6,
                              shadows: [
                                Shadow(
                                  color: Color(0x88F2C94C),
                                  blurRadius: 20,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // NEW GAME
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF2C94C), Color(0xFFD4A017)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66F2C94C),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const StartNightScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'NEW GAME',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // JOIN GAME
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B2CBF), Color(0xFF9D4EDD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x779D4EDD),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const JoinSquadScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'JOIN GAME',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // HOW TO PLAY
                  OutlinedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HowItWorksScreen())),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B5B7A),
                      side: const BorderSide(color: Color(0xFF3A2A4A), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'HOW TO PLAY',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 2),
                    ),
                  ),

                  const Spacer(flex: 1),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Drink responsibly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: PubGolfColors.gold.withValues(alpha: 0.6),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Starfield painter ────────────────────────────────────────────────────────
class _StarfieldPainter extends CustomPainter {
  final double shimmer;
  const _StarfieldPainter(this.shimmer);

  static final List<List<double>> _stars = _buildStars();

  static List<List<double>> _buildStars() {
    final rng = math.Random(13);
    const cols = 8;
    const rows = 6;
    const cellW = 1.0 / cols;
    const cellH = 0.55 / rows;
    final stars = <List<double>>[];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (rng.nextDouble() < 0.12) continue;
        final x = ((col + 0.5 + (rng.nextDouble() - 0.5) * 0.8) * cellW).clamp(0.02, 0.98);
        final y = ((row + 0.5 + (rng.nextDouble() - 0.5) * 0.8) * cellH).clamp(0.01, 0.54);
        stars.add([
          x, y,
          rng.nextDouble() * 1.5 + 1.2,
          rng.nextDouble() * 0.4 + 0.6,
          rng.nextDouble() * 2.0 + 3.0,
          rng.nextDouble(),
        ]);
      }
    }
    return stars;
  }

  void _drawStar(Canvas canvas, Offset center, double outerR, double opacity,
      double glowMult, double phase) {
    final t = math.sin((shimmer + phase) * 2 * math.pi) * 0.5 + 0.5;
    opacity = opacity * (0.4 + 0.6 * t);

    canvas.drawCircle(center, outerR, Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.85)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, outerR * glowMult));

    canvas.drawCircle(center, outerR * 2, Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, outerR * glowMult * 2));

    final vR = outerR * 1.35;
    final hR = outerR;
    final cR = outerR * 0.13;

    final path = Path()
      ..moveTo(center.dx, center.dy - vR)
      ..quadraticBezierTo(center.dx + cR, center.dy - cR, center.dx + hR, center.dy)
      ..quadraticBezierTo(center.dx + cR, center.dy + cR, center.dx, center.dy + vR)
      ..quadraticBezierTo(center.dx - cR, center.dy + cR, center.dx - hR, center.dy)
      ..quadraticBezierTo(center.dx - cR, center.dy - cR, center.dx, center.dy - vR)
      ..close();

    canvas.drawPath(path, Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.fill);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      _drawStar(canvas, Offset(s[0] * size.width, s[1] * size.height),
          s[2], s[3], s[4], s[5]);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.shimmer != shimmer;
}
