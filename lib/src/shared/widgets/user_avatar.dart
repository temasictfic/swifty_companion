import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

/// Circular network avatar, decoded at exactly the size it is displayed.
///
/// Decoding a full-size intra photo (often 1000px+) for a 50dp circle wastes
/// memory and CPU; sizing the decode to `size × devicePixelRatio` keeps
/// list scrolling smooth.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.imageUrl,
    required this.size,
    this.placeholderUrl,
    super.key,
  });

  final String? imageUrl;
  final double size;

  /// Optional low-res image (e.g. the list thumbnail, already on disk) shown
  /// while [imageUrl] loads, so the avatar never flashes empty.
  final String? placeholderUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final cachePx = (size * MediaQuery.devicePixelRatioOf(context)).round();
    final lowRes = placeholderUrl;

    Widget placeholder = _Placeholder(size: size);
    if (lowRes != null && lowRes.isNotEmpty && lowRes != url) {
      placeholder = CachedNetworkImage(
        imageUrl: lowRes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: cachePx,
        fadeInDuration: Duration.zero,
        placeholder: (_, _) => _Placeholder(size: size),
        errorWidget: (_, _, _) => _Placeholder(size: size),
      );
    }
    if (url == null || url.isEmpty) return ClipOval(child: placeholder);

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: cachePx,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => _Placeholder(size: size, showIcon: true),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size, this.showIcon = false});

  final double size;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0x1AFFFFFF),
        shape: BoxShape.circle,
      ),
      child: showIcon
          ? Icon(Icons.person, color: Colors.white54, size: size / 2)
          : null,
    );
  }
}
