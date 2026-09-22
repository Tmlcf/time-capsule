import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Animated unlock sequence: 🔒 → ✨ → 🔓
class UnlockAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const UnlockAnimation({super.key, this.onComplete});

  @override
  State<UnlockAnimation> createState() => _UnlockAnimationState();
}

class _UnlockAnimationState extends State<UnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scale;
  late Animation<double> _glow;

  int _step = 0; // 0 = locked, 1 = sparkle, 2 = unlocked

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _glow = Tween<double>(begin: 0.3, end: 1.0).animate(_glowController);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // Step 1: bounce & sparkle
    setState(() => _step = 1);
    await _scaleController.forward();
    await _scaleController.reverse();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Step 2: unlock
    setState(() => _step = 2);
    await _scaleController.forward();
    await _scaleController.reverse();

    await Future.delayed(const Duration(milliseconds: 500));
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String get _emoji {
    switch (_step) {
      case 0:
        return '🔒';
      case 1:
        return '✨';
      case 2:
        return '🔓';
      default:
        return '🔒';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _glowController]),
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glow circle behind emoji
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_step == 2 ? AppTheme.gold : AppTheme.purple)
                        .withValues(alpha: _glow.value * 0.6),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Transform.scale(
                  scale: _scale.value,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: Text(
                      _emoji,
                      key: ValueKey(_step),
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _step == 2
                    ? 'Your memory has arrived\nfrom the past.'
                    : _step == 1
                        ? 'Unlocking...'
                        : '',
                key: ValueKey(_step),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _step == 2 ? AppTheme.gold : AppTheme.purpleLight,
                  height: 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
