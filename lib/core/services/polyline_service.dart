import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/point_latlng.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';

class PolylineService {
  static const String _apiKey = "AIzaSyA-v4R7vSN0nEb-U_m_mE_vjm55hwUjtj0";
  static const Color _routeColor = Colors.blue;
  static const Color _connectorColor = Colors.grey;
  
  final GoogleMapsPolyline _polylinePoints = GoogleMapsPolyline();

  Future<Set<Polyline>> createRoute(LatLng origin, LatLng destination) async {
    try {
      final result = await _getRouteFromAPI(origin, destination);
      
      if (result != null && result.isNotEmpty) {
        return _createComplexPolylines(origin, destination, result);
      } else {
        return _createDirectLine(origin, destination);
      }
    } catch (e) {
      print('Error creating route: $e');
      return _createDirectLine(origin, destination);
    }
  }

  Future<List<LatLng>?> _getRouteFromAPI(LatLng origin, LatLng destination) async {
    final originPoint = MyPointLatLng(origin.latitude, origin.longitude);
    final destinationPoint = MyPointLatLng(destination.latitude, destination.longitude);
    
    final result = await _polylinePoints.getRouteBetweenCoordinates(
      _apiKey,
      originPoint,
      destinationPoint,
      travelMode: MyTravelMode.walking,
    );

    if ((result.status == "OK" || result.status == "ok") && result.points.isNotEmpty) {
      return result.points
          .where((point) => point.latitude != null && point.longitude != null)
          .map((point) => LatLng(point.latitude!, point.longitude!))
          .toList();
    }
    
    return null;
  }

  Set<Polyline> _createComplexPolylines(
    LatLng origin, 
    LatLng destination, 
    List<LatLng> routePoints
  ) {
    final nearestToOrigin = _findNearestPoint(origin, routePoints);
    final nearestToDestination = _findNearestPoint(destination, routePoints);
    
    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('main_route'),
        color: _routeColor,
        points: routePoints,
        width: 5,
      ),
    };

    if (_calculateDistance(origin, nearestToOrigin) > 0.0001) {
      polylines.add(_createConnectorPolyline(
        'origin_connector',
        [origin, nearestToOrigin],
      ));
    }

    if (_calculateDistance(destination, nearestToDestination) > 0.0001) {
      polylines.add(_createConnectorPolyline(
        'destination_connector',
        [nearestToDestination, destination],
      ));
    }

    return polylines;
  }

  Set<Polyline> _createDirectLine(LatLng origin, LatLng destination) {
    return {
      Polyline(
        polylineId: const PolylineId('direct_route'),
        color: _routeColor,
        points: [origin, destination],
        width: 4,
        patterns: [
          PatternItem.dash(10),
          PatternItem.gap(10),
        ],
      ),
    };
  }

  Polyline _createConnectorPolyline(String id, List<LatLng> points) {
    return Polyline(
      polylineId: PolylineId(id),
      color: _connectorColor,
      points: points,
      width: 3,
      patterns: [
        PatternItem.dash(10),
        PatternItem.gap(10),
      ],
    );
  }

  LatLng _findNearestPoint(LatLng target, List<LatLng> points) {
    if (points.isEmpty) return target;
    
    double minDistance = double.infinity;
    LatLng nearest = points[0];
    
    for (final point in points) {
      final distance = _calculateDistance(target, point);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = point;
      }
    }
    
    return nearest;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return sqrt(
      pow(point1.latitude - point2.latitude, 2) + 
      pow(point1.longitude - point2.longitude, 2)
    );
  }
}