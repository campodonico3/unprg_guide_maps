import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/presentation/pages/home/home_page.dart';
import 'package:unprg_guide_maps/presentation/pages/onboarding/onboarding_page.dart';
import 'package:unprg_guide_maps/presentation/pages/splash/splash_page.dart';

class AppRouter {
  static const String splash = "/";
  static const String home = "/home";
  static const String onboarding = '/onboarding';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("No route defined for ${settings.name}"),
            ),
          ),
        );
    }
  }
}
