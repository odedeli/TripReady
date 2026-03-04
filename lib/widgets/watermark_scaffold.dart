import 'package:flutter/material.dart';
import 'app_logo.dart';

/// Wraps a [Scaffold] body with a fixed, non-scrolling logo watermark.
///
/// The watermark is centered in the available body area and sits behind all
/// content. It ignores pointer events entirely so it never interferes with
/// taps or scrolling.
///
/// Usage — replace your existing Scaffold body wrapping:
///
///   // Before:
///   body: ListView(children: [...])
///
///   // After:
///   body: WatermarkBody(child: ListView(children: [...]))
///
class WatermarkBody extends StatelessWidget {
  const WatermarkBody({
    super.key,
    required this.child,
    this.opacity = 0.08,
    this.size = 260.0,
    this.alignment = const Alignment(0.0, 0.25),
  });

  final Widget child;
  final double opacity;
  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Fixed watermark (behind everything, ignores input) ──
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: alignment,
              child: Opacity(
                opacity: opacity,
                child: const AppLogo(
                  variant: LogoVariant.monoPortrait,
                  monoColor: MonoColor.dark,
                  width: 220,
                ),
              ),
            ),
          ),
        ),

        // ── Actual screen content (scrolls over the watermark) ──
        child,
      ],
    );
  }
}
