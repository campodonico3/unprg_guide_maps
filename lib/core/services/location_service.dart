import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();
  
  Stream<LocationData> get locationStream => _location.onLocationChanged;

  Future<void> initialize() async {
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        return LatLng(locationData.latitude!, locationData.longitude!);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
    return null;
  }
}