/* import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationResult {
  final LatLng position;
  final LocationData rawData;
  
  LocationResult(this.position, this.rawData);
}

class LocationService {
  final Location _locationService = Location();
  
  Future<LocationResult?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    PermissionStatus permission = await _locationService.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _locationService.requestPermission();
      if (permission != PermissionStatus.granted) {
        // Mostrar snackbar si el contexto está disponible
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requieren permisos de ubicación para esta función'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return null;
      }
    }
    
    try {
      LocationData locationData = await _locationService.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        return LocationResult(
          LatLng(locationData.latitude!, locationData.longitude!),
          locationData
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener la ubicación: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    
    return null;
  }
} */