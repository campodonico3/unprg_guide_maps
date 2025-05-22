import 'package:flutter/material.dart';

class MapConstants {
  // Map zoom levels
  static const double initialZoom = 18.0;
  static const double maxZoom = 19.0;
  static const double minZoom = 12.0;

  // Card dimensions
  static const double collapsedCardHeight = 120.0;
  static const double expandedCardHeight = 665.0;

  // Marker dimensions
  static const double markerWidth = 80.0;
  static const double markerHeight = 80.0;

  // Card gesture threshold
  static const double dragThreshold = 300.0;

  // Margins and padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Route styling
  static const double routeLineWidth = 4.0;
  //static const Color routeColor = Colors.orange;
  static const double routePointRadius = 8.0;

  // Constantes para la pagina mapa
  static const String googleApiKey = "AIzaSyA-v4R7vSN0nEb-U_m_mE_vjm55hwUjtj0";
  static const double defaultZoom = 16.0;
  static const int polylineWidth = 5;
  static const int connectorWidth = 3;
  static const Color routeColor = Colors.blue;
  static const Color connectorColor = Colors.grey;
  static const double minDistanceThreshold = 0.0001;

  // Para el card cuando aparezca y desaparezca
  static const double fabDefaultBottom = 1;
  // Aproxima la altura de tu InfoCard + margenes
  static const double infoCardHeightApprox = 255;
}
