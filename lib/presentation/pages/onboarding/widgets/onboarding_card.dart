import 'package:flutter/material.dart';

class OnboardingCardData {
  final String title;
  final String subtitle;
  final String image;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;

  OnboardingCardData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
  });
}

class OnboardingCard extends StatelessWidget {
  final OnboardingCardData data;

  const OnboardingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  data.image,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
              ),
              Text(
                data.title,
                style: TextStyle(
                  color: data.titleColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
