import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/app_style.dart';
import 'package:unprg_guide_maps/presentation/pages/home/widgets/marquee_on_old.dart';

class FacultyCard extends StatelessWidget {
  final String name;
  final String sigla;
  final String imageAsset;

  const FacultyCard({
    super.key,
    required this.name,
    required this.sigla,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Image.asset(
              imageAsset,
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sigla,
                    style: AppTextStyles.black.copyWith(
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                    
                    /*TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),*/
                  ),
                  MarqueeOnOld(
                    text: name,
                    textStyle: AppTextStyles.regular.copyWith(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                    /*TextStyle(
                      fontSize: 14,
                    ),*/
                    height: 60,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
