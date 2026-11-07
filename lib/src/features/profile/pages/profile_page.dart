import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/themes/app_theme.dart';
import '../widgets/achievements_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_tab.dart';
import '../widgets/projects_section.dart';
import '../widgets/skills_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.login, this.preview, super.key});

  final String login;

  /// Partial user from the search results, shown while the full profile loads.
  final UserModel? preview;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _tabs = ['Info', 'Projects', 'Skills', 'Achievements'];

  UserModel? _user;
  CoalitionInfo? _coalitionInfo;
  Object? _error;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // Loaded exactly once. (The old code loaded from didChangeDependencies,
    // which re-fires on route/MediaQuery changes and re-downloaded the profile.)
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    final api = context.read<ApiService>();
    if (_error != null) setState(() => _error = null); // e.g. after Retry

    // Both start immediately; the rate limiter keeps them within API limits.
    final userFuture = api.getUserDetails(widget.login, forceRefresh: refresh);
    final coalitionFuture = api
        .getCoalitionInfo(widget.login, forceRefresh: refresh)
        .then<CoalitionInfo?>((info) => info, onError: (Object _) => null);

    coalitionFuture.then((info) {
      if (mounted && info != null) setState(() => _coalitionInfo = info);
    });

    try {
      final user = await userFuture;
      if (mounted) setState(() => _user = user);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
    await coalitionFuture;
  }

  Color get _accent {
    final coalition = _coalitionInfo?.coalition;
    return coalition == null
        ? AppTheme.primaryColor
        : Color(coalition.colorValue);
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _coalitionInfo?.coalition?.coverUrl;
    final size = MediaQuery.sizeOf(context);
    final coverHeight = size.height * 0.3;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          if (coverUrl != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: coverHeight,
              child: CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                memCacheWidth:
                    (size.width * MediaQuery.devicePixelRatioOf(context))
                        .round(),
                fadeInDuration: const Duration(milliseconds: 200),
                color: Colors.black.withValues(alpha: 0.3),
                colorBlendMode: BlendMode.darken,
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          // Fade the cover into the background (only over the cover area).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: coverHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC0F0F0F),
                    AppTheme.backgroundColor,
                  ],
                  stops: [0.0, 0.67, 1.0],
                ),
              ),
            ),
          ),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final user = _user ?? widget.preview;
    final padding = MediaQuery.paddingOf(context);

    if (user == null && _error == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    return RefreshIndicator(
      color: _accent,
      edgeOffset: padding.top,
      onRefresh: () => _load(refresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(padding: EdgeInsets.only(top: padding.top)),
          if (user != null)
            SliverToBoxAdapter(
              child: ProfileHeader(
                user: user,
                coalition: _coalitionInfo?.coalition,
                accent: _accent,
              ),
            ),
          ..._buildBody(),
          SliverPadding(padding: EdgeInsets.only(bottom: 32 + padding.bottom)),
        ],
      ),
    );
  }

  List<Widget> _buildBody() {
    final user = _user;
    if (user == null) {
      if (_error != null) {
        return [
          SliverFillRemaining(hasScrollBody: false, child: _buildError()),
        ];
      }
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ];
    }

    final accent = _accent;
    final content = switch (_selectedTab) {
      0 => SliverToBoxAdapter(
        child: ProfileInfoTab(
          user: user,
          coalitionUser: _coalitionInfo?.membership,
          accent: accent,
        ),
      ),
      1 => ProjectsSliver(projects: user.projects),
      2 => SkillsSliver(skills: user.skills, accent: accent),
      _ => AchievementsSliver(achievements: user.achievements, accent: accent),
    };

    return [
      SliverToBoxAdapter(child: _buildTabBar()),
      const SliverPadding(padding: EdgeInsets.only(top: 20)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: content,
      ),
    ];
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final selected = index == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selected ? AppTheme.primaryGradient : null,
                color: selected ? null : const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    final error = _error;
    final message = error is ApiException && error.statusCode == 404
        ? 'User "${widget.login}" was not found.'
        : 'Failed to load profile.\n$error';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
