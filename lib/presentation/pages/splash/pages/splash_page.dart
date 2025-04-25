import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_constants.dart';
import 'package:unprg_guide_maps/core/routes/app_router.dart';
import 'package:unprg_guide_maps/presentation/pages/splash/widgets/widget_splash.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() {
    Timer(Duration(seconds: AppConstants.splashDelay), () {
      Navigator.pushReplacementNamed(context, AppRouter.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedLogo(),
      ),
    );
  }
}
