import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng _universityLocation = LatLng(-6.70749760689037, -79.90452516138711);
  final MapController _mapController = MapController();
  final double _btnSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Mapa de la Universidad Nacional de Pedro Ruiz Gallo',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textOnPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _universityLocation,
          initialZoom: 17.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.unprg_guide_maps',
          ),
          MarkerLayer(markers: [
            Marker(
              width: 40.0,
              height: 40.0,
              point: _universityLocation,
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 40.0,
              ),
            ),
          ])
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: _btnSize,
            width: _btnSize,
            child: FloatingActionButton(
              heroTag: "zoomIn",
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.zoom_in,
                color: AppColors.background,
              ),
              onPressed: () {
                _mapController.move(
                    _mapController.camera.center, _mapController.camera.zoom + 1);
              },
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: _btnSize,
            width: _btnSize,
            child: FloatingActionButton(
              heroTag: "zoomOut",
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.zoom_out,
                color: AppColors.background,
              ),
              onPressed: () {
                _mapController.move(
                    _mapController.camera.center, _mapController.camera.zoom - 1);
              },
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: _btnSize,
            width: _btnSize,
            child: FloatingActionButton(
              heroTag: "currentLocation",
              backgroundColor: AppColors.primary,
              onPressed: () {
                _mapController.move(_universityLocation, 17.0);
              },
              child: Icon(
                Icons.my_location,
                color: AppColors.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
