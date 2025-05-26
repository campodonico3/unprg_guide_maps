import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:unprg_guide_maps/core/services/location_service.dart';
import 'package:unprg_guide_maps/core/services/marker_service.dart';
import 'package:unprg_guide_maps/core/services/polyline_service.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';

const _noPoiTransitStyle = '''[
  {
    "featureType": "poi",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "transit",
    "stylers": [{ "visibility": "off" }]
  }
]''';

class MapController extends ChangeNotifier {
  final double initialLatitude;
  final double initialLongitude;
  final String? name;
  final String? sigla;
  final List<FacultyItem>?
      allLocations; // Nueva propiedad para todas las ubicaciones
  final bool
      showMultipleMarkers; // Nueva propiedad para mostrar múltiples marcadores

  bool _showInfoCard = false;

  GoogleMapController? _googleMapController;
  final LocationService _locationService = LocationService();
  final PolylineService _polylineService = PolylineService();
  final MarkerService _markerService = MarkerService();

  StreamSubscription<LocationData>? _locationSubscription;
  Marker? _userMarker;
  Set<Polyline> _polylines = {};
  Set<Marker> _locationMarkers = {};
  String? _selectedLocationId;

  // Getters
  Marker? get userMarker => _userMarker;
  Set<Polyline> get polylines => _polylines;
  Set<Marker> get locationMarkers => _locationMarkers;
  String? get selectedLocationId => _selectedLocationId;
  bool get showInfoCard => _showInfoCard;

  // Inicializar la posición de la cámara
  CameraPosition get initialPosition => CameraPosition(
        target: LatLng(initialLatitude, initialLongitude),
        zoom: showMultipleMarkers ? 14 : 16,
      );

  MapController({
    required this.initialLatitude,
    required this.initialLongitude,
    this.name,
    this.sigla,
    this.allLocations,
    this.showMultipleMarkers = false,
  });

  Future<void> initialize() async {
    await _locationService.initialize();

    if (showMultipleMarkers) {
      await _markerService.initialize();
      await _createMultipleMarkers();
    }

    _startLocationTracking();
  }

  Future<void> _createMultipleMarkers() async {
    if (allLocations == null) return;

    final markers = <Marker>{};

    for (final location in allLocations!) {
      if (location.latitude != null && location.longitude != null) {
        final marker = await _markerService.createLocationMarker(
          location.sigla,
          LatLng(location.latitude!, location.longitude!),
          location.name,
          false,
          onTap: () => _onLocationMarkerTapped(location.sigla),
        );
        markers.add(marker);
      }
    }
    _locationMarkers = markers;
    notifyListeners();
  }

  void _onLocationMarkerTapped(String locationId) {
    _selectedLocationId = locationId;
    _showInfoCard = true;
    notifyListeners();
  }

  FacultyItem? getSelectedLocation() {
    if (_selectedLocationId == null || allLocations == null) return null;

    try {
      return allLocations!.firstWhere(
        (location) => location.sigla == _selectedLocationId,
      );
    } catch (e) {
      return null; // Si no se encuentra, retornar null
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    controller.setMapStyle(_noPoiTransitStyle);
    notifyListeners();
  }

  void onMarkerTapped(MarkerId markerId) {
    if (showMultipleMarkers) {
      _onLocationMarkerTapped(markerId.value);
    }
    // Solo mostrar el card si es el marcador de destino
    else {
      if (markerId.value == sigla) {
        _showInfoCard = true;
        notifyListeners();
      }
    }
  }

  void hideInfoCard() {
    _showInfoCard = false;
    _selectedLocationId = null;
    notifyListeners();
  }

  void _startLocationTracking() {
    _locationSubscription =
        _locationService.locationStream.listen(_onLocationUpdate);

    // Solo obtener ruta inicial si no es modo múltiples marcadores
    if (!showMultipleMarkers){
      Future.delayed(const Duration(seconds: 1), _getInitialRoute);
    }    
  }

  void _onLocationUpdate(LocationData locationData) {
    if (locationData.latitude == null || locationData.longitude == null) return;

    final latLng = LatLng(locationData.latitude!, locationData.longitude!);
    _updateUserMarker(latLng);

    // Solo actualizar polyline si no es modo múltiples marcadores
    if (!showMultipleMarkers){
      _updatePolyline(latLng);
    }
  }

  void _updateUserMarker(LatLng position) {
    //_googleMapController?.animateCamera(CameraUpdate.newLatLng(position));
    if(showMultipleMarkers){
      // En modo múltiples marcadores, no actualizamos el marcador del usuario
      _createCustomUserMarker(position);
    }else{
      // En modo individual, usar el marcador por defecto
      _userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Aquí estás tú'),
      );    
    }
    notifyListeners();
  }

  Future<void> _createCustomUserMarker(LatLng position) async {
    _userMarker = await _markerService.createUserLocationMarker(
      position,
      onTap: () {
        // Mostrar información de ubicación del usuario
      },
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
    if (showMultipleMarkers) return; // En modo múltiples marcadores, no recalculamos la ruta

    final currentLocation =
        _userMarker?.position ?? await _locationService.getCurrentLocation();

    if (currentLocation != null) {
      await _updatePolyline(currentLocation);
    }
  }

  // Método para centrar el mapa en una ubicación específica
  void centerOnLocation(String locationId) {
    if (allLocations == null || _googleMapController == null) return;

    try {
      final location = allLocations!.firstWhere(
        (loc) => loc.sigla == locationId,
      );

      if (location.latitude != null && location.longitude != null) {
        _googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(location.latitude!, location.longitude!),
              zoom: 18,
            ),
          ),
        );
      }

    }catch (e) {
      debugPrint('Error al centrar en la ubicación: $e');
    }
  }

  void showAllLocations() {
    if (allLocations == null || _googleMapController == null) return;

    final validLocations = allLocations!
        .where((loc) => loc.latitude != null && loc.longitude != null)
        .toList();

    if (validLocations.isEmpty) return;

    // Calcular bounds para todas las ubicaciones
    double minLat = validLocations.first.latitude!;
    double maxLat = validLocations.first.latitude!;
    double minLng = validLocations.first.longitude!;
    double maxLng = validLocations.first.longitude!;

    for (final location in validLocations){
      minLat = minLat < location.latitude! ? minLat : location.latitude!;
      maxLat = maxLat > location.latitude! ? maxLat : location.latitude!;
      minLng = minLng < location.longitude! ? minLng : location.longitude!;
      minLng = maxLng > location.longitude! ? maxLng : location.longitude!;
    }

    // Incluir ubicación del usuario si está disponible
    if(_userMarker != null) {
      final userPos = _userMarker!.position;
      minLat = minLat < userPos.latitude ? minLat : userPos.latitude;
      maxLat = maxLat > userPos.latitude ? maxLat : userPos.latitude;
      minLng = minLng < userPos.longitude ? minLng : userPos.longitude;
      maxLng = maxLng > userPos.longitude ? maxLng : userPos.longitude;  
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng), 
      northeast: LatLng(maxLat, maxLng),
    );

    _googleMapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0),);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _googleMapController?.dispose();
    super.dispose();
  }
}
