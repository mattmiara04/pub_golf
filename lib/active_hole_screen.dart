import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Data models ──────────────────────────────────────────────────────────────
class HoleData {
  const HoleData({
    required this.holeNumber,
    required this.totalHoles,
    required this.barName,
    required this.drink,
    required this.par,
    required this.flavorText,
  });
  final int holeNumber, totalHoles, par;
  final String barName, drink, flavorText;
}

class PlayerScore {
  const PlayerScore({
    required this.name,
    required this.totalVsPar,
    required this.isYou,
  });
  final String name;
  final int totalVsPar; // negative = under par (good)
  final bool isYou;
}

// ─── Mock data ────────────────────────────────────────────────────────────────
const _mockHoles = [
  HoleData(holeNumber: 1, totalHoles: 6, barName: 'The Drunken Duck',  drink: 'Pint of Lager',     par: 6, flavorText: 'Steady. Control the pace.'),
  HoleData(holeNumber: 2, totalHoles: 6, barName: 'Brewhaus',          drink: 'IPA',               par: 5, flavorText: 'This is where nights are won.'),
  HoleData(holeNumber: 3, totalHoles: 6, barName: 'Tipsy Tavern',      drink: 'G&T',               par: 4, flavorText: 'Four sips. Easy. Or is it?'),
  HoleData(holeNumber: 4, totalHoles: 6, barName: 'Downtown Taproom',  drink: 'Craft Pale Ale',    par: 7, flavorText: 'Long hole. Pace yourself.'),
  HoleData(holeNumber: 5, totalHoles: 6, barName: 'Whiskey Barrel',    drink: 'Whiskey & Coke',    par: 5, flavorText: 'Nearly there. Stay sharp.'),
  HoleData(holeNumber: 6, totalHoles: 6, barName: 'Night Owl Pub',     drink: 'Tequila Shot',      par: 2, flavorText: 'Final hole. Leave it all here.'),
];

const _mockPlayers = [
  PlayerScore(name: 'Sarah',  totalVsPar: -2, isYou: false),
  PlayerScore(name: 'You',    totalVsPar: -1, isYou: true),
  PlayerScore(name: 'Matt',   totalVsPar:  0, isYou: false),
  PlayerScore(name: 'Jordan', totalVsPar:  2, isYou: false),
  PlayerScore(name: 'Priya',  totalVsPar:  3, isYou: false),
];

// ─── Entry screen ─────────────────────────────────────────────────────────────
class ActiveHoleScreen extends StatefulWidget {
  const ActiveHoleScreen({super.key});

  @override
  State<ActiveHoleScreen> createState() => _ActiveHoleScreenState();
}

class _ActiveHoleScreenState extends State<ActiveHoleScreen> {
  int _holeIndex = 0;
  final List<int> _scores = List.filled(6, -1); // -1 = not logged

  void _logScore(int sips) {
    setState(() => _scores[_holeIndex] = sips);
  }

  void _advanceHole() {
    if (_holeIndex < _mockHoles.length - 1) {
      setState(() => _holeIndex++);
    } else {
      // Game complete — pop for now
      Navigator.pop(context);
    }
  }

  List<PlayerScore> get _liveLeaderboard {
    // Adjust "You" score based on logged holes
    final yourVsPar = _scores
        .asMap()
        .entries
        .where((e) => e.value >= 0)
        .fold(0, (sum, e) => sum + (e.value - _mockHoles[e.key].par));
    return _mockPlayers.map((p) {
      if (p.isYou) return PlayerScore(name: p.name, totalVsPar: yourVsPar, isYou: true);
      return p;
    }).toList()
      ..sort((a, b) => a.totalVsPar.compareTo(b.totalVsPar));
  }

  @override
  Widget build(BuildContext context) {
    final hole = _mockHoles[_holeIndex];
    return _HoleScreenView(
      hole: hole,
      leaderboard: _liveLeaderboard,
      onLogScore: (sips) {
        _logScore(sips);
        // Show result then advance
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 250),
          transitionBuilder: (_, anim, _, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          pageBuilder: (_, _, _) => _HoleResultOverlay(
            hole: hole,
            sips: sips,
            onContinue: () {
              Navigator.pop(context); // close overlay
              _advanceHole();
            },
          ),
        );
      },
    );
  }
}

// ─── Main hole view ───────────────────────────────────────────────────────────
class _HoleScreenView extends StatefulWidget {
  const _HoleScreenView({
    required this.hole,
    required this.leaderboard,
    required this.onLogScore,
  });
  final HoleData hole;
  final List<PlayerScore> leaderboard;
  final ValueChanged<int> onLogScore;

  @override
  State<_HoleScreenView> createState() => _HoleScreenViewState();
}

class _HoleScreenViewState extends State<_HoleScreenView>
    with SingleTickerProviderStateMixin {
  int _sips = 0;
  bool _leaderboardExpanded = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_HoleScreenView old) {
    super.didUpdateWidget(old);
    if (old.hole.holeNumber != widget.hole.holeNumber) {
      setState(() => _sips = 0);
      _leaderboardExpanded = false;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() => _sips++);
    _bounceController.forward(from: 0);
  }

  void _decrement() {
    if (_sips > 0) {
      HapticFeedback.lightImpact();
      setState(() => _sips--);
    }
  }

  ({String text, Color color}) get _feedback {
    if (_sips == 0)        return (text: 'Tap + after your drink', color: const Color(0xFF555555));
    if (_sips < widget.hole.par)  return (text: 'Under par  🔥',         color: const Color(0xFF7CB342));
    if (_sips == widget.hole.par) return (text: 'On par',                color: Colors.white);
    if (_sips <= widget.hole.par + 2) return (text: 'Over par',          color: const Color(0xFFFFB74D));
    return (text: 'Max penalty',                                         color: const Color(0xFFEB5757));
  }

  @override
  Widget build(BuildContext context) {
    final hole = widget.hole;
    final fb = _feedback;

    return Scaffold(
      backgroundColor: const Color(0xFF060608),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1A10), Color(0xFF060608)],
              ),
            ),
          ),
          // Subtle purple bloom mid-screen
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, 0.1),
                radius: 0.65,
                colors: [Color(0x127B2CBF), Colors.transparent],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────────────
                _TopBar(hole: hole),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // ── Drink card ───────────────────────────────────
                        _DrinkCard(hole: hole),

                        const SizedBox(height: 32),

                        // ── Sip counter ──────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CounterButton(
                              icon: Icons.remove,
                              onTap: _decrement,
                              enabled: _sips > 0,
                            ),
                            const SizedBox(width: 32),
                            ScaleTransition(
                              scale: _bounceAnim,
                              child: SizedBox(
                                width: 80,
                                child: Text(
                                  '$_sips',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 72,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            _CounterButton(
                              icon: Icons.add,
                              onTap: _increment,
                              enabled: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Contextual feedback ──────────────────────────
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            fb.text,
                            key: ValueKey(fb.text),
                            style: TextStyle(
                              color: fb.color,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // ── Log Score button ─────────────────────────────
                        _LogButton(
                          active: _sips > 0,
                          onTap: () => widget.onLogScore(_sips),
                        ),

                        const SizedBox(height: 16),

                        // ── Leaderboard ──────────────────────────────────
                        _LeaderboardStrip(
                          players: widget.leaderboard,
                          expanded: _leaderboardExpanded,
                          onToggle: () => setState(
                            () => _leaderboardExpanded = !_leaderboardExpanded,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.hole});
  final HoleData hole;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          // Hole pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2A0A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF7CB342), width: 1),
            ),
            child: Text(
              'HOLE ${hole.holeNumber}',
              style: const TextStyle(
                color: Color(0xFF7CB342),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const Spacer(),

          // Bar name
          Text(
            hole.barName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          // Progress
          Text(
            '${hole.holeNumber} of ${hole.totalHoles}',
            style: const TextStyle(color: Color(0xFF555555), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Drink card ───────────────────────────────────────────────────────────────
class _DrinkCard extends StatelessWidget {
  const _DrinkCard({required this.hole});
  final HoleData hole;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF222232), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x1A7B2CBF), blurRadius: 24, spreadRadius: 4),
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Label
          const Text(
            'YOUR DRINK',
            style: TextStyle(
              color: Color(0xFF555555),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 10),

          // Divider
          Container(height: 1, color: const Color(0xFF1E1E2A)),

          const SizedBox(height: 16),

          // Drink name
          Text(
            hole.drink,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 14),

          // Par row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'PAR',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 14, color: const Color(0xFF2A2A3A)),
              const SizedBox(width: 10),
              Text(
                '${hole.par} sips',
                style: const TextStyle(
                  color: Color(0xFFF2C94C),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Divider
          Container(height: 1, color: const Color(0xFF1E1E2A)),

          const SizedBox(height: 12),

          // Flavor text
          Text(
            hole.flavorText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF444455),
              fontSize: 12,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Counter button ───────────────────────────────────────────────────────────
class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap, required this.enabled});
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? const Color(0xFF151520) : const Color(0xFF0D0D14),
          border: Border.all(
            color: enabled ? const Color(0xFF2A2A3A) : const Color(0xFF161620),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : const Color(0xFF333340),
          size: 24,
        ),
      ),
    );
  }
}

// ─── Log Score button ─────────────────────────────────────────────────────────
class _LogButton extends StatelessWidget {
  const _LogButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A2A0A) : const Color(0xFF0F0F14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFF7CB342) : const Color(0xFF1E1E26),
            width: 1.5,
          ),
          boxShadow: active
              ? const [
                  BoxShadow(color: Color(0x667CB342), blurRadius: 18, spreadRadius: 2),
                  BoxShadow(color: Color(0x337CB342), blurRadius: 36, spreadRadius: 4),
                ]
              : null,
        ),
        child: Text(
          'Log Score',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF333340),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─── Leaderboard strip ────────────────────────────────────────────────────────
class _LeaderboardStrip extends StatelessWidget {
  const _LeaderboardStrip({
    required this.players,
    required this.expanded,
    required this.onToggle,
  });
  final List<PlayerScore> players;
  final bool expanded;
  final VoidCallback onToggle;

  String _formatScore(int s) {
    if (s == 0) return 'E';
    return s > 0 ? '+$s' : '$s';
  }

  Color _scoreColor(int s) {
    if (s < 0) return const Color(0xFF7CB342);
    if (s == 0) return Colors.white;
    return const Color(0xFFEB5757);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E2A)),
      ),
      child: Column(
        children: [
          // Header row — always visible
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'SCOREBOARD',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),

                  // Top 3 avatars collapsed
                  if (!expanded)
                    Row(
                      children: players.take(3).map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _PlayerAvatar(player: p, score: _formatScore(p.totalVsPar), scoreColor: _scoreColor(p.totalVsPar)),
                        );
                      }).toList(),
                    ),

                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF444455), size: 18),
                  ),
                ],
              ),
            ),
          ),

          // Expanded rows
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: expanded
                ? Column(
                    children: [
                      Container(height: 1, color: const Color(0xFF1A1A24)),
                      ...players.asMap().entries.map((entry) {
                        final rank = entry.key + 1;
                        final p = entry.value;
                        return _LeaderboardRow(
                          rank: rank,
                          player: p,
                          score: _formatScore(p.totalVsPar),
                          scoreColor: _scoreColor(p.totalVsPar),
                        );
                      }),
                      const SizedBox(height: 4),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player, required this.score, required this.scoreColor});
  final PlayerScore player;
  final String score;
  final Color scoreColor;

  @override
  Widget build(BuildContext context) {
    final isYou = player.isYou;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isYou ? const Color(0xFF1A1A40) : const Color(0xFF1A1A1A),
            border: Border.all(
              color: isYou ? const Color(0xFF7B2CBF) : const Color(0xFF2A2A3A),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              player.name[0],
              style: TextStyle(
                color: isYou ? const Color(0xFF9D4EDD) : const Color(0xFF777777),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(score, style: TextStyle(color: scoreColor, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.player,
    required this.score,
    required this.scoreColor,
  });
  final int rank;
  final PlayerScore player;
  final String score;
  final Color scoreColor;

  @override
  Widget build(BuildContext context) {
    final isYou = player.isYou;
    return Container(
      color: isYou ? const Color(0x0A7B2CBF) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$rank',
              style: TextStyle(
                color: rank == 1 ? const Color(0xFFF2C94C) : const Color(0xFF444455),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isYou ? const Color(0xFF1A1A40) : const Color(0xFF1A1A1A),
              border: Border.all(
                color: isYou ? const Color(0xFF7B2CBF) : const Color(0xFF2A2A3A),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                player.name[0],
                style: TextStyle(
                  color: isYou ? const Color(0xFF9D4EDD) : const Color(0xFF777777),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isYou ? '${player.name} (you)' : player.name,
              style: TextStyle(
                color: isYou ? Colors.white : const Color(0xFFBBBBBB),
                fontSize: 14,
                fontWeight: isYou ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            score,
            style: TextStyle(
              color: scoreColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hole result overlay ──────────────────────────────────────────────────────
class _HoleResultOverlay extends StatefulWidget {
  const _HoleResultOverlay({required this.hole, required this.sips, required this.onContinue});
  final HoleData hole;
  final int sips;
  final VoidCallback onContinue;

  @override
  State<_HoleResultOverlay> createState() => _HoleResultOverlayState();
}

class _HoleResultOverlayState extends State<_HoleResultOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.4)));
    _controller.forward();

    // Auto-advance after 2.2s
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onContinue();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delta = widget.sips - widget.hole.par;
    final String label;
    final String subLabel;
    final Color color;

    if (delta < 0) {
      label = '$delta';
      subLabel = 'Under par';
      color = const Color(0xFF7CB342);
    } else if (delta == 0) {
      label = 'E';
      subLabel = 'On par';
      color = Colors.white;
    } else {
      label = '+$delta';
      subLabel = 'Over par';
      color = const Color(0xFFEB5757);
    }

    return Scaffold(
      backgroundColor: const Color(0xDD060608),
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'HOLE ${widget.hole.holeNumber} COMPLETE',
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 88,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    shadows: [
                      Shadow(color: color.withValues(alpha: 0.5), blurRadius: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subLabel,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                if (widget.hole.holeNumber < widget.hole.totalHoles)
                  Column(
                    children: [
                      Text(
                        'Next up',
                        style: const TextStyle(color: Color(0xFF444455), fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _mockHoles[widget.hole.holeNumber].barName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
