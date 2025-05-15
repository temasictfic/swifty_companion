import 'dart:ui';
import 'package:flutter/material.dart';

class OptimizedGlassContainer extends StatelessWidget {
  const OptimizedGlassContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.color,
    this.blur = 5, // Reduced from 10
    this.useBlur = true,
  });
  
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final double blur;
  final bool useBlur;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: child,
    );

    // Only apply blur if needed
    if (useBlur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: container,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: container,
    );
  }
}
