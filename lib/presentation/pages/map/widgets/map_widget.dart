import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unprg_guide_maps/presentation/pages/map/controller/map_controller.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final String? sigla;
  final String? name;
  final double initialLatitude;
  final double initialLongitude;

  const MapWidget({
    super.key,
    required this.mapController,
    this.sigla,
    this.name,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: mapController,
      builder: (context, _) {
        return GoogleMap(
          onMapCreated: mapController.onMapCreated,
          initialCameraPosition: mapController.initialPosition,
          markers: _buildMarkers(),
          polylines: mapController.polylines,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
        );
      },
    );
  }

  Set<Marker> _buildMarkers() {
    final destinationMarkerId = MarkerId(sigla ?? 'destination_marker');

    // Marcador de destino con callback onTap
    final destinationMarker = Marker(
      markerId: destinationMarkerId,
      position: LatLng(initialLatitude, initialLongitude),
      infoWindow: InfoWindow(
        title: sigla,
      ),
      onTap: () {
        mapController.onMarkerTapped(destinationMarkerId);
      },
    );

    final markers = <Marker>{destinationMarker};  

    // Si hay marcador de usuario, le agregamos también onTap si queremos:
    if(mapController.userMarker != null) {
      final userM = mapController.userMarker!;
      markers.add(userM.copyWith(
        onTapParam: () {
          mapController.onMarkerTapped(userM.markerId);
        },
      ));
    }
    return markers;
  }
}
