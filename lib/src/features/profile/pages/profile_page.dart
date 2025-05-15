import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/models/coalition_model.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/themes/app_theme.dart';
import '../widgets/achievements_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_stats.dart';
import '../widgets/projects_section.dart';
import '../widgets/skills_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  UserModel? _user;
  CoalitionModel? _coalition;
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedTab = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _tabs = ['Info', 'Projects', 'Skills', 'Achievements'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final login = ModalRoute.of(context)!.settings.arguments as String;
    _loadUserData(login);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData(String login) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Load user details and coalition in parallel
      final results = await Future.wait([
        apiService.getUserDetails(login),
        apiService.getUserCoalition(login),
      ]);

      setState(() {
        _user = results[0] as UserModel;
        _coalition = results[1] as CoalitionModel?;
      });

      // Load projects to get active projects count
      await _loadProjects(login);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProjects(String login) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final projects = await apiService.getUserProjects(login);

      setState(() {
        _projects = projects;
      });
    } catch (e) {
      // Handle error silently for projects
    }
  }

  Future<void> _onTabChanged(int index) async {
    setState(() {
      _selectedTab = index;
    });

    // Load projects when switching to projects tab
    if (index == 1 && _projects.isEmpty && _user != null) {
      await _loadProjects(_user!.login);
    }
  }


  String _getCurrentGrade() {
    // Find the active cursus with the highest level
    final activeCursus = _user!.cursusUsers
        .where((cursus) => cursus.endAt == null || cursus.endAt!.isAfter(DateTime.now()))
        .toList();
    
    if (activeCursus.isEmpty) {
      return 'None';
    }
    
    // Sort by level to get the highest
    activeCursus.sort((a, b) => b.level.compareTo(a.level));
    return activeCursus.first.grade ?? 'Student';
  }

  int _getActiveProjects() {
    return _projects.where((project) => 
      project.status == 'in_progress' || 
      project.status == 'searching_a_group'
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareProfile(),
            ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_user == null) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        // Background with coalition image
        if (_coalition?.coverUrl != null)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: CachedNetworkImage(
              imageUrl: _coalition!.coverUrl!,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),

        // Dark gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppTheme().backgroundColor.withValues(alpha: 0.8),
                AppTheme().backgroundColor,
              ],
              stops: const [0.0, 0.2, 0.3],
            ),
          ),
        ),

        // Main content
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    user: _user!,
                    coalition: _coalition,
                  ),

                  const SizedBox(height: 20),

                  // Tab bar
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedTab == index;

                        return GestureDetector(
                          onTap: () => _onTabChanged(index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppTheme().primaryGradient : null,
                              color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                _tabs[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tab content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTabContent(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildInfoTab();
      case 1:
        return ProjectsSection(projects: _projects, coalitionColor: _coalition?.color);
      case 2:
        return SkillsSection(skills: _user!.skills, coalitionColor: _coalition?.color);
      case 3:
        return AchievementsSection(
            achievements: _user!.achievements, coalitionColor: _coalition?.color);
      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoTab() {
    return Column(
      children: [
        ProfileStats(user: _user!, coalition: _coalition),
        const SizedBox(height: 24),
        ProfileSection(
          title: 'Contact Information',
          icon: Icons.contact_mail,
          children: [
            _buildInfoRow(Icons.email, _user!.email),
            if (_user!.phone != null) _buildInfoRow(Icons.phone, _user!.phone!),
            if (_user!.location != null) _buildInfoRow(Icons.location_on, _user!.location!),
          ],
        ),
        const SizedBox(height: 16),
        ProfileSection(
          title: 'Academic Information',
          icon: Icons.school,
          children: [
            _buildInfoRow(Icons.pool, 'Pool: ${_user!.poolYear ?? "N/A"}'),
            if (_user!.poolMonth != null) _buildInfoRow(Icons.calendar_month, 'Pool Month: ${_formatPoolMonth(_user!.poolMonth!)}'),
            _buildInfoRow(Icons.timeline, 'Enrolled Cursus: ${_getEnrolledCursusCount()}'),
            _buildInfoRow(Icons.star, 'Current Grade: ${_getCurrentGrade()}'),
            if (_getActiveProjects() > 0) _buildInfoRow(Icons.assignment, 'Active Projects: ${_getActiveProjects()}'),
            _buildInfoRow(Icons.check_circle_outline, 'Completed Projects: ${_getCompletedProjects()}'),
            _buildInfoRow(Icons.today, 'Member Since: ${_formatDate(_user!.createdAt)}'),
          ],
        ),
      ],
    );
  }

  String _formatPoolMonth(String poolMonth) {
    // Capitalize first letter
    return poolMonth[0].toUpperCase() + poolMonth.substring(1);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  int _getEnrolledCursusCount() {
    return _user!.cursusUsers.length;
  }

  int _getCompletedProjects() {
    return _projects.where((project) => 
      project.status == 'finished' && project.validated == true
    ).length;
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme().primaryColor),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme().errorColor.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage.isEmpty ? 'Failed to load profile' : _errorMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  void _shareProfile() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }
}
