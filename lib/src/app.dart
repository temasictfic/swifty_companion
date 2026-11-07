import 'package:material_ui/material_ui.dart';

import 'core/models/user_model.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/pages/initial_setup_page.dart';
import 'features/profile/pages/profile_page.dart';
import 'features/search/pages/search_page.dart';
import 'features/settings/pages/settings_page.dart';

abstract final class AppRoutes {
  static const home = '/home';
  static const profile = '/profile';
  static const settings = '/settings';
  static const setup = '/setup';
}

class FlutteryMateApp extends StatelessWidget {
  const FlutteryMateApp({required this.initialRoute, super.key});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluttery Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.home => const SearchScreen(),
      AppRoutes.setup => const InitialSetupPage(),
      AppRoutes.settings => SettingsPage(
        isInitialSetup:
            settings.arguments is Map &&
            (settings.arguments! as Map)['isInitialSetup'] == true,
      ),
      AppRoutes.profile => switch (settings.arguments) {
        // Search passes the user it already has, so the header can render
        // instantly while the full profile loads.
        final UserModel user => ProfileScreen(login: user.login, preview: user),
        final String login => ProfileScreen(login: login),
        _ => const SearchScreen(),
      },
      _ => const SearchScreen(),
    };
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
