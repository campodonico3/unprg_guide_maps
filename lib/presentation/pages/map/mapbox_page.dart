import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';

class MapboxMapPage extends StatefulWidget {
  const MapboxMapPage({super.key});

  @override
  State<MapboxMapPage> createState() => _MapboxMapPageState();
}

class _MapboxMapPageState extends State<MapboxMapPage> {
  MapboxMap? mapboxMap;
  // Reemplaza esto con tu token de acceso público de Mapbox
  final String accessToken = 'pk.eyJ1IjoibWFkY2l0bzEzIiwiYSI6ImNtOWpmc2txdTA5a3MybHEwZG81cjl6cmUifQ.VElvnaSy9735FFZX-g8f8w';
  
  // Coordenadas predeterminadas (ajusta según la ubicación de tu universidad)
  final double defaultLatitude = -6.70749760689037; // Para Lambayeque, Perú (ajustar según ubicación real)
  final double defaultLongitude = -79.90452516138711; // Para Lambayeque, Perú (ajustar según ubicación real)
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Mapa del Campus',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildMapboxMap(),
    );
  }

  Widget _buildMapboxMap() {
    return MapWidget(
      key: const ValueKey('mapWidget'),
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            defaultLongitude, 
            defaultLatitude
          )
        ),
        zoom: 15.0,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: (styleLoaded) {
        debugPrint('Estilo del mapa cargado');
      },
    );
  }

  void _onMapCreated(MapboxMap map) {
    setState(() {
      mapboxMap = map;
    });

    Future.delayed(Duration(milliseconds: 500), (){
      _addBuildingMarkers();
    });

  }


  Future<void> _addBuildingMarkers() async {
    // Asegúrate de que el mapa se haya inicializado
    if (mapboxMap == null) return;

    try {
      // Obtener el gestor de anotaciones de puntos
      final pointAnnotationManager = await mapboxMap!.annotations.createPointAnnotationManager();
      
      // Lista de edificios (ejemplo)
      final buildings = [
        {
          'name': 'Facultad de Ingeniería',
          'coordinates': [defaultLongitude, defaultLatitude]
        },
        {
          'name': 'Biblioteca Central',
          'coordinates': [defaultLongitude + 0.002, defaultLatitude + 0.001]
        },
        // Añade más edificios según necesites
      ];

      // Cargar la imagen del marcador desde los assets
      final ByteData bytes = await rootBundle.load('assets/images/img_agronomia_logo.png');
      final Uint8List imageBytes = bytes.buffer.asUint8List();

      // Crear un marcador para cada edificio
      for (final building in buildings) {
        // Obtener las coordenadas como doubles no nulos
        final double longitude = (building['coordinates'] as List)[0] as double;
        final double latitude = (building['coordinates'] as List)[1] as double;
        
        // Crear opciones para el marcador
        final options = PointAnnotationOptions(
          // Geometría del punto (ubicación)
          geometry: Point(
            coordinates: Position(longitude, latitude)
          ),
          // Usar 'image' para proporcionar directamente los bytes de la imagen
          image: imageBytes,
          // Tamaño del icono
          iconSize: 1.0,
          // Campo de texto para mostrar el nombre
          textField: building['name'].toString(),
          // Tamaño del texto
          textSize: 12.0,
          // Desplazamiento del texto (usando valores no nulos)
          textOffset: [0.0, 2.0],
          // Color del texto
          textColor: Colors.black.value,
        );
        
        // Crear el marcador
        await pointAnnotationManager.create(options);
      }
    } catch (e) {
      debugPrint('Error al añadir marcadores: $e');
    }
  }
}