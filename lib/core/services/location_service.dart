import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  // Crea una instancia de la clase Location para acceder a la ubicación
  final Location _location = Location();
  
  // Devuelve un Stream (flujo) de datos de ubicación que emite actualizaciones cuando cambia la ubicación
  Stream<LocationData> get locationStream => _location.onLocationChanged;

  // Método público que inicializa el servicio de ubicación, solicitando permisos si es necesario
  Future<void> initialize() async {
    await _requestPermissions();
  }

  // Método privado que solicita permisos de ubicación al usuario
  Future<void> _requestPermissions() async {
    // Verifica si el servicio de ubicación está habilitado en el dispositivo
    bool serviceEnabled = await _location.serviceEnabled();

    // Si no está habilitado, se solicita al usuario que lo habilite
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      // Si el usuario no habilita el servicio, se retorna sin continuar
      if (!serviceEnabled) return;
    }

  // Verifica si el permiso de ubicación ha sido otorgado
    PermissionStatus permissionGranted = await _location.hasPermission();

    // Si el permiso está denegado, se solicita permiso
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      // Si el permiso no se otorga, se retorna sin continuar
      if (permissionGranted != PermissionStatus.granted) return;
    }
  }

  // Método que obtiene la ubicación actual del dispositivo y la devuelve como LatLng
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Intenta obtener la ubicación actual
      final locationData = await _location.getLocation();
      
      // Verifica si la latitud y longitud no son nulas
      if (locationData.latitude != null && locationData.longitude != null) {
        // Devuelve la ubicación como un objeto LatLng
        return LatLng(locationData.latitude!, locationData.longitude!);
      }
    } catch (e) {
      // Imprime un mensaje de error si ocurre alguna excepción
      print('Error getting location: $e');
    }
    // Si no se puede obtener la ubicación, retorna null
    return null;
  }
}