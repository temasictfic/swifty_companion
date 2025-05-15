import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/coalition_model.dart';
import '../models/coalition_user_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'https://api.intra.42.fr/v2';
  final AuthService _authService = AuthService();
  
  /// Generic GET request method with automatic token refresh
  Future<dynamic> _get(String endpoint) async {
    print('Making request to: $_baseUrl$endpoint');
    
    var token = await _authService.getAccessToken();
    
    var response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    print('Response status: ${response.statusCode}');
    
    // If unauthorized, refresh token and retry
    if (response.statusCode == 401) {
      print('Token expired, refreshing...');
      token = await _authService.refreshToken();
      response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('Retry response status: ${response.statusCode}');
    }
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error response body: ${response.body}');
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
  
  /// Search for users by login
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    try {
      final data = await _get('/users?search[login]=$query%&page[size]=20');
      return (data as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .where((user) => user.imageUrl != null) // Filter out users without images
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
  
  /// Get detailed user information
  Future<UserModel> getUserDetails(String login) async {
    try {
      print('Getting user details for: $login');
      final data = await _get('/users/$login');
      return UserModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('Error in getUserDetails: $e');
      throw Exception('Failed to get user details: $e');
    }
  }
  
  /// Get user projects
  Future<List<ProjectModel>> getUserProjects(String login) async {
    try {
      final data = await _get('/users/$login/projects_users?page[size]=100');
      final projects = (data as List)
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Sort by creation date (newest first)
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return projects;
    } catch (e) {
      throw Exception('Failed to get user projects: $e');
    }
  }
  
  /// Get user coalition information
  Future<CoalitionModel?> getUserCoalition(String login) async {
    try {
      final data = await _get('/users/$login/coalitions');
      if (data is List && data.isNotEmpty) {
        // Get the most recent coalition
        return CoalitionModel.fromJson(data.last as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user coalition: $e');
    }
  }
  
  /// Get user's coalition user data (score and rank)
  Future<CoalitionUserModel?> getUserCoalitionUser(String login) async {
    try {
      final data = await _get('/users/$login/coalitions_users');
      if (data is List && data.isNotEmpty) {
        // Get the first coalition user data (should typically only be one)
        return CoalitionUserModel.fromJson(data.first as Map<String, dynamic>);
      } else if (data is Map<String, dynamic>) {
        // In case the API returns a single object
        return CoalitionUserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting coalition user data: $e');
      return null;
    }
  }
  
  /// Get user achievements
  Future<List<Map<String, dynamic>>> getUserAchievements(String login) async {
    try {
      // Get user data which includes achievements
      final userData = await _get('/users/$login');
      final achievements = userData['achievements'] as List? ?? [];
      
      return achievements.map((achievement) => {
        'name': achievement['name'] ?? '',
        'description': achievement['description'] ?? '',
        'kind': achievement['kind'] ?? '',
        'tier': achievement['tier'] ?? '',
        'image': achievement['image'] ?? '',
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user achievements: $e');
    }
  }
}
