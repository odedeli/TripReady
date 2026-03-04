import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';

/// Animated splash screen.
/// — White/light-gray background so the color logo pops
/// — Fade + scale in over 800 ms
/// — Linear progress bar fills over [_totalDuration]
/// — Calls [onComplete] after the bar finishes
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 3500);
  static const _fadeInDuration = Duration(milliseconds: 800);

  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: _totalDuration);

    // Logo fades + scales in during first 800 ms
    final fadeInterval = Interval(
      0.0,
      _fadeInDuration.inMilliseconds / _totalDuration.inMilliseconds,
      curve: Curves.easeOut,
    );
    _fadeIn  = CurvedAnimation(parent: _ctrl, curve: fadeInterval);
    _scaleIn = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: fadeInterval));

    // Progress bar runs the full duration
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always light background regardless of system theme
    const bg      = Color(0xFFF2FAFE); // app background color
    const primary = Color(0xFF257599); // ocean-dusk primary

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Centered logo ──────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Opacity(
                opacity: _fadeIn.value,
                child: Transform.scale(
                  scale: _scaleIn.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Portrait logo (icon + Lexend wordmark)
                      AppLogo.portrait(height: 220),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Progress bar pinned to bottom ──────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (_, __) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtle label
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Opacity(
                      opacity: _fadeIn.value,
                      child: const Text(
                        'Personal Travel Planner',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1B5976),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  // Progress bar
                  LinearProgressIndicator(
                    value: _progress.value,
                    minHeight: 3,
                    backgroundColor: const Color(0xFFB7E2FA),
                    valueColor: const AlwaysStoppedAnimation<Color>(primary),
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
