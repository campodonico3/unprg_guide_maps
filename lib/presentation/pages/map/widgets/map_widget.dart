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
          myLocationEnabled: !mapController
              .showMultipleMarkers, // Deshabilitar si usamos marcador personalizado
          zoomControlsEnabled: false,
        );
      },
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (mapController.showMultipleMarkers) {
      // Modo múltiples marcadores
      markers.addAll(mapController.locationMarkers);

      // Agregar marcador de usuario si existe
      if (mapController.userMarker != null) {
        markers.add(mapController.userMarker!);
      }
    } else {
      // 📍 Modo marcador único (ruta entre 2 puntos)

      // 1. Marcador de destino
      final destinationMarkerId = MarkerId(sigla ?? 'destination_marker');
      final destinationMarker = Marker(
        markerId: destinationMarkerId,
        position: LatLng(initialLatitude, initialLongitude),
        infoWindow: InfoWindow(title: sigla),
        onTap: () {
          mapController.onMarkerTapped(destinationMarkerId);
        },
      );
      markers.add(destinationMarker);

      // 2. Marcador de origen manual (si se ha definido)
      if (mapController.manualOrigin != null) {
        final originMarkerId = MarkerId(sigla ?? 'destination_marker');
        final originMarker = Marker(
          markerId: originMarkerId,
          position: mapController.manualOrigin!,
          infoWindow: InfoWindow(title: sigla),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onTap: () {
            mapController.onMarkerTapped(originMarkerId);
          },
        );
        markers.add(originMarker);
      }

      // 3. Marcador del usuario (ubicación en tiempo real)
      if (mapController.userMarker != null) {
        final userM = mapController.userMarker!;
        markers.add(userM.copyWith(
          onTapParam: () {
            mapController.onMarkerTapped(userM.markerId);
          },
        ));
      }
    }
    return markers;
  }
}
