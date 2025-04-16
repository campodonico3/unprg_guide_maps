import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  // Coordenadas de ejemplo para la Universidad (ajusta según las coordenadas reales)
  final LatLng _universityLocation = const LatLng(-6.70749760689037, -79.90452516138711); // Coordenadas de UNPRG (ajusta según las reales)
  
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('university'),
        position: _universityLocation,
        infoWindow: const InfoWindow(
          title: 'Universidad Nacional Pedro Ruiz Gallo',
          snippet: 'Campus principal',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Mapa de la Universidad',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _universityLocation,
          zoom: 17,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoomIn",
            backgroundColor: AppColors.primary,
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.zoomIn(),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "zoomOut",
            backgroundColor: AppColors.primary,
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.zoomOut(),
              );
            },
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "myLocation",
            backgroundColor: AppColors.primary,
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_universityLocation, 17),
              );
            },
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}