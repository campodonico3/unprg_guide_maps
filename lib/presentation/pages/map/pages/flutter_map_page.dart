import 'dart:async';
import 'dart:math' show sqrt, pow;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';
import 'package:location/location.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/point_latlng.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/utils/result_polyline.dart';

class FlutterMapPage extends StatefulWidget {
  final List<FacultyItem> locations;
  final String? name;
  final String? sigla;
  final double initialLatitude;
  final double initialLongitude;

  const FlutterMapPage({
    super.key,
    required this.locations,
    this.name,
    this.sigla,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FlutterMapPageState createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage> {
  late GoogleMapController _mapController;
  late CameraPosition _initialPosition;
  final Location _locationService = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  Marker? _userMarker;

  // Para las polilíneas
  final Set<Polyline> polylines = {};
  final GoogleMapsPolyline polylinePoints = GoogleMapsPolyline();
  final String googleApiKey = "AIzaSyA-v4R7vSN0nEb-U_m_mE_vjm55hwUjtj0";

  // Colores y estilos para las polilíneas
  static const Color routeColor = Colors.blue;
  static const Color connectorColor = Colors.grey;
  static const List<int> connectorPattern = [5, 5];

  @override
  void initState() {
    super.initState();

    // Imprime en la terminal al iniciar el widget
    print('🔵 FlutterMapPage => initialLatitude: ${widget.initialLatitude}');
    print('🔵 FlutterMapPage => initialLongitude: ${widget.initialLongitude}');

    // Initialize camera position
    _initialPosition = CameraPosition(
      target: LatLng(widget.initialLatitude, widget.initialLongitude),
      zoom: 16,
    );

    // Inicializa el servicio de ubicación
    _initLocationService();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _initLocationService() async {
    // Servicio de GPS
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    // Permisos
    PermissionStatus permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Escucha cambios de la ubicación
    _locationSubscription =
        _locationService.onLocationChanged.listen((LocationData loc) {
      if (loc.latitude == null || loc.longitude == null) return;
      final LatLng latLng = LatLng(loc.latitude!, loc.longitude!);

      // Print para la consola
      print('📍 Ubicación actual: ${loc.latitude}, ${loc.longitude}');

      // Mueve cámara al nuevo punto
      _mapController.animateCamera(CameraUpdate.newLatLng(latLng));

      // Actualiza el marcador del usuario
      setState(() {
        _userMarker = Marker(
          markerId: const MarkerId('user_location'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'Aqui estás tú'),
        );

        // Actualiza la polilínea cada vez que cambia la ubicación del usuario
        _getPolyline(
          origin: latLng,
          destination: LatLng(
            widget.initialLatitude,
            widget.initialLongitude,
          ),
        );
      });
    });

    // Obtener ruta inicial cuando se crean los marcadores pero antes de cualquier actualización
    Future.delayed(Duration(seconds: 1),() {
      //Intentamos obtener la ubicación actual para crear una polilínea inicial
      _locationService.getLocation().then((location){
        if(location.latitude != null && location.longitude != null){
          _getPolyline(origin: LatLng(location.latitude!, location.longitude!), 
          destination: LatLng(
            widget.initialLatitude,
            widget.initialLongitude,
          ));
        }
      });
    });
  }

  // Método para obtener la polyline entre dos puntos
  Future<void> _getPolyline({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      // Imprimir información para depuración
      print('📍 Solicitando ruta desde: ${origin.latitude}, ${origin.longitude}');
      print('📍 Hasta: ${destination.latitude}, ${destination.longitude}');
      
      // Obtener puntos de la polyline
      MyPointLatLng originPoint = MyPointLatLng(origin.latitude, origin.longitude);
      MyPointLatLng destinationPoint = MyPointLatLng(destination.latitude, destination.longitude);
      
      ResultPolyline result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        originPoint,
        destinationPoint,
        travelMode: MyTravelMode.walking, // Puedes cambiar a driving, cycling, etc.
      );
      
      // Información detallada de depuración
      print('🔵 Estado de la respuesta: ${result.status}');
      print('🔢 Cantidad de puntos recibidos: ${result.points.length}');
      
      // El estado es "OK" pero verificamos explícitamente si hay puntos
      if ((result.status == "OK" || result.status == "ok") && result.points.isNotEmpty) {
        // Convertir los puntos recibidos a formato LatLng para la polyline
        List<LatLng> polylineCoordinates = [];
        
        for (var point in result.points) {
          // Verificar si los puntos son nulos
          if (point.latitude == null || point.longitude == null) {
            print('⚠️ Punto con coordenadas nulas detectado, omitiendo...');
            continue;
          }
          
          polylineCoordinates.add(LatLng(point.latitude!, point.longitude!));
        }
        
        if (polylineCoordinates.isEmpty) {
          print('⚠️ No se pudieron convertir puntos válidos');
          return;
        }
        
        // Crear las polylines
        _createAndSetPolylines(
          origin: origin,
          destination: destination,
          routePoints: polylineCoordinates,
        );
        
        print('✅ Polylines creadas con ${polylineCoordinates.length} puntos');
      } else {
        print('❌ No se pudo obtener la polyline: ${result.status}');
        
        // Si la API falla, creamos una línea directa entre origen y destino
        _createDirectLine(origin, destination);
      }
    } catch (e) {
      print('❌ Error al crear polyline: $e');
      // Mostrar stack trace completo para mejor depuración
      print(StackTrace.current);
      
      // Si hay error, creamos una línea directa entre origen y destino
      _createDirectLine(origin, destination);
    }
  }

  // Método para dibujar la polilínea entre dos puntos
  /* Future<void> _getPolyline({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
       // Imprimir información para depuración
      print('📍 Solicitando ruta desde: ${origin.latitude}, ${origin.longitude}');
      print('📍 Hasta: ${destination.latitude}, ${destination.longitude}');
      print('🔑 Usando API key: [verifica que sea correcta]');

      MyPointLatLng originPoint =
          MyPointLatLng(origin.latitude, origin.longitude);
      MyPointLatLng destinationPoint =
          MyPointLatLng(destination.latitude, destination.longitude);

      ResultPolyline result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        originPoint,
        destinationPoint,
        travelMode: MyTravelMode.walking,
      );

      // Información detallada de depuración
      print('🔵 Estado de la respuesta: ${result.status}');
      print('🔢 Cantidad de puntos recibidos: ${result.points.length}');

      // El estado es "OK" pero verificamos explícitamente si hay puntos
      if (result.status == "OK" || result.status == "ok") {
        if (result.points.isEmpty) {
          print('⚠️ Estado OK pero no se recibieron puntos. Posible ruta no encontrada.');
          return;
        }
        // Convertir los puntos recibidos a LatLng para la polyline
        List<LatLng> polylineCoordinates = [];

        for (var point in result.points) {
          // Verificar si los puntos son nulos
          if (point.latitude == null || point.longitude == null) {
            print('⚠️ Punto con coordenadas nulas detectado, omitiendo...');
            continue;
          }
          polylineCoordinates.add(LatLng(point.latitude!, point.longitude!));
          // Imprimir algunos puntos para depuración
          if (polylineCoordinates.length <= 3) {
            print('🧭 Punto ${polylineCoordinates.length}: ${point.latitude}, ${point.longitude}');
          }
        }

        if (polylineCoordinates.isEmpty) {
          print('⚠️ No se pudieron convertir puntos válidos');
          return;
        }

        // Actualizar el estado para mostrar la polilínea
        setState(() {
          polylines.clear();
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blue.shade400,
              points: polylineCoordinates,
              width: 5,
            ),
          );
        });

        print('✅ Polyline creada con ${polylineCoordinates.length} puntos');
      } else {
        print('❌ No se pudo obtener la polyline: ${result.status}');
      }
    } catch (e) {
      print('❌ Error al crear polyline: $e');
      print(StackTrace.current);
    }
  } */

  /// Método para crear las polylines con conectores
  void _createAndSetPolylines({
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> routePoints,
  }) {
    // Limpiar polylines anteriores
    setState(() {
      polylines.clear();
      
      // 1. Añadir la polyline principal (ruta)
      polylines.add(
        Polyline(
          polylineId: const PolylineId('main_route'),
          color: routeColor,
          points: routePoints,
          width: 5,
        ),
      );
      
      // 2. Encontrar los puntos más cercanos en la ruta al origen y destino
      LatLng nearestToOrigin = _findNearestPoint(origin, routePoints);
      LatLng nearestToDestination = _findNearestPoint(destination, routePoints);
      
      // 3. Añadir línea punteada desde el origen hasta el punto más cercano en la ruta
      if (_calculateDistance(origin, nearestToOrigin) > 0.0001) { // Si la distancia es significativa
        polylines.add(
          Polyline(
            polylineId: const PolylineId('origin_connector'),
            color: connectorColor,
            points: [origin, nearestToOrigin],
            width: 3,
            patterns: [
              PatternItem.dash(10), 
              PatternItem.gap(10)
            ],
          ),
        );
      }
      
      // 4. Añadir línea punteada desde el punto más cercano en la ruta hasta el destino
      if (_calculateDistance(destination, nearestToDestination) > 0.0001) { // Si la distancia es significativa
        polylines.add(
          Polyline(
            polylineId: const PolylineId('destination_connector'),
            color: connectorColor,
            points: [nearestToDestination, destination],
            width: 3,
            patterns: [
              PatternItem.dash(10), 
              PatternItem.gap(10)
            ],
          ),
        );
      }
    });
  }
  
  // Método para encontrar el punto más cercano en una lista de puntos
  LatLng _findNearestPoint(LatLng target, List<LatLng> points) {
    if (points.isEmpty) return target;
    
    double minDistance = double.infinity;
    LatLng nearest = points[0];
    
    for (LatLng point in points) {
      double distance = _calculateDistance(target, point);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = point;
      }
    }
    
    return nearest;
  }
  
  // Método para calcular la distancia entre dos puntos (aproximación simple)
  double _calculateDistance(LatLng point1, LatLng point2) {
    // Cálculo simple de distancia euclidiana para comparación
    return sqrt(
      pow(point1.latitude - point2.latitude, 2) + 
      pow(point1.longitude - point2.longitude, 2)
    );
  }
  
  // Método para crear una línea directa si la API falla
  void _createDirectLine(LatLng origin, LatLng destination) {
    setState(() {
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: const PolylineId('direct_route'),
          color: routeColor,
          points: [origin, destination],
          width: 4,
          patterns: [
            PatternItem.dash(10),
            PatternItem.gap(10)
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sigla != null && widget.name != null
            ? '${widget.sigla} - ${widget.name}'
            : 'Mapa'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialPosition,
        markers: {
          Marker(
            markerId: MarkerId(widget.sigla ?? 'location_marker'),
            position: LatLng(widget.initialLatitude, widget.initialLongitude),
            infoWindow: InfoWindow(
              title: widget.sigla,
              snippet: widget.name,
            ),
          ),
          if (_userMarker != null) _userMarker!,
        },
        polylines: polylines, // Añadimos la polilínea al mapa
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_userMarker != null) {
            _getPolyline(
              origin: _userMarker!.position, 
              destination: LatLng(
                widget.initialLatitude,
                widget.initialLongitude,
              ),
            );
          }else{
            // Si no hay marcador de usuario, intentar obtener la ubicación actual
            _locationService.getLocation().then((location) {
              if (location.latitude != null && location.longitude != null) {
                _getPolyline(
                  origin: LatLng(location.latitude!, location.longitude!),
                  destination: LatLng(widget.initialLatitude, widget.initialLongitude),
                );
              }
            });
          }
        },
        child: const Icon(Icons.route),        
      ),
    );
  }
}
