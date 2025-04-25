import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/app_style.dart';
import 'package:unprg_guide_maps/core/constants/map_constants.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/location_info_card.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/location_marker.dart';

class FlutterMapPage extends StatefulWidget {
  final String? title;
  final String? sigla;
  final double initialLatitude;
  final double initialLongitude;
  final List<FacultyItem>? locations;

  const FlutterMapPage({
    super.key,
    this.title,
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
    if (widget.title != null) {
      _selectedTitle = widget.title!;
      _selectedSigla = widget.sigla ?? '';
      _isMarkerSelected = true;
      _selectedMarkerPosition = _center;
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
          fontSize: 21,
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
              widget.title ?? "Campus Principal",
              widget.sigla,
            ),
          ];

    return MarkerLayer(markers: markers);
  }

  Marker _buildMarker(LatLng position, String title, String? sigla) {
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
    
    return Marker(
      width: MapConstants.markerWidth,
      height: MapConstants.markerHeight,
      point: position,
      child: GestureDetector(
        onTap: () => _selectMarker(position, title, sigla ?? ''),
        child: LocationMarker(
          title: title,
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
          icon: const Icon(Icons.my_location, color: Colors.white),
          onPressed: () => _resetMapView(),
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

  void _resetMapView() {
    _mapController.move(_center, MapConstants.initialZoom);
  }
}