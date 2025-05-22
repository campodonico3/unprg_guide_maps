import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:unprg_guide_maps/core/services/location_service.dart';
import 'package:unprg_guide_maps/core/services/polyline_service.dart';

class MapController extends ChangeNotifier {
  final double initialLatitude;
  final double initialLongitude;
  
  GoogleMapController? _googleMapController;
  final LocationService _locationService = LocationService();
  final PolylineService _polylineService = PolylineService();
  
  StreamSubscription<LocationData>? _locationSubscription;
  Marker? _userMarker;
  Set<Polyline> _polylines = {};
  
  // Getters
  Marker? get userMarker => _userMarker;
  Set<Polyline> get polylines => _polylines;
  CameraPosition get initialPosition => CameraPosition(
    target: LatLng(initialLatitude, initialLongitude),
    zoom: 16,
  );

  MapController({
    required this.initialLatitude,
    required this.initialLongitude,
  });

  Future<void> initialize() async {
    await _locationService.initialize();
    _startLocationTracking();
  }

  void onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }

  void _startLocationTracking() {
    _locationSubscription = _locationService.locationStream.listen(_onLocationUpdate);
    
    // Obtener ruta inicial
    Future.delayed(const Duration(seconds: 1), _getInitialRoute);
  }

  void _onLocationUpdate(LocationData locationData) {
    if (locationData.latitude == null || locationData.longitude == null) return;
    
    final latLng = LatLng(locationData.latitude!, locationData.longitude!);
    _updateUserMarker(latLng);
    _updatePolyline(latLng);
  }

  void _updateUserMarker(LatLng position) {
    _googleMapController?.animateCamera(CameraUpdate.newLatLng(position));
    
    _userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Aquí estás tú'),
    );
    notifyListeners();
  }

  Future<void> _updatePolyline(LatLng origin) async {
    final destination = LatLng(initialLatitude, initialLongitude);
    _polylines = await _polylineService.createRoute(origin, destination);
    notifyListeners();
  }

  Future<void> _getInitialRoute() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      await _updatePolyline(location);
    }
  }

  Future<void> recalculateRoute() async {
    final currentLocation = _userMarker?.position ?? 
        await _locationService.getCurrentLocation();
    
    if (currentLocation != null) {
      await _updatePolyline(currentLocation);
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _googleMapController?.dispose();
    super.dispose();
  }
}