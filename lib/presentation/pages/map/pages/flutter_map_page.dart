import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/app_style.dart';
import 'package:unprg_guide_maps/core/constants/map_constants.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/location_info_card.dart';
// Importamos nuestros nuevos widgets y servicios
import 'package:unprg_guide_maps/presentation/pages/map/widgets/map_floating_buttons.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/custom_map_view.dart';
import 'package:unprg_guide_maps/core/services/location_service.dart';
import 'package:unprg_guide_maps/core/services/marker_service.dart';


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
  final LocationService _locationService = LocationService();
  final MarkerService _markerService = MarkerService();
  
  GoogleMapController? _mapController;
  bool _isGettingLocation = false;
  
  // Selected marker state
  bool _isMarkerSelected = false;
  String _selectedTitle = '';
  String _selectedSigla = '';
  LatLng? _selectedMarkerPosition;
  
  // Card state
  bool _isCardExpanded = false;
  
  // Markers collection
  Set<Marker> _markers = {};
  bool _markersReady = false;
  
  @override
  void initState() {
    super.initState();
    _initMapState();
  }
  
  Future<void> _initMapState() async {
    _center = LatLng(
      widget.initialLatitude,
      widget.initialLongitude,
    );
    
    // Initialize marker icons
    await _markerService.initialize();
    
    // Initial selection if provided
    if (widget.name != null) {
      _selectedTitle = widget.name!;
      _selectedSigla = widget.sigla ?? '';
      _isMarkerSelected = true;
      _selectedMarkerPosition = _center;
    }
    
    // Setup markers
    await _setupMarkers();
    
    setState(() {
      _markersReady = true;
    });
  }
  
  Future<void> _setupMarkers() async {
    Set<Marker> markers = {};
    
    if (widget.locations != null && widget.locations!.isNotEmpty) {
      for (var location in widget.locations!) {
        if (location.latitude != null && 
            location.longitude != null && 
            (location.latitude != 0.0 || location.longitude != 0.0)) {
          
          final isSelected = location.name == _selectedTitle;
          final marker = await _markerService.createLocationMarker(
            location.name,
            LatLng(location.latitude!, location.longitude!),
            location.sigla,
            isSelected,
            onTap: () => _selectMarker(
              LatLng(location.latitude!, location.longitude!),
              location.name,
              location.sigla,
            ),
          );
          
          markers.add(marker);
        }
      }
    } else {
      // Add default marker for the center point
      final marker = await _markerService.createLocationMarker(
        widget.name ?? "Campus Principal",
        _center,
        widget.sigla ?? '',
        _isMarkerSelected,
        onTap: () => _selectMarker(
          _center,
          widget.name ?? "Campus Principal",
          widget.sigla ?? '',
        ),
      );
      
      markers.add(marker);
    }
    
    setState(() {
      _markers = markers;
    });
  }
  
  Future<void> _updateMarkerSelection() async {
    final updatedMarkers = await _markerService.updateMarkerSelections(
      _markers, 
      _selectedTitle,
      widget.name ?? "Campus Principal"
    );
    
    setState(() {
      _markers = updatedMarkers;
    });
  }
  
  void _selectMarker(LatLng position, String title, String sigla) {
    setState(() {
      _isMarkerSelected = true;
      _selectedTitle = title;
      _selectedSigla = sigla;
      _selectedMarkerPosition = position;
    });
    
    // Update marker appearances
    _updateMarkerSelection();
    
    // Center the map on the selected marker
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
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
        _updateMarkerSelection();
      } else {
        // Expand card
        _isCardExpanded = true;
      }
    });
  }
  
  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;
    
    setState(() {
      _isGettingLocation = true;
    });
    
    try {
      final locationResult = await _locationService.getCurrentLocation(context);
      
      if (locationResult != null && _mapController != null) {
        final userLocation = locationResult.position;
        
        // Animate to user location
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: userLocation,
              zoom: MapConstants.initialZoom + 2,
            ),
          ),
        );
        
        // Create user location marker
        final userMarker = await _markerService.createUserLocationMarker(
          userLocation,
          onTap: () => _selectMarker(
            userLocation,
            "Mi ubicación",
            "",
          ),
        );
        
        // Update markers
        setState(() {
          // Remove old user location marker if exists
          _markers.removeWhere((marker) => marker.markerId.value == "my_location");
          _markers.add(userMarker);
          
          _isMarkerSelected = true;
          _selectedTitle = "Mi ubicación";
          _selectedSigla = "";
          _selectedMarkerPosition = userLocation;
        });
        
        // Update marker selections
        _updateMarkerSelection();
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
  
  void _handleMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _markerService.setMapStyle(controller);
  }
  
  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }
  
  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    if (!_markersReady) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          CustomMapView(
            center: _center, 
            markers: _markers,
            onMapCreated: _handleMapCreated,
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
      ),
      floatingActionButton: MapFloatingButtons(
        isCardExpanded: _isCardExpanded,
        isMarkerSelected: _isMarkerSelected,
        isGettingLocation: _isGettingLocation,
        onZoomIn: _zoomIn,
        onZoomOut: _zoomOut,
        onGetLocation: _getCurrentLocation,
      ),
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
}