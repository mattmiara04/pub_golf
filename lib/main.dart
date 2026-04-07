import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const PubGolfApp());
}

// ─── Design System ───────────────────────────────────────────────────────────
class PubGolfColors {
  PubGolfColors._();

  static const background   = Color(0xFF0B3D2E);
  static const surface      = Color(0xFF1E1E1E);
  static const gold         = Color(0xFFF2C94C);
  static const purple       = Color(0xFF9D4EDD);
  static const purpleDark   = Color(0xFF7B2CBF);
  static const danger       = Color(0xFFEB5757);
  static const textPrimary  = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFBDBDBD);
}
// ─────────────────────────────────────────────────────────────────────────────

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
        // Buttons are styled individually on the home screen for nightlife effects
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: PubGolfColors.gold,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 6,
            shadowColor: PubGolfColors.gold.withValues(alpha: 0.5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: PubGolfColors.purple,
            side: const BorderSide(color: PubGolfColors.purple, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

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

    _emojiSlide = Tween<Offset>(
      begin: const Offset(0, -4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _emojiController,
      curve: const ElasticOutCurve(0.2),
    ));

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: const ElasticOutCurve(0.3),
    ));

    _emojiFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _emojiController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

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
                colors: [
                  Color(0xFF0B3D2E),
                  Color(0xFF050D0A),
                ],
              ),
            ),
          ),
          // Layer 2: dark night sky overlay — fades from near-black top into transparent
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE0050810), // deep night at the very top
                    Color(0x8010052A), // dark purple-night mid-blend
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.28, 0.58],
                ),
              ),
            ),
          ),
          // Layer 3: four-pointed stars scattered across the night sky area
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (_, _) => CustomPaint(
                painter: _StarfieldPainter(_shimmerController.value),
              ),
            ),
          ),
          // Layer 4: tight purple bloom only around the emoji (top-center, small radius)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.45),
                  radius: 0.35,
                  colors: [
                    Color(0x557B2CBF),
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Layer 3: second purple bloom lower down — ties buttons into the palette
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, 0.7),
                  radius: 0.6,
                  colors: [
                    Color(0x2E7B2CBF),
                    Colors.transparent,
                  ],
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
                      // Emoji — larger, brighter purple halo
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
                      // Title — stronger purple glow
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

                  // NEW GAME — gold gradient, warm shadow
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'NEW GAME',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // JOIN GAME — richer purple gradient fill + stronger glow
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'JOIN GAME',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // HOW TO PLAY — dim, very secondary
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B5B7A), // muted purple-gray
                      side: const BorderSide(color: Color(0xFF3A2A4A), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'HOW TO PLAY',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Footer
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

class _StarfieldPainter extends CustomPainter {
  final double shimmer;
  const _StarfieldPainter(this.shimmer);

  // [xFrac, yFrac, outerRadius, opacity, glowSigmaMultiplier, phaseOffset]
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
        // Skip ~12% of cells so the grid doesn't feel mechanical
        if (rng.nextDouble() < 0.12) continue;

        // Place star at a random position within the cell (±40% of cell size)
        final x = ((col + 0.5 + (rng.nextDouble() - 0.5) * 0.8) * cellW)
            .clamp(0.02, 0.98);
        final y = ((row + 0.5 + (rng.nextDouble() - 0.5) * 0.8) * cellH)
            .clamp(0.01, 0.54);

        stars.add([
          x,
          y,
          rng.nextDouble() * 1.5 + 1.2, // outer radius 1.2–2.7 px
          rng.nextDouble() * 0.4 + 0.6,  // base opacity 0.6–1.0
          rng.nextDouble() * 2.0 + 3.0,  // glow sigma multiplier 3.0–5.0
          rng.nextDouble(),               // shimmer phase offset
        ]);
      }
    }
    return stars;
  }

  void _drawStar(Canvas canvas, Offset center, double outerR, double opacity, double glowMult, double phase) {
    // Each star pulses between 40% and 100% of its base opacity independently
    final t = (math.sin((shimmer + phase) * 2 * math.pi) * 0.5 + 0.5); // 0.0–1.0
    opacity = opacity * (0.4 + 0.6 * t);
    // Glow halo — drawn first so it sits behind the star
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.85)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, outerR * glowMult);
    canvas.drawCircle(center, outerR, glowPaint);
    // Second wider bloom for extra radiance
    canvas.drawCircle(center, outerR * 2, Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, outerR * glowMult * 2));

    // Four-pointed sparkle with concave bezier curves between each tip.
    // Vertical axis is 1.35× longer than horizontal to match the reference shape.
    final vR  = outerR * 1.35; // vertical tip reach
    final hR  = outerR;        // horizontal tip reach
    final cR  = outerR * 0.13; // waist control-point distance from centre (tighter = more pinched)

    final top    = Offset(center.dx,        center.dy - vR);
    final right  = Offset(center.dx + hR,   center.dy);
    final bottom = Offset(center.dx,        center.dy + vR);
    final left   = Offset(center.dx - hR,   center.dy);

    // Control points sit very close to centre at the 45° diagonals,
    // pulling the path inward and creating the concave waist.
    final cTR = Offset(center.dx + cR, center.dy - cR);
    final cBR = Offset(center.dx + cR, center.dy + cR);
    final cBL = Offset(center.dx - cR, center.dy + cR);
    final cTL = Offset(center.dx - cR, center.dy - cR);

    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..quadraticBezierTo(cTR.dx, cTR.dy, right.dx, right.dy)
      ..quadraticBezierTo(cBR.dx, cBR.dy, bottom.dx, bottom.dy)
      ..quadraticBezierTo(cBL.dx, cBL.dy, left.dx, left.dy)
      ..quadraticBezierTo(cTL.dx, cTL.dy, top.dx, top.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      _drawStar(
        canvas,
        Offset(s[0] * size.width, s[1] * size.height),
        s[2],
        s[3],
        s[4],
        s[5],
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.shimmer != shimmer;
}
