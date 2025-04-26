import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/app_style.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';
//import 'package:unprg_guide_maps/presentation/pages/home/widgets/marquee_on_old.dart';
import 'package:unprg_guide_maps/presentation/pages/map/pages/flutter_map_page.dart';

class FacultyCard extends StatelessWidget {
  final String name;
  final String sigla;
  final String imageAsset;
  final double? latitude;
  final double? longitude;
  final List<FacultyItem> allLocations; // Nuevo parámetro

  const FacultyCard({
    super.key,
    required this.name,
    required this.sigla,
    required this.imageAsset,
    required this.allLocations,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (latitude != null && longitude != null) {
          // Navegar al mapa con la ubicación de la facultad u oficina
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlutterMapPage(
                locations: allLocations,
                name: name,
                sigla: sigla,
                initialLatitude: latitude ?? -6.70749760689037,
                initialLongitude: longitude ?? -79.90452516138711,
              ),
            ),
          );
        } else {
          // Handle the case when latitude and longitude are not provided
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ubicación no disponible'),
            ),
          );
        }
      },
      child: Card(
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
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sigla,
                      style: AppTextStyles.black.copyWith(
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      name.startsWith('Facultad de') 
                          ? name.replaceFirst('Facultad de', '').trim()
                          : name,
                      style: AppTextStyles.regular.copyWith(
                        fontSize: 10.5,
                        color: AppColors.textPrimary
                      ),
                    ),
                    /*MarqueeOnOld(
                      text: name,
                      textStyle: AppTextStyles.regular.copyWith(
                        fontSize: 8,
                        color: AppColors.black,
                      ),
                      height: 60,
                    )*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
