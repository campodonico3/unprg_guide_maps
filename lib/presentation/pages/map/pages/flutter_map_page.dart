import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/app_style.dart';
import 'package:unprg_guide_maps/core/constants/map_constants.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/location_info_card.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/location_marker.dart';
import 'package:location/location.dart';

class FlutterMapPage extends StatefulWidget {
  final String? name;
  final String? sigla;
  final double initialLatitude;
  final double initialLongitude;
  final List<FacultyItem>? locations;

  const FlutterMapPage({
    super.key,
    this.name,
    this.sigla,
    this.initialLatitude = -6.70749760689037,
    this.initialLongitude = -79.90452516138711,
    this.locations,
  });

  @override
  State<FlutterMapPage> createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage> {
  late final LatLng _center;
  final MapController _mapController = MapController();
  
  // Selected marker state
  bool _isMarkerSelected = false;
  String _selectedTitle = '';
  String _selectedSigla = '';
  LatLng? _selectedMarkerPosition;
  
  // Card state
  bool _isCardExpanded = false;

  // Location service
  final Location _locationService = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _currentLocation;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeMapState();
  }

  void _initializeMapState() {
    _center = LatLng(
      widget.initialLatitude,
      widget.initialLongitude,
    );

    // Initialize with the widget's title if provided
    if (widget.name != null) {
      _selectedTitle = widget.name!;
      _selectedSigla = widget.sigla ?? '';
      _isMarkerSelected = true;
      _selectedMarkerPosition = _center;
    }
  }

  Future<void> _checkLocationPermissions() async {
    _serviceEnabled = await _locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationService.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationService.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationService.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });
    
    try {
      await _checkLocationPermissions();
      
      if (_serviceEnabled && _permissionGranted == PermissionStatus.granted) {
        _currentLocation = await _locationService.getLocation();
        
        if (_currentLocation != null) {
          final userLocation = LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          );
          
          _mapController.move(userLocation, MapConstants.initialZoom + 2);
          
          // Optional: Show a marker at user's location
          setState(() {
            _isMarkerSelected = true;
            _selectedTitle = "Mi ubicación";
            _selectedSigla = "";
            _selectedMarkerPosition = userLocation;
          });
        }
      } else {
        // Show alert that location permissions are required
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requieren permisos de ubicación para esta función'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener la ubicación: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildMap(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      title: Text(
        'Mapa del Campus',
        style: AppTextStyles.medium.copyWith(
          fontSize: 18,
          color: AppColors.textOnPrimary,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textOnPrimary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: MapConstants.initialZoom,
        maxZoom: MapConstants.maxZoom,
        minZoom: MapConstants.minZoom,
      ),
      children: [
        _buildTileLayer(),
        _buildMarkerLayer(),
        if (_currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              )
            ],
          ),
        if (_isMarkerSelected)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LocationInfoCard(
              isExpanded: _isCardExpanded,
              title: _selectedTitle,
              sigla: _selectedSigla,
              onCardStateChanged: _handleCardStateChanged,
              showNavigateButton: true,
            ),
          ),
      ],
    );
  }

  TileLayer _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.unprg_guide_maps',
      maxZoom: MapConstants.maxZoom,
    );
  }

  MarkerLayer _buildMarkerLayer() {
    final List<Marker> markers = widget.locations != null && widget.locations!.isNotEmpty
        ? widget.locations!.map((location) {
            return _buildMarker(
              LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0),
              location.name,
              location.sigla,
            );
          }).toList()
        : [
            _buildMarker(
              _center,
              widget.name ?? "Campus Principal",
              widget.sigla ?? "Campus Principal",
              //widget.sigla ?? "Campus Principal",
              //widget.name,
            ),
          ];

    return MarkerLayer(markers: markers);
  }

  Marker _buildMarker(LatLng position, String name, String? sigla) {
    // Skip invalid positions
    if (position.latitude == 0.0 && position.longitude == 0.0) {
      return const Marker(
        width: 0,
        height: 0,
        point: LatLng(0, 0),
        child: SizedBox.shrink(),
      );
    }
    
    final bool isSelected = _selectedMarkerPosition != null &&
        _selectedMarkerPosition!.latitude == position.latitude &&
        _selectedMarkerPosition!.longitude == position.longitude;

    // Determinar el título del marcador siguiendo la prioridad establecida
    final String markerTitle = sigla ?? name;
  
    return Marker(
      width: MapConstants.markerWidth,
      height: MapConstants.markerHeight,
      point: position,
      child: GestureDetector(
        onTap: () => _selectMarker(position, name, sigla ?? ''),
        child: LocationMarker(
          title: markerTitle,
          isSelected: isSelected,
        ),
      ),
    );
  }

  void _selectMarker(LatLng position, String title, String sigla) {
    setState(() {
      _isMarkerSelected = true;
      _selectedTitle = title;
      _selectedSigla = sigla;
      _selectedMarkerPosition = position;
    });
  }

  void _handleCardStateChanged(bool isExpanded) {
    setState(() {
      if (!isExpanded && _isCardExpanded) {
        // Collapse card
        _isCardExpanded = false;
      } else if (!isExpanded && !_isCardExpanded) {
        // Hide card
        _isMarkerSelected = false;
        _selectedMarkerPosition = null;
      } else {
        // Expand card
        _isCardExpanded = true;
      }
    });
  }

  Widget _buildFloatingActionButtons() {
    // Si la tarjeta está expandida, no mostramos ningún botón flotante
    if (_isCardExpanded) {
      return SizedBox(
        height: _isMarkerSelected ? 130 : 0, // Mantenemos el espaciado para la tarjeta
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildFloatingButton(
          heroTag: "zoom_in",
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _zoomIn(),
        ),
        const SizedBox(height: 8),
        _buildFloatingButton(
          heroTag: "zoom_out",
          icon: const Icon(Icons.remove, color: Colors.white),
          onPressed: () => _zoomOut(),
        ),
        const SizedBox(height: 8),
        _buildFloatingButton(
          heroTag: "my_location",
          icon: _isGettingLocation 
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.my_location, color: Colors.white),
          onPressed: () => _getCurrentLocation(),
        ),
        // Add padding when the card is displayed
        if (_isMarkerSelected) const SizedBox(height: 130),
      ],
    );
  }

  Widget _buildFloatingButton({
    required String heroTag,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 45,
      height: 45,
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: AppColors.primary,
        onPressed: onPressed,
        child: icon,
      ),
    );
  }

  void _zoomIn() {
    final newZoom = _mapController.camera.zoom + 1;
    _mapController.move(_mapController.camera.center, newZoom);
  }

  void _zoomOut() {
    final newZoom = _mapController.camera.zoom - 1;
    _mapController.move(_mapController.camera.center, newZoom);
  }
  
}