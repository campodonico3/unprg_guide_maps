import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/map_constants.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';
import 'package:unprg_guide_maps/presentation/pages/map/controller/map_controller.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/info_card.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/map_widget.dart';

class FlutterMapPage extends StatefulWidget {
  final List<FacultyItem> locations;
  final String? name;
  final String? sigla;
  final double initialLatitude;
  final double initialLongitude;
  final bool showMultipleMarkers; // Nueva propiedad

  const FlutterMapPage({
    super.key,
    required this.locations,
    this.name,
    this.sigla,
    required this.initialLatitude,
    required this.initialLongitude,
    this.showMultipleMarkers =
        false, // Por defecto false para mantener compatibilidad
  });

  @override
  State<FlutterMapPage> createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage> {
  late final MapController _mapController;
  final MapConstants mapConstants = MapConstants();

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initialLatitude: widget.initialLatitude,
      initialLongitude: widget.initialLongitude,
      name: widget.name,
      sigla: widget.sigla,
      allLocations: widget.showMultipleMarkers ? widget.locations : null,
      showMultipleMarkers: widget.showMultipleMarkers,
    );
    _mapController.initialize();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_buildTitle()),
      ),
      body: Stack(
        children: [
          MapWidget(
            mapController: _mapController,
            sigla: widget.sigla,
            name: widget.name,
            initialLatitude: widget.initialLatitude,
            initialLongitude: widget.initialLongitude,
          ),
          // Card de información
          ListenableBuilder(
              listenable: _mapController,
              builder: (_, __) {
                if (!_mapController.showInfoCard) {
                  return const SizedBox.shrink();
                }

                if (widget.showMultipleMarkers) {
                  // Mostrar card para ubicación seleccionada en modo multiples marcadores
                  final selectedLocation = _mapController.getSelectedLocation();
                  if (selectedLocation == null) return const SizedBox.shrink();

                  return Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: _buildMultipleMarkersInfoCard(selectedLocation),
                  );
                } else {
                  return Positioned(
                    bottom: 0,
                    left: 20,
                    right: 20,
                    child: InfoCard(
                      sigla: widget.sigla,
                      name: widget.name,
                      latitude: widget.initialLatitude,
                      longitude: widget.initialLongitude,
                      onClose: _mapController.hideInfoCard,
                      imagesUrls: [
                        'assets/images/info_card_facultades/ficsa/img_ficsa.jpg'
                        'assets/images/info_card_facultades/ficsa/img_ficsa1.jpg',
                        'assets/images/info_card_facultades/ficsa/img_ficsa2.jpg',                    
                      ],
                    ),
                  );
                }
              })
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return ListenableBuilder(
      listenable: _mapController,
      builder: (_, __) {
        if (widget.showMultipleMarkers) {
          // En modo multiples marcadores, mostrar botón para ver todas las ubicaciones
          return FloatingActionButton(
            onPressed: _mapController.showAllLocations,
            backgroundColor: AppColors.primary,
            child: const Icon(
              Icons.zoom_out_map,
              color: AppColors.background,
            ),
          );
        } else {
          // Botón original para recalcular ruta
          final bottomPadding = _mapController.showInfoCard
              ? MapConstants.infoCardHeightApprox +
                  MapConstants.fabDefaultBottom
              : MapConstants.fabDefaultBottom;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding, right: 16),
            child: FloatingActionButton(
              onPressed: _mapController.recalculateRoute,
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.route,
                color: AppColors.background,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMultipleMarkersInfoCard(FacultyItem location) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.sigla,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _mapController.hideInfoCard,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToSingleLocation(location),
                    icon: const Icon(Icons.navigation, size: 18),
                    label: const Text('Ir aquí'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _mapController.centerOnLocation(location.sigla),
                    icon: const Icon(Icons.center_focus_strong, size: 18),
                    label: const Text('Centrar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSingleLocation(FacultyItem location) {
    // Cerrar el card actual
    _mapController.hideInfoCard();

    // Navegador a la vista individual con navegación
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FlutterMapPage(
          locations: widget.locations,
          name: location.name,
          sigla: location.sigla,
          initialLatitude: location.latitude!,
          initialLongitude: location.longitude!,
          showMultipleMarkers: false,
        ),
      ),
    );
  }

  /* void _centerOnUserLocation() {
    final userMarker = _mapController.userMarker;
    if (userMarker != null) {
      // Lógica para centrar en la ubicación del usuario
      // Puedes implementar esto en el MapController
    }
  } */

  String _buildTitle() {
    if (widget.showMultipleMarkers) {
      return 'Mapa de Ubicaciones';
    }

    if (widget.sigla != null && widget.name != null) {
      return '${widget.sigla} - ${widget.name}';
    }
    return 'Mapa';
  }
}
