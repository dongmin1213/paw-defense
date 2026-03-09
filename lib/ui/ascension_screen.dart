import 'package:flutter/material.dart';
import '../game/runner_game.dart';

class AscensionScreen extends StatefulWidget {
  final RunnerGame game;

  const AscensionScreen({super.key, required this.game});

  @override
  State<AscensionScreen> createState() => _AscensionScreenState();
}

class _AscensionScreenState extends State<AscensionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleAnim;

  int _soulsEarned = 0;
  int _ascensionNumber = 0;
  bool _hasAscended = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.elasticOut)),
    );

    final game = widget.game;
    _soulsEarned = game.ascensionManager.calculateSoulReward(game.totalCoinsEarned);
    _ascensionNumber = game.ascensionManager.ascensionCount + 1;

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            color: Color.lerp(
              Colors.transparent,
              const Color(0xFFF5F5F5),
              _fadeIn.value * 0.95,
            ),
            child: Center(
              child: Opacity(
                opacity: _fadeIn.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ascension icon
                      Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: Color.lerp(
                          const Color(0xFF9C27B0),
                          const Color(0xFFFFD700),
                          (_controller.value * 2).clamp(0, 1),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        '초월 $_ascensionNumber회차',
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Soul reward
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF9C27B0).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '획득 소울',
                              style: TextStyle(color: Color(0xFF7B1FA2), fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, color: Color(0xFF9C27B0), size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  '+$_soulsEarned',
                                  style: const TextStyle(
                                    color: Color(0xFF7B1FA2),
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        '일반 업그레이드와 코인이 초기화됩니다',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (!_hasAscended) ...[
                        // Confirm button
                        GestureDetector(
                          onTap: _performAscension,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9C27B0).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              '초월하기',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => widget.game.closeAscensionScreen(),
                          child: const Text(
                            '돌아가기',
                            style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                          ),
                        ),
                      ] else ...[
                        // After ascension - continue
                        GestureDetector(
                          onTap: () => widget.game.closeAscensionScreen(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              '계속하기',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _performAscension() {
    widget.game.executeAscension();
    setState(() {
      _hasAscended = true;
    });
  }
}
