import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/assets_path.dart';
import 'package:unprg_guide_maps/core/routes/app_router.dart';
import 'package:unprg_guide_maps/presentation/pages/onboarding/widgets/onboarding_card.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    final pages = [
      OnboardingCardData(
        title: 'BIENVENIDO A\n\'UNIVERSIDAD MAPS\'',
        subtitle: 'Tu guía en el campus universitario',
        image: AssetsPath.onboardingImage2,
        backgroundColor: AppColors.primary,
        titleColor: Colors.white,
        subtitleColor: Colors.white,
      ),
      OnboardingCardData(
        title: 'Aquí encontrarás distintos puntos del campus',
        subtitle: 'Edificios, facultades y áreas comunes',
        image: AssetsPath.onboardingImage1,
        backgroundColor: AppColors.secondary,
        titleColor: Colors.white,
        subtitleColor: Colors.white,
      ),
      OnboardingCardData(
        title: 'Podrás llegar a tiempo a tus clases',
        subtitle: 'Con rutas optimizadas y búsqueda fácil',
        image: AssetsPath.onboardingImage1,
        backgroundColor: AppColors.accent,
        titleColor: Colors.white,
        subtitleColor: Colors.white,
      ),
    ];

    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.backgroundColor).toList(),
        itemCount: pages.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (int index) {
          return OnboardingCard(
            data: pages[index],
          );
        },
        onChange: (index){
          print(index);
        },
        onFinish: () {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        },

      ),
    );
  }
}