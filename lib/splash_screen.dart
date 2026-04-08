import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _barController;
  late final AnimationController _fadeController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _barProgress;
  late final Animation<double> _screenFade;

  @override
  void initState() {
    super.initState();

    // Logo pops in
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Loading bar fills over ~2.4s
    _barController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    // Fade out whole splash at end
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _barProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeInOut),
    );

    _screenFade = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Short pause then logo appears
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Bar starts slightly after logo
    await Future.delayed(const Duration(milliseconds: 500));
    await _barController.forward();

    // Brief pause at full bar
    await Future.delayed(const Duration(milliseconds: 300));

    // Fade out then navigate
    await _fadeController.forward();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _barController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _screenFade,
      child: Scaffold(
        backgroundColor: const Color(0xFF060608),
        body: Stack(
          children: [
            // Same dark background as home
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0B1A14), Color(0xFF060608)],
                ),
              ),
            ),

            // Faint purple radial glow centre
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.1),
                  radius: 0.6,
                  colors: [Color(0x2A7B2CBF), Colors.transparent],
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo + brand name
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Column(
                        children: [
                          // Shevmatic shield / logo mark
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7B2CBF).withValues(alpha: 0.4),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: _ShevmaticLogoPainter(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Brand name
                          const Text(
                            'SHEVMATIC INC.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'presents',
                            style: TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Loading bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _barProgress,
                          builder: (_, _) {
                            return Column(
                              children: [
                                // Bar track
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A2A),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: _barProgress.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF7B2CBF), Color(0xFFF2C94C)],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF9D4EDD).withValues(alpha: 0.7),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'Loading${_loadingDots(_barProgress.value)}',
                                  style: const TextStyle(
                                    color: Color(0xFF555555),
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _loadingDots(double progress) {
    if (progress < 0.33) return '.';
    if (progress < 0.66) return '..';
    return '...';
  }
}

// ─── Shevmatic logo mark — stylised "S" in a circle ──────────────────────────
class _ShevmaticLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Circle background
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFF12101E),
    );

    // Circle border — purple
    canvas.drawCircle(
      Offset(cx, cy),
      r - 1,
      Paint()
        ..color = const Color(0xFF7B2CBF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Stylised "S" drawn with two arcs
    final sPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final topArc = Rect.fromCenter(
      center: Offset(cx, cy - r * 0.18),
      width: r * 0.75,
      height: r * 0.50,
    );
    final bottomArc = Rect.fromCenter(
      center: Offset(cx, cy + r * 0.18),
      width: r * 0.75,
      height: r * 0.50,
    );

    canvas.drawArc(topArc, 0, -3.14, false, sPaint);
    canvas.drawArc(bottomArc, 3.14, -3.14, false, sPaint);
  }

  @override
  bool shouldRepaint(_ShevmaticLogoPainter old) => false;
}
