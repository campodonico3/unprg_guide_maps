import 'dart:async';

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
  }

  // Método para dibujar la polilínea entre dos puntos
  Future<void> _getPolyline({
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
          }
        },
        child: const Icon(Icons.route),
      ),
    );
  }
}
