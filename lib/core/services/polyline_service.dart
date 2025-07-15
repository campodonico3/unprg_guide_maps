import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/point_latlng.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';

// Clase de servicio para manejar la creación de polylines (rutas) en Google Map
class PolylineService {
  // Clave API de Google Maps (constante estática)
  static const String _apiKey = "AIzaSyA-v4R7vSN0nEb-U_m_mE_vjm55hwUjtj0";
  // Color azul para las rutas principales
  static const Color _routeColor = Colors.blue;
  // Color gris para las líneas conectoras
  static const Color _connectorColor = Colors.grey;

  // Instancia del objeto GoogleMapsPolyline para obtener rutas de la API
  final GoogleMapsPolyline _polylinePoints = GoogleMapsPolyline();

  /// Método público principal para crear una ruta entre dos puntos
  Future<Set<Polyline>> createRoute(LatLng origin, LatLng destination) async {
    try {
      // Intenta obtener la ruta desde la API de Google Maps
      final result = await _getRouteFromAPI(origin, destination);

      // Si la API devuelve una ruta válida con puntos
      if (result != null && result.isNotEmpty) {
        // Crea polylines complejas con conectores
        return _createComplexPolylines(origin, destination, result);
      } else {
        // Si no hay ruta de la API, crea una línea directa
        return _createDirectLine(origin, destination);
      }
    } catch (e) {
      print('Error creating route: $e');
      // Retorna una línea directa como fallback
      return _createDirectLine(origin, destination);
    }
  }

  // Método privado para obtener la ruta desde la API de Google Maps
  Future<List<LatLng>?> _getRouteFromAPI(
      LatLng origin, LatLng destination) async {
    // Convierte el punto de origen a formato MyPointLatLng
    final originPoint = MyPointLatLng(origin.latitude, origin.longitude);
    // Convierte el punto de destino a formato MyPointLatLng
    final destinationPoint =
        MyPointLatLng(destination.latitude, destination.longitude);

    // Llama a la API de Google Maps para obtener la ruta
    final result = await _polylinePoints.getRouteBetweenCoordinates(
      _apiKey, // Clave API
      originPoint, // Punto de origen
      destinationPoint, // Punto de destino
      travelMode: MyTravelMode.walking, // Modo de viaje: caminando
    );

    // Verifica si la respuesta es exitosa y tiene puntos
    if ((result.status == "OK" || result.status == "ok") &&
        result.points.isNotEmpty) {
      // Filtra puntos válidos (que tengan latitud y longitud)
      return result.points
          .where((point) => point.latitude != null && point.longitude != null)
          // Convierte cada punto a LatLng de Google Maps
          .map((point) => LatLng(point.latitude!, point.longitude!))
          // Convierte a lista
          .toList();
    }
    // Si no hay ruta válida, retorna null
    return null;
  }

  /// Método para crear polylines complejas con conectores
  Set<Polyline> _createComplexPolylines(
    LatLng origin,
    LatLng destination,
    List<LatLng> routePoints,
  ) {
    // Encuentra el punto más cercano al origen en la ruta
    final nearestToOrigin = _findNearestPoint(origin, routePoints);
    // Encuentra el punto más cercano al destino en la ruta
    final nearestToDestination = _findNearestPoint(destination, routePoints);

    // Crea un conjunto de polylines comenzando con la ruta principal
    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('main_route'), // ID único para la ruta
        color: _routeColor, // Color azul
        points: routePoints, // Puntos de la ruta
        width: 5, // Grosor de la línea
      ),
    };

    // Si el origen está lejos del punto más cercano en la ruta
    if (_calculateDistance(origin, nearestToOrigin) > 0.0001) {
      // Agrega una línea conectora desde el origen hasta la ruta
      polylines.add(_createConnectorPolyline(
        'origin_connector', // ID del conector
        [origin, nearestToOrigin], // Puntos: origen y punto más cercano
      ));
    }

    // Si el destino está lejos del punto más cercano en la ruta
    if (_calculateDistance(destination, nearestToDestination) > 0.0001) {
      // Agrega una línea conectora desde la ruta hasta el destino
      polylines.add(_createConnectorPolyline(
        'destination_connector', // ID del conector
        [
          nearestToDestination,
          destination
        ], // Puntos: punto más cercano y destino
      ));
    }
    // Retorna el conjunto de polylines
    return polylines;
  }

  /// Método para crear una línea directa entre dos puntos (fallback)
  Set<Polyline> _createDirectLine(LatLng origin, LatLng destination) {
    return {
      Polyline(
        polylineId: const PolylineId('direct_route'), // ID único
        color: _routeColor, // Color azul
        points: [origin, destination], // Solo origen y destino
        width: 4, // Grosor menor
        patterns: [
          // Patrón de línea punteada
          PatternItem.dash(10), // Dash de 10 unidades
          PatternItem.gap(10), // Gap de 10 unidades
        ],
      ),
    };
  }

  /// Método para crear una polyline conectora (línea auxiliar)
  Polyline _createConnectorPolyline(String id, List<LatLng> points) {
    return Polyline(
      polylineId: PolylineId(id), // ID único basado en el parámetro
      color: _connectorColor, // Color gris
      points: points, // Puntos de la línea conectora
      width: 3, // Grosor menor que la ruta principal
      patterns: [
        // Patrón punteado
        PatternItem.dash(10), // Dash de 10 unidades
        PatternItem.gap(10), // Gap de 10 unidades
      ],
    );
  }

  /// Método para encontrar el punto más cercano a un objetivo
  LatLng _findNearestPoint(LatLng target, List<LatLng> points) {
    // Si no hay puntos, retorna el objetivo mismo
    if (points.isEmpty) return target;

    // Inicializa la distancia mínima como infinito
    double minDistance = double.infinity;
    // Toma el primer punto como el más cercano inicialmente
    LatLng nearest = points[0];

    // Itera sobre todos los puntos
    for (final point in points) {
      // Calcula la distancia entre el objetivo y el punto actual
      final distance = _calculateDistance(target, point);
      // Si esta distancia es menor que la mínima encontrada
      if (distance < minDistance) {
        // Actualiza la distancia mínima
        minDistance = distance;
        // Actualiza el punto más cercano
        nearest = point;
      }
    }
    // Retorna el punto más cercano encontrado
    return nearest;
  }

  /// Método para calcular la distancia euclidiana entre dos puntos
  double _calculateDistance(LatLng point1, LatLng point2) {
    // Fórmula: √[(lat1-lat2)² + (lng1-lng2)²]
    return sqrt(pow(point1.latitude - point2.latitude, 2) + pow(point1.longitude - point2.longitude, 2));
  }
}
