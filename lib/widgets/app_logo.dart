import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Which logo variant to display
enum LogoVariant {
  colorIcon,       // 800×800  — icon only, color
  colorPortrait,   // 800×1008 — icon + caption stacked, color
  colorLandscape,  // 3296×800 — icon + caption side-by-side, color
  monoIcon,        // 800×800  — icon only, mono
  monoPortrait,    // 800×1008 — icon + caption stacked, mono
  monoLandscape,   // 3296×800 — icon + caption side-by-side, mono
}

enum MonoColor { auto, white, dark }

/// Branded logo widget — picks the correct SVG and sizes it from one dimension.
///
/// Quick constructors:
///   AppLogo.icon(size: 40)                — color icon, square
///   AppLogo.whiteIcon(size: 32)           — white mono icon (dark AppBars)
///   AppLogo.landscape(height: 36)         — color landscape wordmark
///   AppLogo.whiteLandscape(height: 36)    — white mono landscape wordmark
///   AppLogo.portrait(height: 120)         — color portrait (splash/about)
///   AppLogo.watermark(size: 320)          — 5% opacity background decoration
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.variant = LogoVariant.colorIcon,
    this.size,
    this.width,
    this.height,
    this.monoColor = MonoColor.auto,
    this.opacity = 1.0,
  });

  const AppLogo.icon({super.key, required double this.size})
      : variant = LogoVariant.colorIcon, width = null, height = null,
        monoColor = MonoColor.auto, opacity = 1.0;

  const AppLogo.whiteIcon({super.key, required double this.size})
      : variant = LogoVariant.monoIcon, width = null, height = null,
        monoColor = MonoColor.white, opacity = 1.0;

  const AppLogo.darkIcon({super.key, required double this.size})
      : variant = LogoVariant.monoIcon, width = null, height = null,
        monoColor = MonoColor.dark, opacity = 1.0;

  const AppLogo.landscape({super.key, this.height})
      : variant = LogoVariant.colorLandscape, size = null, width = null,
        monoColor = MonoColor.auto, opacity = 1.0;

  const AppLogo.whiteLandscape({super.key, this.height})
      : variant = LogoVariant.monoLandscape, size = null, width = null,
        monoColor = MonoColor.white, opacity = 1.0;

  const AppLogo.portrait({super.key, this.height, this.width})
      : variant = LogoVariant.colorPortrait, size = null,
        monoColor = MonoColor.auto, opacity = 1.0;

  const AppLogo.watermark({super.key, required double this.size})
      : variant = LogoVariant.colorIcon, width = null, height = null,
        monoColor = MonoColor.auto, opacity = 0.05;

  final LogoVariant variant;
  final double? size;
  final double? width;
  final double? height;
  final MonoColor monoColor;
  final double opacity;

  static const _base = 'assets/logos';

  String get _asset {
    switch (variant) {
      case LogoVariant.colorIcon:       return '$_base/TripReady_Logo_color_nocaption.svg';
      case LogoVariant.colorPortrait:   return '$_base/TripReady_Logo_color.svg';
      case LogoVariant.colorLandscape:  return '$_base/TripReady_Logo_color_landscape.svg';
      case LogoVariant.monoIcon:        return '$_base/TripReady_Logo_mono_nocaption.svg';
      case LogoVariant.monoPortrait:    return '$_base/TripReady_Logo_mono.svg';
      case LogoVariant.monoLandscape:   return '$_base/TripReady_Logo_mono_landscape.svg';
    }
  }

  (double, double) get _naturalSize {
    switch (variant) {
      case LogoVariant.colorIcon:
      case LogoVariant.monoIcon:       return (800, 800);
      case LogoVariant.colorPortrait:
      case LogoVariant.monoPortrait:   return (800, 1008);
      case LogoVariant.colorLandscape:
      case LogoVariant.monoLandscape:  return (3296, 800);
    }
  }

  bool get _isMono =>
      variant == LogoVariant.monoIcon ||
      variant == LogoVariant.monoPortrait ||
      variant == LogoVariant.monoLandscape;

  Color? _resolveColor(BuildContext context) {
    if (!_isMono) return null;
    switch (monoColor) {
      case MonoColor.white: return Colors.white;
      case MonoColor.dark:  return const Color(0xFF393D46);
      case MonoColor.auto:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF393D46);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (nw, nh) = _naturalSize;
    final aspect = nw / nh;

    double? w = width ?? (size != null ? size! * aspect : null);
    double? h = height ?? (variant == LogoVariant.colorIcon || variant == LogoVariant.monoIcon ? size : null);

    if (w != null && h == null) h = w / aspect;
    if (h != null && w == null) w = h * aspect;

    final tint = _resolveColor(context);
    final svg = SvgPicture.asset(
      _asset,
      width: w, height: h,
      colorFilter: tint != null ? ColorFilter.mode(tint, BlendMode.srcIn) : null,
      fit: BoxFit.contain,
    );

    return opacity == 1.0 ? svg : Opacity(opacity: opacity, child: svg);
  }
}
