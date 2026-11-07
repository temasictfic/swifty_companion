import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/themes/app_theme.dart';
import '../../../shared/widgets/animated_search_bar.dart';
import '../../../shared/widgets/surface_card.dart';
import '../../../shared/widgets/user_avatar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

enum _SearchStatus { idle, tooShort, loading, results, empty, error }

class _SearchScreenState extends State<SearchScreen> {
  static const _minChars = 2;
  static const _debounce = Duration(milliseconds: 400);

  final TextEditingController _searchController = TextEditingController();
  Timer? _debouncer;
  List<UserModel> _results = const [];
  _SearchStatus _status = _SearchStatus.idle;
  String _errorMessage = '';

  /// Incremented per search; responses from older searches are ignored so a
  /// slow earlier request can't overwrite newer results.
  int _searchId = 0;

  @override
  void dispose() {
    _debouncer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debouncer?.cancel();
    final query = value.trim();

    if (query.isEmpty || query.length < _minChars) {
      _searchId++; // cancel any pending result
      setState(() {
        _results = const [];
        _status = query.isEmpty ? _SearchStatus.idle : _SearchStatus.tooShort;
      });
      return;
    }

    if (_status != _SearchStatus.loading && _status != _SearchStatus.results) {
      setState(() => _status = _SearchStatus.loading);
    }
    _debouncer = Timer(_debounce, () => _performSearch(query));
  }

  void _onSubmitted(String value) {
    _debouncer?.cancel();
    final query = value.trim();
    if (query.length >= _minChars) _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    final id = ++_searchId;
    setState(() => _status = _SearchStatus.loading);

    try {
      final results = await context.read<ApiService>().searchUsers(query);
      if (!mounted || id != _searchId) return;
      setState(() {
        _results = results;
        _status = results.isEmpty ? _SearchStatus.empty : _SearchStatus.results;
      });
    } catch (e) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _errorMessage = 'Failed to search users.\n$e';
        _status = _SearchStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _Header(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSubmitted,
                  hintText: 'Search by login...',
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return switch (_status) {
      _SearchStatus.idle => const _Message(
        icon: Icons.search,
        text: 'Start typing to search',
      ),
      _SearchStatus.tooShort => const _Message(
        text: 'Please enter at least 2 characters',
      ),
      _SearchStatus.loading => const _LoadingList(),
      _SearchStatus.empty => const _Message(
        icon: Icons.search_off,
        text: 'No results found',
      ),
      _SearchStatus.error => _Message(
        icon: Icons.error_outline,
        iconColor: AppTheme.errorColor,
        text: _errorMessage,
      ),
      _SearchStatus.results => ListView.builder(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: _results.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _UserTile(user: _results[index]),
        ),
      ),
    };
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary: the header never changes, so it is painted once and
    // reused while the list/shimmer below animates.
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fluttery Mate',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: AppTheme.primaryGradient.createShader,
                    child: const Text(
                      'Find any 42 student',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
              tooltip: 'Settings',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.profile, arguments: user),
        child: SurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(
                tag: 'avatar-${user.login}',
                child: UserAvatar(imageUrl: user.smallImageUrl, size: 50),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.login,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    // A single Shimmer around the whole list (one animation instead of five),
    // isolated so its per-frame repaint doesn't repaint the rest of the screen.
    return RepaintBoundary(
      child: Shimmer.fromColors(
        baseColor: const Color(0x1AFFFFFF),
        highlightColor: const Color(0x33FFFFFF),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: 5,
          itemBuilder: (_, _) => Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.icon, this.iconColor});

  final String text;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 80,
                color: iconColor?.withValues(alpha: 0.7) ?? Colors.white30,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
