import 'package:material_ui/material_ui.dart';

/// Translucent rounded card used across the app.
///
/// Replaces the old "glass" containers. Those wrapped every card in a
/// `BackdropFilter` blur — one offscreen GPU pass per card, per frame —
/// which caused most of the scrolling jank on mid-range phones. Over the app's
/// flat dark background a blur is visually identical to this plain
/// translucent fill, which costs nothing extra to draw.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;

  static const Color defaultColor = Color(0x1AFFFFFF); // white @ 10%
  static const Color borderColor = Color(0x33FFFFFF); // white @ 20%

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
