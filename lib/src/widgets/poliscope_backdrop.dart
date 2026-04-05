import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

class PoliscopeBackdrop extends StatefulWidget {
  const PoliscopeBackdrop({super.key, required this.child});

  final Widget child;

  @override
  State<PoliscopeBackdrop> createState() => _PoliscopeBackdropState();
}

class _PoliscopeBackdropState extends State<PoliscopeBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppPalette.canvas,
            Color(0xFFFFF0E7),
            Color(0xFFF7FFE6),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                return Stack(
                  children: [
                    _GlowBlob(
                      color: AppPalette.coral,
                      size: 220,
                      left: -30 + (t * 38),
                      top: -16 + (t * 24),
                    ),
                    _GlowBlob(
                      color: AppPalette.sky,
                      size: 240,
                      right: -60 + ((1 - t) * 46),
                      top: 120 + ((1 - t) * 24),
                    ),
                    _GlowBlob(
                      color: AppPalette.lime,
                      size: 260,
                      left: 90 + ((1 - t) * 22),
                      bottom: -90 + (t * 42),
                    ),
                    _GlowBlob(
                      color: AppPalette.gold,
                      size: 180,
                      right: 26 + (t * 10),
                      bottom: 90 + ((1 - t) * 14),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.24),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.color,
    required this.size,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  final Color color;
  final double size;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.28),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PoliscopePanel extends StatelessWidget {
  const PoliscopePanel({
    super.key,
    required this.child,
    this.accentColor = AppPalette.coral,
    this.padding = const EdgeInsets.all(22),
    this.fillOpacity = 0.72,
  });

  final Widget child;
  final Color accentColor;
  final EdgeInsets padding;
  final double fillOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: fillOpacity),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
