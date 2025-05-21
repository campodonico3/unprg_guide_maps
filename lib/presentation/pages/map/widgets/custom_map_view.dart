/*import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unprg_guide_maps/core/constants/map_constants.dart';

class CustomMapView extends StatelessWidget {
  final LatLng center;
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;

  const CustomMapView({
    super.key,
    required this.center,
    required this.markers,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: MapConstants.initialZoom,
      ),
      markers: markers,
      mapType: MapType.normal,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      buildingsEnabled: true,
      trafficEnabled: false,
      onMapCreated: onMapCreated,
    );
  }
}*/