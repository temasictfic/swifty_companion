import 'package:material_ui/material_ui.dart';

import '../../core/themes/app_theme.dart';

/// Search field that glows while focused.
///
/// Focus is tracked with a [FocusNode] (the old version guessed it from taps,
/// so the glow got stuck on after closing the keyboard with the back button),
/// and the clear button now updates as you type.
class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({
    required this.controller,
    required this.onChanged,
    required this.hintText,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  final FocusNode _focusNode = FocusNode();

  static const _radius = BorderRadius.all(Radius.circular(16));
  static const _focusedShadow = [
    BoxShadow(color: Color(0x4D00BABC), blurRadius: 20, offset: Offset(0, 4)),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    return AnimatedScale(
      scale: focused ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: _radius,
          boxShadow: focused ? _focusedShadow : const [],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTapOutside: (_) => _focusNode.unfocus(),
          textInputAction: TextInputAction.search,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(
              Icons.search,
              color: focused ? AppTheme.primaryColor : Colors.white54,
            ),
            suffixIcon: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => widget.controller.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      tooltip: 'Clear',
                      onPressed: () {
                        widget.controller.clear();
                        widget.onChanged('');
                      },
                    ),
            ),
            filled: true,
            fillColor: const Color(0x1AFFFFFF),
            border: const OutlineInputBorder(
              borderRadius: _radius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: _radius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: _radius,
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
