import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';
import 'package:unprg_guide_maps/presentation/pages/map/pages/flutter_map_page.dart';
import 'package:unprg_guide_maps/widgets/app_layoutbuilder_widget.dart';
import 'package:unprg_guide_maps/widgets/location_search_bottom_sheet.dart';

class ManualRouteInputSheet extends StatefulWidget {
  final List<FacultyItem> allLocations;
  const ManualRouteInputSheet({super.key, required this.allLocations});

  @override
  State<ManualRouteInputSheet> createState() => _ManualRouteInputSheetState();
}

class _ManualRouteInputSheetState extends State<ManualRouteInputSheet> {
  String? originSigla;
  String? destinationSigla;

  void _openLocationSelector({required bool isOrigin}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: LocationSearchBottomSheet(
          onLocationSelected: (FacultyItem selected) {
            setState(() {
              if (isOrigin) {
                originSigla = selected.sigla;
              } else {
                destinationSigla = selected.sigla;
              }
            });
          },
        ),
      ),
    );
  }

  void _cambiarUbicaciones() {
    setState(() {
      final temp = originSigla;
      originSigla = destinationSigla;
      destinationSigla = temp;
    });
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Para ajustarse al contenido
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 4, color: Colors.blueGrey.shade100),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: AppLayoutBuilderWidget(randomDivider: 10),
                        ),
                        Icon(
                          Icons.place,
                          color: Colors.red,
                          size: 26,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _openLocationSelector(isOrigin: true),
                          child: AbsorbPointer(
                            child: TextField(
                              readOnly: true,
                              controller: TextEditingController(
                                  text: originSigla ?? 'Ubicación origen'),
                              decoration: _buildInputDecoration('Origen'),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _openLocationSelector(isOrigin: false),
                          child: AbsorbPointer(
                            child: TextField(
                              readOnly: true,
                              controller: TextEditingController(
                                  text:
                                      destinationSigla ?? 'Ubicación destino'),
                              decoration: _buildInputDecoration('Destino'),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: _cambiarUbicaciones,
              child: Icon(
                Icons.swap_vert,
                color: Colors.black,
                size: 30,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        if (originSigla != null && destinationSigla != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 100,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final origin = widget.allLocations.firstWhere(
                        (f) => f.sigla == originSigla,
                        orElse: () => FacultyItem(
                            name: '', sigla: '', latitude: null, longitude: null, imageAsset: ''));
                    final destination = widget.allLocations.firstWhere(
                        (f) => f.sigla == destinationSigla,
                        orElse: () => FacultyItem(
                            name: '', sigla: '', latitude: null, longitude: null, imageAsset: ''));

                    if (origin.latitude != null &&
                        origin.longitude != null &&
                        destination.latitude != null &&
                        destination.longitude != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlutterMapPage(
                            locations: widget.allLocations,
                            name: destination.name,
                            sigla: destination.sigla,
                            initialLatitude: destination.latitude!,
                            initialLongitude: destination.longitude!,
                            manualOrigin: LatLng(origin.latitude!, origin.longitude!),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coordenadas no disponibles')),
                      );
                    }
                  },                  
                  label: const Text(
                    'Ver ruta',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
