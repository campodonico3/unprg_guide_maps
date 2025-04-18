import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';

class FlutterMapPage extends StatefulWidget {
  final String? title;
  final String? sigla;
  final double initialLatitude;
  final double initialLongitude;

  const FlutterMapPage({
    super.key,
    this.title,
    this.sigla,
    this.initialLatitude = -6.70749760689037,
    this.initialLongitude = -79.90452516138711,
  });

  @override
  State<FlutterMapPage> createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage> {
  late final LatLng _center;
  final double _initialZoom = 16.0;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _center = LatLng(
      widget.initialLatitude,
      widget.initialLongitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          widget.title != null ? widget.title! : 'Mapa del Campus',
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
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: _initialZoom,
          maxZoom: 18.0,
          minZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.unprg_guide_maps',
            maxZoom: 19,
          ),
          MarkerLayer(
            markers: [

              _buildMarker(_center, widget.title ?? "Campus Principal", widget.sigla),
    
              // Example markers for various university buildings
              /*_buildMarker(_center, "Campus Principal"),
              _buildMarker(
                LatLng(_center.latitude + 0.001, _center.longitude + 0.001),
                "Facultad de Ingeniería",
              ),
              _buildMarker(
                LatLng(_center.latitude - 0.001, _center.longitude - 0.001),
                "Biblioteca Central",
              ),
              // Add more markers as needed*/
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              final newZoom = _mapController.camera.zoom + 1;
              _mapController.move(_mapController.camera.center, newZoom);
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.remove, color: Colors.white),
            onPressed: () {
              final newZoom = _mapController.camera.zoom - 1;
              _mapController.move(_mapController.camera.center, newZoom);
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "my_location",
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () {
              _mapController.move(_center, _initialZoom);
            },
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(LatLng position, String title, String? sigla) {
    return Marker(
      width: 40.0,
      height: 40.0,
      point: position,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(title),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 24,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
